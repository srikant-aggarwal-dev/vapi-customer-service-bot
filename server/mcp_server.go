package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"
	"time"
)

// MCPServer represents our MCP server
type MCPServer struct {
	clients []Client
}

// MCPRequest represents a JSON-RPC request
type MCPRequest struct {
	JSONRPC string                 `json:"jsonrpc"`
	ID      interface{}            `json:"id"`
	Method  string                 `json:"method"`
	Params  map[string]interface{} `json:"params,omitempty"`
}

// MCPResponse represents a JSON-RPC response
type MCPResponse struct {
	JSONRPC string                 `json:"jsonrpc"`
	ID      interface{}            `json:"id"`
	Result  map[string]interface{} `json:"result,omitempty"`
	Error   *MCPError              `json:"error,omitempty"`
}

// MCPError represents a JSON-RPC error
type MCPError struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

// Tool represents an MCP tool
type Tool struct {
	Name        string                 `json:"name"`
	Description string                 `json:"description"`
	InputSchema map[string]interface{} `json:"inputSchema"`
}

// Initialize handles the MCP initialization
func (s *MCPServer) Initialize(request MCPRequest) MCPResponse {
	return MCPResponse{
		JSONRPC: "2.0",
		ID:      request.ID,
		Result: map[string]interface{}{
			"protocolVersion": "2024-11-05",
			"capabilities": map[string]interface{}{
				"tools": map[string]interface{}{},
			},
			"serverInfo": map[string]interface{}{
				"name":    "PersonalFinanceAdvisorMCPServer",
				"version": "1.0.0",
			},
		},
	}
}

// ListTools returns available tools
func (s *MCPServer) ListTools(request MCPRequest) MCPResponse {
	tools := []Tool{
		{
			Name:        "capture_client",
			Description: "Capture client financial information for debt analysis",
			InputSchema: map[string]interface{}{
				"type": "object",
				"properties": map[string]interface{}{
					"name":                map[string]string{"type": "string", "description": "Full name"},
					"email":               map[string]string{"type": "string", "description": "Email address"},
					"phone":               map[string]string{"type": "string", "description": "Phone number"},
					"province":            map[string]string{"type": "string", "description": "Canadian province of residence"},
					"total_debt":          map[string]string{"type": "number", "description": "Total debt amount in dollars"},
					"credit_card_debt":    map[string]string{"type": "number", "description": "Total credit card debt in dollars"},
					"monthly_income":      map[string]string{"type": "number", "description": "Monthly income after taxes"},
					"monthly_expenses":    map[string]string{"type": "number", "description": "Monthly expenses excluding debt payments"},
					"minimum_payments":    map[string]string{"type": "number", "description": "Total monthly minimum debt payments"},
					"interest_rates":      map[string]string{"type": "array", "description": "List of interest rates on different debts"},
					"debt_sources":        map[string]string{"type": "array", "description": "Sources of debt (credit cards, loans, etc)"},
					"financial_goals":     map[string]string{"type": "array", "description": "Client's financial goals"},
					"recommended_action":  map[string]string{"type": "string", "description": "Initial recommendation for debt reduction"},
					"status":              map[string]string{"type": "string", "description": "initial-assessment, plan-created, or follow-up"},
				},
				"required": []string{"name", "email"},
			},
		},
		{
			Name:        "end_call",
			Description: "End the call when user requests",
			InputSchema: map[string]interface{}{
				"type": "object",
				"properties": map[string]interface{}{
					"reason": map[string]string{"type": "string", "description": "Reason for ending the call"},
				},
				"required": []string{"reason"},
			},
		},
	}

	return MCPResponse{
		JSONRPC: "2.0",
		ID:      request.ID,
		Result: map[string]interface{}{
			"tools": tools,
		},
	}
}

// CallTool executes a tool
func (s *MCPServer) CallTool(request MCPRequest) MCPResponse {
	toolName, _ := request.Params["name"].(string)
	arguments, _ := request.Params["arguments"].(map[string]interface{})

	switch toolName {
	case "capture_client":
		return s.captureClient(request.ID, arguments)
	case "end_call":
		return s.endCall(request.ID, arguments)
	default:
		return MCPResponse{
			JSONRPC: "2.0",
			ID:      request.ID,
			Error: &MCPError{
				Code:    -32601,
				Message: "Tool not found",
			},
		}
	}
}

func (s *MCPServer) captureClient(id interface{}, args map[string]interface{}) MCPResponse {
	client := Client{
		ID:        generateClientID(),
		CreatedAt: time.Now(),
		Status:    "initial-assessment",
	}

	// Extract client information
	if name, ok := args["name"].(string); ok {
		client.Name = name
	}
	if email, ok := args["email"].(string); ok {
		client.Email = email
	}
	if phone, ok := args["phone"].(string); ok {
		client.Phone = phone
	}
	if province, ok := args["province"].(string); ok {
		client.Province = province
	}
	
	// Extract financial information
	if totalDebt, ok := args["total_debt"].(float64); ok {
		client.TotalDebt = totalDebt
	}
	if creditCardDebt, ok := args["credit_card_debt"].(float64); ok {
		client.CreditCardDebt = creditCardDebt
	}
	if monthlyIncome, ok := args["monthly_income"].(float64); ok {
		client.MonthlyIncome = monthlyIncome
	}
	if monthlyExpenses, ok := args["monthly_expenses"].(float64); ok {
		client.MonthlyExpenses = monthlyExpenses
	}
	if minimumPayments, ok := args["minimum_payments"].(float64); ok {
		client.MinimumPayments = minimumPayments
	}
	
	// Extract arrays
	if interestRates, ok := args["interest_rates"].([]interface{}); ok {
		for _, rate := range interestRates {
			if r, ok := rate.(float64); ok {
				client.InterestRates = append(client.InterestRates, r)
			}
		}
	}
	if debtSources, ok := args["debt_sources"].([]interface{}); ok {
		for _, source := range debtSources {
			if s, ok := source.(string); ok {
				client.DebtSources = append(client.DebtSources, s)
			}
		}
	}
	if financialGoals, ok := args["financial_goals"].([]interface{}); ok {
		for _, goal := range financialGoals {
			if g, ok := goal.(string); ok {
				client.FinancialGoals = append(client.FinancialGoals, g)
			}
		}
	}
	
	if recommendedAction, ok := args["recommended_action"].(string); ok {
		client.RecommendedAction = recommendedAction
	}
	if status, ok := args["status"].(string); ok {
		client.Status = status
	}

	// Calculate debt-to-income ratio for logging
	debtToIncome := 0.0
	if client.MonthlyIncome > 0 {
		debtToIncome = client.MinimumPayments / client.MonthlyIncome * 100
	}

	// Store client in the shared clients array
	clients = append(clients, client)
	s.clients = clients // Update local reference

	log.Printf("Client captured via MCP: %s - Total Debt: $%.2f, DTI: %.1f%%", client.Name, client.TotalDebt, debtToIncome)

	return MCPResponse{
		JSONRPC: "2.0",
		ID:      id,
		Result: map[string]interface{}{
			"success":  true,
			"clientId": client.ID,
			"message":  fmt.Sprintf("Client %s captured successfully", client.Name),
		},
	}
}

func (s *MCPServer) endCall(id interface{}, args map[string]interface{}) MCPResponse {
	reason, _ := args["reason"].(string)
	
	log.Printf("🎯 MCP: End call requested. Reason: %s", reason)
	
	// In MCP context, we just acknowledge the request
	// VAPI will handle the actual call termination
	return MCPResponse{
		JSONRPC: "2.0",
		ID:      id,
		Result: map[string]interface{}{
			"success": true,
			"message": "Call end acknowledged",
			"reason":  reason,
		},
	}
}

// ProcessRequest handles incoming MCP requests
func (s *MCPServer) ProcessRequest(request MCPRequest) MCPResponse {
	switch request.Method {
	case "initialize":
		return s.Initialize(request)
	case "tools/list":
		return s.ListTools(request)
	case "tools/call":
		return s.CallTool(request)
	default:
		return MCPResponse{
			JSONRPC: "2.0",
			ID:      request.ID,
			Error: &MCPError{
				Code:    -32601,
				Message: "Method not found",
			},
		}
	}
}

// RunMCPServer starts the MCP server using stdio transport
func RunMCPServer() {
	server := &MCPServer{
		clients: clients, // Use the shared clients array
	}

	decoder := json.NewDecoder(os.Stdin)
	encoder := json.NewEncoder(os.Stdout)

	log.SetOutput(os.Stderr) // Send logs to stderr so they don't interfere with JSON output

	log.Println("MCP Server started")

	for {
		var request MCPRequest
		if err := decoder.Decode(&request); err != nil {
			if err == io.EOF {
				log.Println("MCP Server: stdin closed, shutting down")
				break
			}
			log.Printf("Error decoding request: %v", err)
			continue
		}

		response := server.ProcessRequest(request)
		
		if err := encoder.Encode(response); err != nil {
			log.Printf("Error encoding response: %v", err)
		}
	}
} 