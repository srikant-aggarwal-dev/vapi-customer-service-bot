package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os/exec"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

// MCPSession represents an active MCP session
type MCPSession struct {
	ID        string
	Process   *exec.Cmd
	Stdin     io.WriteCloser
	Stdout    io.ReadCloser
	Stderr    io.ReadCloser
	Reader    *json.Decoder
	Writer    *json.Encoder
	Mutex     sync.Mutex
	LastUsed  time.Time
}

var (
	mcpSessions = make(map[string]*MCPSession)
	sessionsMux sync.Mutex
)

// handleMCPInfo returns information about the MCP server
func handleMCPInfo(c *gin.Context) {
	c.JSON(200, gin.H{
		"type": "mcp",
		"version": "2024-11-05",
		"status": "ready",
		"endpoints": []string{
			"/mcp/initialize",
			"/mcp/request",
			"/mcp/session/:id",
		},
	})
}

// AddMCPRoutes adds MCP HTTP bridge routes to the Gin router
func AddMCPRoutes(r *gin.Engine) {
	// Add a base MCP info endpoint
	r.GET("/mcp", handleMCPInfo)
	
	mcp := r.Group("/mcp")
	{
		mcp.POST("/initialize", handleMCPInitialize)
		mcp.POST("/request", handleMCPRequest)
		mcp.DELETE("/session/:id", handleMCPCloseSession)
	}

	// Cleanup old sessions periodically
	go cleanupOldSessions()
}

func handleMCPInitialize(c *gin.Context) {
	sessionID := generateSessionID()
	
	// Start MCP server process
	cmd := exec.Command("go", "run", ".", "mcp")
	// cmd.Dir is not set, so it uses current directory
	
	stdin, err := cmd.StdinPipe()
	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to create stdin pipe"})
		return
	}
	
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to create stdout pipe"})
		return
	}
	
	stderr, err := cmd.StderrPipe()
	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to create stderr pipe"})
		return
	}
	
	if err := cmd.Start(); err != nil {
		c.JSON(500, gin.H{"error": "Failed to start MCP server"})
		return
	}
	
	session := &MCPSession{
		ID:       sessionID,
		Process:  cmd,
		Stdin:    stdin,
		Stdout:   stdout,
		Stderr:   stderr,
		Reader:   json.NewDecoder(stdout),
		Writer:   json.NewEncoder(stdin),
		LastUsed: time.Now(),
	}
	
	// Send initialize request
	initReq := MCPRequest{
		JSONRPC: "2.0",
		ID:      "init",
		Method:  "initialize",
		Params: map[string]interface{}{
			"protocolVersion": "2024-11-05",
			"capabilities": map[string]interface{}{
				"roots": map[string]interface{}{
					"listChanged": true,
				},
				"sampling": map[string]interface{}{},
			},
			"clientInfo": map[string]interface{}{
				"name":    "VAPI-HTTP-Bridge",
				"version": "1.0.0",
			},
		},
	}
	
	var response MCPResponse
	if err := session.sendRequest(initReq, &response); err != nil {
		cmd.Process.Kill()
		c.JSON(500, gin.H{"error": "Failed to initialize MCP session"})
		return
	}
	
	// Store session
	sessionsMux.Lock()
	mcpSessions[sessionID] = session
	sessionsMux.Unlock()
	
	// Log stderr in background
	go logStderr(session)
	
	c.JSON(200, gin.H{
		"sessionId": sessionID,
		"result":    response.Result,
	})
}

func handleMCPRequest(c *gin.Context) {
	var req struct {
		SessionID string                 `json:"sessionId"`
		Method    string                 `json:"method"`
		Params    map[string]interface{} `json:"params"`
		ID        interface{}            `json:"id"`
	}
	
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Invalid request"})
		return
	}
	
	sessionsMux.Lock()
	session, exists := mcpSessions[req.SessionID]
	sessionsMux.Unlock()
	
	if !exists {
		c.JSON(404, gin.H{"error": "Session not found"})
		return
	}
	
	session.LastUsed = time.Now()
	
	mcpReq := MCPRequest{
		JSONRPC: "2.0",
		ID:      req.ID,
		Method:  req.Method,
		Params:  req.Params,
	}
	
	var response MCPResponse
	if err := session.sendRequest(mcpReq, &response); err != nil {
		c.JSON(500, gin.H{"error": fmt.Sprintf("MCP request failed: %v", err)})
		return
	}
	
	// Return the response
	if response.Error != nil {
		c.JSON(200, gin.H{
			"error": response.Error,
		})
	} else {
		c.JSON(200, gin.H{
			"result": response.Result,
		})
	}
}

func handleMCPCloseSession(c *gin.Context) {
	sessionID := c.Param("id")
	
	sessionsMux.Lock()
	session, exists := mcpSessions[sessionID]
	if exists {
		delete(mcpSessions, sessionID)
	}
	sessionsMux.Unlock()
	
	if !exists {
		c.JSON(404, gin.H{"error": "Session not found"})
		return
	}
	
	// Close the session
	session.close()
	
	c.JSON(200, gin.H{"message": "Session closed"})
}

func (s *MCPSession) sendRequest(req MCPRequest, resp *MCPResponse) error {
	s.Mutex.Lock()
	defer s.Mutex.Unlock()
	
	// Send request
	if err := s.Writer.Encode(req); err != nil {
		return fmt.Errorf("failed to send request: %v", err)
	}
	
	// Read response
	if err := s.Reader.Decode(resp); err != nil {
		return fmt.Errorf("failed to read response: %v", err)
	}
	
	return nil
}

func (s *MCPSession) close() {
	s.Stdin.Close()
	s.Process.Wait()
}

func logStderr(session *MCPSession) {
	buf := make([]byte, 1024)
	for {
		n, err := session.Stderr.Read(buf)
		if err != nil {
			break
		}
		if n > 0 {
			log.Printf("MCP[%s] stderr: %s", session.ID, string(buf[:n]))
		}
	}
}

func cleanupOldSessions() {
	ticker := time.NewTicker(5 * time.Minute)
	defer ticker.Stop()
	
	for range ticker.C {
		sessionsMux.Lock()
		now := time.Now()
		for id, session := range mcpSessions {
			if now.Sub(session.LastUsed) > 10*time.Minute {
				log.Printf("Cleaning up idle MCP session: %s", id)
				delete(mcpSessions, id)
				go session.close()
			}
		}
		sessionsMux.Unlock()
	}
}

func generateSessionID() string {
	return fmt.Sprintf("mcp_%d", time.Now().UnixNano())
} 