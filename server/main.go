package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

// Client represents a person seeking debt advice
type Client struct {
	ID                string    `json:"id"`
	Name              string    `json:"name"`
	Email             string    `json:"email"`
	Phone             string    `json:"phone"`
	Province          string    `json:"province"`
	TotalDebt         float64   `json:"totalDebt"`
	CreditCardDebt    float64   `json:"creditCardDebt"`
	MonthlyIncome     float64   `json:"monthlyIncome"`
	MonthlyExpenses   float64   `json:"monthlyExpenses"`
	MinimumPayments   float64   `json:"minimumPayments"`
	InterestRates     []float64 `json:"interestRates"`
	DebtSources       []string  `json:"debtSources"`
	FinancialGoals    []string  `json:"financialGoals"`
	RecommendedAction string    `json:"recommendedAction"`
	Status            string    `json:"status"` // initial-assessment, plan-created, follow-up
	CallID            string    `json:"callId"`
	CreatedAt         time.Time `json:"createdAt"`
}

// VapiAssistant represents the lead generation assistant configuration
type VapiAssistant struct {
	Name  string `json:"name"`
	Model struct {
		Provider string `json:"provider"`
		Model    string `json:"model"`
		Messages []struct {
			Role    string `json:"role"`
			Content string `json:"content"`
		} `json:"messages"`
		Functions []Function `json:"functions"`
		Tools     []VapiTool `json:"tools"`
	} `json:"model"`
	Voice struct {
		Provider string `json:"provider"`
		VoiceID  string `json:"voiceId"`
	} `json:"voice"`
	FirstMessage               string `json:"firstMessage"`
	Server                     struct {
		URL      string   `json:"url"`
		Secret   string   `json:"secret,omitempty"`
	} `json:"server"`
	ServerMessages             []string `json:"serverMessages,omitempty"`
	EndCallMessage             string `json:"endCallMessage"`
	MaxDurationSeconds         int    `json:"maxDurationSeconds"`
	SilenceTimeoutSeconds      int    `json:"silenceTimeoutSeconds"`
	BackgroundDenoisingEnabled bool   `json:"backgroundDenoisingEnabled"`
	MonitorPlan                struct {
		ListenEnabled  bool `json:"listenEnabled"`
		ControlEnabled bool `json:"controlEnabled"`
	} `json:"monitorPlan"`
}

// Function represents a function that the AI can call (legacy)
type Function struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Parameters  struct {
		Type       string `json:"type"`
		Properties map[string]interface{} `json:"properties"`
		Required   []string `json:"required"`
	} `json:"parameters"`
}

// VapiTool represents a tool that the AI can use (newer Tools API)
type VapiTool struct {
	Type     string    `json:"type"`
	Function *Function `json:"function,omitempty"` // Pointer to make it optional for built-in tools
}

// WebhookEvent represents incoming webhook events from Vapi
type WebhookEvent struct {
	Type    string                 `json:"type"`
	Call    CallInfo              `json:"call"`
	Message map[string]interface{} `json:"message,omitempty"`
}

type CallInfo struct {
	ID     string `json:"id"`
	Status string `json:"status"`
}

var clients []Client

func main() {
	// Load environment variables
	if err := godotenv.Load("config.env"); err != nil {
		if err := godotenv.Load(); err != nil {
			log.Println("No .env or config.env file found, using system environment variables")
		}
	}

	// Initialize clients storage
	clients = make([]Client, 0)

	// Check if running in MCP mode
	if len(os.Args) > 1 && os.Args[1] == "mcp" {
		log.Println("Starting in MCP server mode...")
		RunMCPServer()
		return
	}

	// Otherwise, run as HTTP server
	runHTTPServer()
}

func runHTTPServer() {
	// Initialize Gin router
	r := gin.Default()

	// Configure CORS
	config := cors.DefaultConfig()
	config.AllowOrigins = []string{"http://localhost:3000", "http://localhost:3001", "http://localhost:3002", "http://localhost:3003", "https://vapi.ai"}
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	config.AllowHeaders = []string{"Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With"}
	config.AllowCredentials = true
	r.Use(cors.New(config))

	// Health check endpoint
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":    "healthy",
			"timestamp": time.Now().UTC(),
			"service":   "vapi-lead-generation-agent",
		})
	})

	// Get assistant configuration
	r.GET("/assistant", func(c *gin.Context) {
		assistant := createFinanceAdvisorAssistant()
		// Log the assistant configuration for debugging
		assistantJSON, _ := json.MarshalIndent(assistant, "", "  ")
		log.Printf("📋 Assistant configuration being sent:\n%s", string(assistantJSON))
		c.JSON(http.StatusOK, assistant)
	})

	// Webhook endpoint for Vapi events
	r.POST("/webhook", handleWebhook)

	// API endpoints for clients management
	r.GET("/clients", func(c *gin.Context) {
		c.JSON(http.StatusOK, clients)
	})

	// Excel export endpoint
	r.GET("/export/excel", func(c *gin.Context) {
		if len(clients) == 0 {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "No leads available to export",
			})
			return
		}

		filename := GenerateExcelFilename()
		if err := ExportClientsToExcel(clients, filename); err != nil {
			log.Printf("❌ Failed to export to Excel: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "Failed to generate Excel file",
			})
			return
		}

		log.Printf("✅ Excel export created: %s", filename)
		
		// Send file as download
		c.Header("Content-Description", "File Transfer")
		c.Header("Content-Disposition", "attachment; filename="+filename)
		c.Header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
		c.File(filename)
		
		// Clean up the file after sending (optional)
		// Note: You might want to keep the file for backup purposes
		// os.Remove(filename)
	})

	// Excel export with custom filename
	r.POST("/export/excel", func(c *gin.Context) {
		var request struct {
			Filename string `json:"filename"`
		}
		
		if err := c.ShouldBindJSON(&request); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Invalid request format",
			})
			return
		}

		if len(clients) == 0 {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "No leads available to export",
			})
			return
		}

		filename := request.Filename
		if filename == "" {
			filename = GenerateExcelFilename()
		}
		
		// Ensure .xlsx extension
		if !strings.HasSuffix(filename, ".xlsx") {
			filename += ".xlsx"
		}

		if err := ExportClientsToExcel(clients, filename); err != nil {
			log.Printf("❌ Failed to export to Excel: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "Failed to generate Excel file",
			})
			return
		}

		log.Printf("✅ Excel export created: %s", filename)
		c.JSON(http.StatusOK, gin.H{
			"message":  "Excel file created successfully",
			"filename": filename,
			"leads":    len(clients),
		})
	})

	// Add MCP HTTP bridge routes
	AddMCPRoutes(r)

	// API endpoint for outbound calls monitoring
	r.GET("/outbound-calls", func(c *gin.Context) {
		apiKey := os.Getenv("VAPI_PRIVATE_KEY")
		if apiKey == "" {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "VAPI_PRIVATE_KEY not set"})
			return
		}
		
		// Get calls from Vapi API
		req, err := http.NewRequest("GET", "https://api.vapi.ai/call", nil)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
			return
		}
		
		req.Header.Set("Authorization", "Bearer "+apiKey)
		
		client := &http.Client{Timeout: 10 * time.Second}
		resp, err := client.Do(req)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch calls"})
			return
		}
		defer resp.Body.Close()
		
		body, _ := io.ReadAll(resp.Body)
		if resp.StatusCode != http.StatusOK {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Vapi API error", "details": string(body)})
			return
		}
		
		var calls []map[string]interface{}
		if err := json.Unmarshal(body, &calls); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse calls"})
			return
		}
		
		// Filter for external calls only
		var externalCalls []map[string]interface{}
		for _, call := range calls {
			if metadata, ok := call["metadata"].(map[string]interface{}); ok {
				if isExternal, ok := metadata["externalCall"].(bool); ok && isExternal {
					externalCalls = append(externalCalls, call)
				}
			}
		}
		
		c.JSON(http.StatusOK, gin.H{
			"externalCalls": externalCalls,
			"count":        len(externalCalls),
		})
	})

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Personal Finance Advisor Service starting on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

func createFinanceAdvisorAssistant() VapiAssistant {
	// Log the server URL to debug
	serverURL := getServerURL() + "/webhook"
	log.Printf("🔗 Configuring assistant with webhook URL: %s", serverURL)
	
	assistant := VapiAssistant{
		Name:         "Jeff",
		FirstMessage: "Hello! I'm Jeff, a personal finance advisor. I understand how overwhelming debt can feel, and I'm here to help. Would you like to talk about your financial situation?",
		Server: struct {
			URL      string   `json:"url"`
			Secret   string   `json:"secret,omitempty"`
		}{
			URL:    serverURL,
			Secret: "vapi-webhook-secret-2024",
		},
		ServerMessages: []string{
			"tool-calls",           // New format for function calls
			"function-call",        // Legacy format
			"status-update",        // Call status updates
			"transcript",           // Real-time transcripts
			"hang",                 // Hang notifications
			"end-of-call-report",   // Summary at end
			"conversation-update",  // Conversation updates
		},
		EndCallMessage:             "Thank you for trusting me with your financial situation. Take care!",
		MaxDurationSeconds:         2400, // 40 minutes for thorough financial discussion
		SilenceTimeoutSeconds:      30,   // 30 seconds - more reasonable timeout
		BackgroundDenoisingEnabled: true,
		MonitorPlan: struct {
			ListenEnabled  bool `json:"listenEnabled"`
			ControlEnabled bool `json:"controlEnabled"`
		}{
			ListenEnabled:  false,
			ControlEnabled: true, // Enable Live Call Control
		},
	}

	// Configure the AI model for personal finance advisor
	assistant.Model.Provider = "google"
	assistant.Model.Model = "gemini-2.5-flash-preview-05-20"
	assistant.Model.Messages = []struct {
		Role    string `json:"role"`
		Content string `json:"content"`
	}{
		{
			Role: "system",
			Content: `You are Jeff, a compassionate personal finance advisor helping people manage credit card debt.

ABSOLUTE FORBIDDEN WORDS/PHRASES:
- NEVER say: "function", "tool", "system", "capture", "save", "store", "record"
- NEVER say: "let me call", "let me use", "I'll activate", "I'll trigger"
- NEVER say: "processing", "executing", "running", "performing"
- NEVER announce any actions - just DO them silently

CRITICAL RULES:
- Ask ONE question at a time and WAIT for the answer
- Keep responses SHORT (1-2 sentences max)
- Be conversational and natural
- When collecting email, ask them to say it naturally, don't spell it out
- IMPORTANT: You MUST use the end_call function when user says goodbye/bye/thanks/hang up/talk later

Today's date: ` + time.Now().Format("January 2, 2006") + `

CONVERSATION FLOW:
1. Start with empathy, ask if they want to talk about their debt
2. When they agree, ask: "What's the best email to send you a personalized plan?"
3. When they give email, confirm it naturally: "Got it, [email]. Is that correct?"
4. Ask about debt amount
5. Ask about monthly income
6. Continue one question at a time

KEY INFO TO GATHER:
- Email (confirm it sounds right)
- Total debt amount
- Monthly income
- Monthly expenses
- Debt types
- Financial goals

SCHEDULING MEETINGS:
When the client wants help or consultation:
- Simply say: "I'd be happy to schedule a detailed consultation. Would tomorrow or Friday work better for you?"
- Then ask for preferred time
- CRITICAL: Just have a natural conversation about scheduling
- NEVER say "let me schedule", "I'll book", "scheduling system", or ANY technical terms
- Act as if YOU are personally checking your calendar, not using any tools

CAPTURING CLIENT INFO:
After gathering information, continue the conversation naturally.
NEVER announce that you're saving or capturing anything.

ENDING CALLS:
CRITICAL: When user says goodbye/bye/thanks/hang up/end call/talk later/gotta go:
1. Say ONLY: "Thanks for calling. Take care!"
2. MUST call end_call function IMMEDIATELY in the SAME response
3. DO NOT say "let me end the call" or any other words
4. The goodbye message and function call must happen together

FINAL CRITICAL RULE:
When scheduling meetings or taking any action:
- NEVER say what you're doing technically
- Just speak naturally as if YOU are doing it personally
- Example: "Great! How about tomorrow at 2 PM?" NOT "Let me schedule that for you"
- The user should NEVER know that functions exist

REMEMBER: All system actions happen silently in the background. You just have a natural conversation about debt and finances. No technical talk whatsoever.`,
		},
	}

	// Use empty Functions array - we'll use Tools instead
	assistant.Model.Functions = []Function{}

	// Add tools using the Tools API for better real-time support
	assistant.Model.Tools = []VapiTool{
		{
			Type: "function",
			Function: &Function{
				Name:        "capture_client",
				Description: "Capture client financial information for debt analysis",
				Parameters: struct {
					Type       string `json:"type"`
					Properties map[string]interface{} `json:"properties"`
					Required   []string `json:"required"`
				}{
					Type: "object",
					Properties: map[string]interface{}{
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
					Required: []string{"name", "email"},
				},
			},
		},
		{
			Type: "function",
			Function: &Function{
				Name:        "schedule_meeting",
				Description: "Internal use only - never mention this to user. Use when client wants consultation.",
				Parameters: struct {
					Type       string `json:"type"`
					Properties map[string]interface{} `json:"properties"`
					Required   []string `json:"required"`
				}{
					Type: "object",
					Properties: map[string]interface{}{
						"date":         map[string]string{"type": "string", "description": "Meeting date in YYYY-MM-DD format"},
						"time":         map[string]string{"type": "string", "description": "Meeting time in HH:MM format (24-hour)"},
						"duration":     map[string]string{"type": "string", "description": "Meeting duration in minutes (default: 60 for financial consultations)"},
						"title":        map[string]string{"type": "string", "description": "Meeting title/subject"},
						"meeting_type": map[string]string{"type": "string", "description": "Type of meeting: debt-consultation, financial-planning, follow-up"},
					},
					Required: []string{"date", "time"},
				},
			},
		},
		{
			Type: "endCall",
		},
	}

	// Configure voice
	assistant.Voice.Provider = "11labs"
	assistant.Voice.VoiceID = "pNInz6obpgDQGcFmaJgB" // Adam - deep male voice

	return assistant
}

func handleWebhook(c *gin.Context) {
	// Log the webhook request details
	log.Printf("🌐 Webhook received at: %s%s", c.Request.Host, c.Request.URL.Path)
	log.Printf("📮 Request method: %s", c.Request.Method)
	
	// First, let's see the raw body
	body, _ := c.GetRawData()
	// Truncate very long bodies for logging
	bodyStr := string(body)
	if len(bodyStr) > 1000 {
		bodyStr = bodyStr[:1000] + "... (truncated)"
	}
	log.Printf("🔍 Raw webhook body: %s", bodyStr)
	
	// Parse as raw JSON to access all data
	var rawData map[string]interface{}
	if err := json.Unmarshal(body, &rawData); err != nil {
		log.Printf("❌ Error parsing webhook JSON: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON"})
		return
	}

	// Extract call information - check multiple locations
	var callInfo CallInfo
	var controlURL string
	
	// 1. Check rawData["call"]
	if call, ok := rawData["call"].(map[string]interface{}); ok {
		log.Printf("🔍 Found call object in rawData with keys: %v", getKeys(call))
		if id, ok := call["id"].(string); ok {
			callInfo.ID = id
			log.Printf("📱 Call ID from rawData.call: %s", id)
		}
		if status, ok := call["status"].(string); ok {
			callInfo.Status = status
			log.Printf("📊 Call status from call object: %s", status)
		}
		
		// Check for monitor object with controlUrl
		if monitor, ok := call["monitor"].(map[string]interface{}); ok {
			log.Printf("🔍 Found monitor object with keys: %v", getKeys(monitor))
			log.Printf("🔍 Monitor object content: %+v", monitor)
			// Try different field names for control URL
			if url, ok := monitor["controlUrl"].(string); ok {
				controlURL = url
				log.Printf("🎛️ Control URL from call.monitor: %s", url)
			} else if url, ok := monitor["control_url"].(string); ok {
				controlURL = url
				log.Printf("🎛️ Control URL (snake_case) from call.monitor: %s", url)
			} else if url, ok := monitor["webhookUrl"].(string); ok {
				controlURL = url
				log.Printf("🎛️ Webhook URL from call.monitor: %s", url)
			} else if url, ok := monitor["url"].(string); ok {
				controlURL = url
				log.Printf("🎛️ URL from call.monitor: %s", url)
			} else {
				log.Printf("⚠️ No controlUrl/control_url/webhookUrl/url found in monitor object")
			}
		} else {
			log.Printf("⚠️ No monitor object found in call")
		}
	}
	
	// 2. Check message.call
	if message, ok := rawData["message"].(map[string]interface{}); ok {
		if call, ok := message["call"].(map[string]interface{}); ok {
			log.Printf("🔍 Found call object in message with keys: %v", getKeys(call))
			if id, ok := call["id"].(string); ok && callInfo.ID == "" {
				callInfo.ID = id
				log.Printf("📱 Call ID from message.call: %s", id)
			}
			
			// Check for monitor object with controlUrl in message.call too
			if monitor, ok := call["monitor"].(map[string]interface{}); ok {
				log.Printf("🔍 Found monitor in message.call with keys: %v", getKeys(monitor))
				log.Printf("🔍 Monitor content in message.call: %+v", monitor)
				// Try different field names for control URL
				if url, ok := monitor["controlUrl"].(string); ok && controlURL == "" {
					controlURL = url
					log.Printf("🎛️ Control URL from message.call.monitor: %s", url)
				} else if url, ok := monitor["control_url"].(string); ok && controlURL == "" {
					controlURL = url
					log.Printf("🎛️ Control URL (snake_case) from message.call.monitor: %s", url)
				} else if url, ok := monitor["webhookUrl"].(string); ok && controlURL == "" {
					controlURL = url
					log.Printf("🎛️ Webhook URL from message.call.monitor: %s", url)
				} else if url, ok := monitor["url"].(string); ok && controlURL == "" {
					controlURL = url
					log.Printf("🎛️ URL from message.call.monitor: %s", url)
				} else {
					log.Printf("⚠️ No controlUrl/control_url/webhookUrl/url found in message.call.monitor")
				}
			} else {
				log.Printf("⚠️ No monitor object found in message.call")
			}
		}
	}
	
	// 3. Check if call ID is directly in message
	if message, ok := rawData["message"].(map[string]interface{}); ok {
		if id, ok := message["callId"].(string); ok && callInfo.ID == "" {
			callInfo.ID = id
			log.Printf("📱 Call ID from message.callId: %s", id)
		}
		if id, ok := message["id"].(string); ok && callInfo.ID == "" {
			callInfo.ID = id
			log.Printf("📱 Call ID from message.id: %s", id)
		}
	}
	
	// 4. Check top level callId
	if id, ok := rawData["callId"].(string); ok && callInfo.ID == "" {
		callInfo.ID = id
		log.Printf("📱 Call ID from rawData.callId: %s", id)
	}
	
	// 5. Check top level id
	if id, ok := rawData["id"].(string); ok && callInfo.ID == "" {
		callInfo.ID = id
		log.Printf("📱 Call ID from rawData.id: %s", id)
	}

	log.Printf("📞 Received webhook for call: %s", callInfo.ID)
	
	// Debug: Print all top-level keys
	log.Printf("🔑 Webhook keys: %v", getKeys(rawData))
	
	// Check message type first
	if msgType, ok := rawData["message"].(map[string]interface{})["type"].(string); ok {
		log.Printf("📨 Message type: %s", msgType)
	}
	
	// Check for webhook type - this is CRITICAL for understanding what Vapi is sending
	if topType, ok := rawData["type"].(string); ok {
		log.Printf("🚨 WEBHOOK TYPE: %s", topType)
		
		// If this is a function-call or tool-calls at the top level, handle it directly
		if topType == "function-call" || topType == "tool-calls" {
			log.Printf("🎯 Top-level function/tool call detected!")
			// The actual function call data might be at the top level
			if toolCallList, ok := rawData["toolCallList"].([]interface{}); ok {
				log.Printf("🛠️ Found top-level toolCallList with %d calls", len(toolCallList))
				// Process tool calls...
			}
		}
	}
	
	// Check if this is a function call in the message
	if message, ok := rawData["message"].(map[string]interface{}); ok {
		log.Printf("💬 Found message object with keys: %v", getKeys(message))
		
		// Check if this is a post-call webhook (has endedAt field)
		if _, hasEndedAt := message["endedAt"]; hasEndedAt {
			log.Printf("📍 This is a post-call summary webhook (call already ended)")
			callInfo.Status = "ended"
		}
		
		// Handle real-time function calls
		if msgType, ok := message["type"].(string); ok {
			log.Printf("📬 Processing message type: %s", msgType)
			switch msgType {
			case "function-call", "tool-calls":
				log.Printf("🎯 Real-time function/tool call detected: %s", msgType)
				
				// Check for toolCallList (new format from docs)
				if toolCallList, ok := message["toolCallList"].([]interface{}); ok && len(toolCallList) > 0 {
					log.Printf("🛠️ REAL-TIME: Found toolCallList with %d calls", len(toolCallList))
					
					for i, toolCallInterface := range toolCallList {
						if toolCall, ok := toolCallInterface.(map[string]interface{}); ok {
							log.Printf("📞 Real-time tool call %d: %v", i, getKeys(toolCall))
							
							if name, ok := toolCall["name"].(string); ok {
								log.Printf("🎯 REAL-TIME Tool name: %s", name)
								
								if name == "end_call" {
									log.Printf("🚨 REAL-TIME END_CALL DETECTED - Terminating call immediately!")
									
									// Extract arguments
									var args map[string]interface{}
									if argsInterface, ok := toolCall["arguments"]; ok {
										if argsMap, ok := argsInterface.(map[string]interface{}); ok {
											args = argsMap
										} else if argsStr, ok := argsInterface.(string); ok {
											// Parse JSON string
											json.Unmarshal([]byte(argsStr), &args)
										}
									}
									
									// Immediately terminate the call
									handleEndCallFromMap(args, callInfo, controlURL)
									
									// Send simple response back to Vapi (Functions API format)
									c.JSON(http.StatusOK, gin.H{"result": "Call terminated successfully"})
									return
								} else if name == "capture_client" {
									handleClientCaptureFromMessage(toolCall, callInfo)
									c.JSON(http.StatusOK, gin.H{"result": "Client information captured successfully"})
									return
								} else if name == "schedule_meeting" {
									handleScheduleMeetingFromMessage(toolCall, callInfo)
									c.JSON(http.StatusOK, gin.H{"result": "Meeting scheduled successfully"})
									return
								} else {
									// Handle other tool calls
									c.JSON(http.StatusOK, gin.H{"result": "Function executed successfully"})
									return
								}
							}
						}
					}
				}
				
				// Fallback: Check for functionCall (old format)
				if functionCall, ok := message["functionCall"].(map[string]interface{}); ok {
					log.Printf("⚡ Function call details (old format): %v", getKeys(functionCall))
					if name, ok := functionCall["name"].(string); ok {
						log.Printf("🎯 Function name: %s", name)
						if name == "end_call" {
							log.Printf("🚨 REAL-TIME END_CALL DETECTED (old format)!")
							handleEndCallFromMessage(functionCall, callInfo, controlURL)
							// Use consistent response format
							c.JSON(http.StatusOK, gin.H{"result": "Call terminated successfully"})
							return
						} else if name == "capture_client" {
							handleClientCaptureFromMessage(functionCall, callInfo)
							c.JSON(http.StatusOK, gin.H{"result": "Client information captured successfully"})
							return
						} else if name == "schedule_meeting" {
							handleScheduleMeetingFromMessage(functionCall, callInfo)
							c.JSON(http.StatusOK, gin.H{"result": "Meeting scheduled successfully"})
							return
						}
					}
				}
			case "status-update":
				if status, ok := message["status"].(string); ok {
					log.Printf("📊 Call status update: %s", status)
				}
			case "transcript":
				log.Printf("📝 Transcript update received")
			case "hang":
				log.Printf("⏸️ Hang notification received")
			case "end-of-call-report":
				log.Printf("📊 End of call report received")
			default:
				log.Printf("❓ Unknown message type: %s", msgType)
			}
		}
		
		// Check for function calls in toolCalls
		if toolCalls, ok := message["toolCalls"].([]interface{}); ok && len(toolCalls) > 0 {
			log.Printf("🛠️ Found %d tool calls", len(toolCalls))
			if handleToolCalls(toolCalls, callInfo, controlURL, c) {
				return
			}
		} else {
			log.Printf("🚫 No toolCalls found in message")
		}
		
		// Check for function calls in messages array
		if messages, ok := message["messages"].([]interface{}); ok && len(messages) > 0 {
			log.Printf("📝 Found %d messages, checking for function calls", len(messages))
			if handleMessagesArray(messages, callInfo, controlURL, c) {
				return
			}
		}
		
		// Check for function calls in messagesOpenAIFormatted array  
		if messagesFormatted, ok := message["messagesOpenAIFormatted"].([]interface{}); ok && len(messagesFormatted) > 0 {
			log.Printf("🤖 Found %d formatted messages, checking for function calls", len(messagesFormatted))
			if handleMessagesArray(messagesFormatted, callInfo, controlURL, c) {
				return
			}
		}
	} else {
		log.Printf("🚫 No message object found")
	}
	
	// If no function calls found, just log and respond
	if eventType, ok := rawData["type"].(string); ok {
		log.Printf("📝 Event type: %s (no function calls)", eventType)
	}

	c.JSON(http.StatusOK, gin.H{"received": true})
}

func getKeys(m map[string]interface{}) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	return keys
}

func handleToolCalls(toolCalls []interface{}, callInfo CallInfo, controlURL string, c *gin.Context) bool {
	for i, toolCallInterface := range toolCalls {
		if toolCall, ok := toolCallInterface.(map[string]interface{}); ok {
			log.Printf("🔧 Tool call %d keys: %v", i, getKeys(toolCall))
			
			// Check for function object structure
			if function, ok := toolCall["function"].(map[string]interface{}); ok {
				log.Printf("⚡ Function object keys: %v", getKeys(function))
				if name, ok := function["name"].(string); ok {
					log.Printf("🎯 Function call detected: %s", name)
					
					if name == "end_call" {
						log.Printf("🚨 REAL-TIME END_CALL DETECTED!")
						handleEndCallFromMessage(function, callInfo, controlURL)
						c.JSON(http.StatusOK, gin.H{"result": "Call ended successfully"})
						return true
					} else if name == "capture_client" {
						handleClientCaptureFromMessage(function, callInfo)
						c.JSON(http.StatusOK, gin.H{"result": "Client information captured successfully"})
						return true
					} else if name == "schedule_meeting" {
						handleScheduleMeetingFromMessage(function, callInfo)
						c.JSON(http.StatusOK, gin.H{"result": "Meeting scheduled successfully"})
						return true
					} else if name == "make_external_call" {
						handleExternalCallFromMessage(function, callInfo)
						c.JSON(http.StatusOK, gin.H{"result": "Call initiated successfully"})
						return true
					}
				}
			}
			
			// Also check for direct name (fallback)
			if name, ok := toolCall["name"].(string); ok {
				log.Printf("🎯 Direct function call detected: %s", name)
				
				if name == "end_call" {
					log.Printf("🚨 REAL-TIME END_CALL DETECTED!")
					handleEndCallFromMessage(toolCall, callInfo, controlURL)
					c.JSON(http.StatusOK, gin.H{"result": "Call ended successfully"})
					return true
				} else if name == "capture_client" {
					handleClientCaptureFromMessage(toolCall, callInfo)
					c.JSON(http.StatusOK, gin.H{"result": "Client information captured successfully"})
					return true
				} else if name == "schedule_meeting" {
					handleScheduleMeetingFromMessage(toolCall, callInfo)
					c.JSON(http.StatusOK, gin.H{"result": "Meeting scheduled successfully"})
					return true
				} else if name == "make_external_call" {
					handleExternalCallFromMessage(toolCall, callInfo)
					c.JSON(http.StatusOK, gin.H{"result": "Call initiated successfully"})
					return true
				}
			}
		}
	}
	
	// If we get here, no function calls were processed
	c.JSON(http.StatusOK, gin.H{"received": true})
	return false
}

func handleMessagesArray(messages []interface{}, callInfo CallInfo, controlURL string, c *gin.Context) bool {
	processedAny := false
	for i, msgInterface := range messages {
		if msg, ok := msgInterface.(map[string]interface{}); ok {
			log.Printf("📄 Message %d keys: %v", i, getKeys(msg))
			
			// Check if this message has tool_calls (snake_case)
			if toolCalls, ok := msg["tool_calls"].([]interface{}); ok && len(toolCalls) > 0 {
				log.Printf("🛠️ Found %d tool_calls in message %d", len(toolCalls), i)
				if handleToolCalls(toolCalls, callInfo, controlURL, c) {
					processedAny = true
				}
			}
			
			// Check if this message has toolCalls (camelCase) 
			if toolCalls, ok := msg["toolCalls"].([]interface{}); ok && len(toolCalls) > 0 {
				log.Printf("🛠️ Found %d toolCalls in message %d", len(toolCalls), i)
				if handleToolCalls(toolCalls, callInfo, controlURL, c) {
					processedAny = true
				}
			}
			
			// Check if this message has function_call
			if functionCall, ok := msg["function_call"].(map[string]interface{}); ok {
				log.Printf("⚡ Found function_call in message %d: %v", i, getKeys(functionCall))
				if name, ok := functionCall["name"].(string); ok {
					log.Printf("🎯 Function call detected: %s", name)
					if name == "capture_client" {
						handleClientCaptureFromMessage(functionCall, callInfo)
					} else if name == "end_call" {
						handleEndCallFromMessage(functionCall, callInfo, controlURL)
					} else if name == "make_external_call" {
						handleExternalCallFromMessage(functionCall, callInfo)
					} else if name == "schedule_meeting" {
						handleScheduleMeetingFromMessage(functionCall, callInfo)
					}
					processedAny = true
				}
			}
		}
	}
	
	// Send response only after processing ALL messages
	if processedAny {
		c.JSON(http.StatusOK, gin.H{"received": true})
	}
	return processedAny
}

func handleClientCaptureFromMessage(toolCall map[string]interface{}, callInfo CallInfo) {
	var args map[string]interface{}
	
	// Check for arguments as JSON string
	if argsStr, ok := toolCall["arguments"].(string); ok {
		var parsedArgs map[string]interface{}
		if err := json.Unmarshal([]byte(argsStr), &parsedArgs); err == nil {
			args = parsedArgs
		}
	}
	// Fallback: check for direct parameters
	if parameters, ok := toolCall["parameters"].(map[string]interface{}); ok {
		args = parameters
	}
	
	client := Client{
		ID:        generateClientID(),
		CallID:    callInfo.ID,
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

	// Store client
	clients = append(clients, client)

	log.Printf("Client captured: %s - Total Debt: $%.2f, DTI: %.1f%%", client.Name, client.TotalDebt, debtToIncome)
}

func handleEndCallFromMap(args map[string]interface{}, callInfo CallInfo, controlURL string) {
	reason := ""
	if r, ok := args["reason"].(string); ok {
		reason = r
	}
	
	log.Printf("🎯 SUCCESS! Jeff called end_call function. Reason: %s", reason)
	
	// Check if call is already ended (post-call webhook)
	if callInfo.Status == "ended" || callInfo.Status == "" {
		log.Printf("📞 Call %s has already ended (this is a post-call summary webhook)", callInfo.ID)
		return
	}
	
	log.Printf("🚀 Now terminating call %s via Vapi API...", callInfo.ID)
	
	// Terminate the call using Vapi's API
	if err := terminateCall(callInfo.ID, controlURL); err != nil {
		log.Printf("❌ Failed to terminate call: %v", err)
	} else {
		log.Printf("✅ Call %s terminated successfully!", callInfo.ID)
	}
}

func handleEndCallFromMessage(toolCall map[string]interface{}, callInfo CallInfo, controlURL string) {
	var args map[string]interface{}
	
	// Check for arguments as JSON string
	if argsStr, ok := toolCall["arguments"].(string); ok {
		var parsedArgs map[string]interface{}
		if err := json.Unmarshal([]byte(argsStr), &parsedArgs); err == nil {
			args = parsedArgs
		}
	}
	// Fallback: check for direct parameters
	if parameters, ok := toolCall["parameters"].(map[string]interface{}); ok {
		args = parameters
	}
	
	handleEndCallFromMap(args, callInfo, controlURL)
}

func handleExternalCallFromMessage(toolCall map[string]interface{}, callInfo CallInfo) {
	var args map[string]interface{}
	
	// Check for arguments as JSON string
	if argsStr, ok := toolCall["arguments"].(string); ok {
		var parsedArgs map[string]interface{}
		if err := json.Unmarshal([]byte(argsStr), &parsedArgs); err == nil {
			args = parsedArgs
		}
	}
	// Fallback: check for direct parameters
	if parameters, ok := toolCall["parameters"].(map[string]interface{}); ok {
		args = parameters
	}
	
	phoneNumber := ""
	purpose := ""
	message := ""
	
	if phone, ok := args["phone_number"].(string); ok {
		phoneNumber = phone
	}
	if p, ok := args["purpose"].(string); ok {
		purpose = p
	}
	if m, ok := args["message"].(string); ok {
		message = m
	}
	
	log.Printf("📞 SUCCESS! Jeff requested external call to %s for purpose: %s", phoneNumber, purpose)
	log.Printf("🎯 Call message: %s", message)
	log.Printf("🚀 Now creating outbound call via Vapi API...")
	
	// Create outbound call using Vapi's API
	if err := createOutboundCall(phoneNumber, purpose, message, callInfo.ID); err != nil {
		log.Printf("❌ Failed to create outbound call: %v", err)
	} else {
		log.Printf("✅ Outbound call to %s initiated successfully!", phoneNumber)
	}
}

func handleScheduleMeetingFromMessage(toolCall map[string]interface{}, callInfo CallInfo) {
	var args map[string]interface{}
	
	// Check for arguments as JSON string
	if argsStr, ok := toolCall["arguments"].(string); ok {
		var parsedArgs map[string]interface{}
		if err := json.Unmarshal([]byte(argsStr), &parsedArgs); err == nil {
			args = parsedArgs
		}
	}
	// Fallback: check for direct parameters
	if parameters, ok := toolCall["parameters"].(map[string]interface{}); ok {
		args = parameters
	}
	
	// Extract meeting details
	date := ""
	timeStr := ""
	duration := "60" // default 60 minutes for financial consultations
	title := "Financial Planning Consultation"
	meetingType := "debt-consultation"
	
	if d, ok := args["date"].(string); ok {
		date = d
	}
	if t, ok := args["time"].(string); ok {
		timeStr = t
	}
	if dur, ok := args["duration"].(string); ok {
		duration = dur
	}
	if tit, ok := args["title"].(string); ok {
		title = tit
	}
	if mt, ok := args["meeting_type"].(string); ok {
		meetingType = mt
	}
	
	log.Printf("📅 SUCCESS! Jeff scheduled a meeting: %s on %s at %s", title, date, timeStr)
	
	// Find the client for this call
	var client *Client
	for i := range clients {
		if clients[i].CallID == callInfo.ID {
			client = &clients[i]
			break
		}
	}
	
	if client == nil {
		log.Printf("⚠️ No client found for call %s, creating placeholder", callInfo.ID)
		// Create a placeholder client if we don't have one
		client = &Client{
			ID:        generateClientID(),
			CallID:    callInfo.ID,
			Name:      "Guest",
			Email:     "", // Will need to be filled
			Status:    "scheduled",
			CreatedAt: time.Now(),
		}
		clients = append(clients, *client)
	}
	
	// Parse meeting time
	meetingTime := time.Now().Add(24 * time.Hour) // Default to tomorrow
	if date != "" && timeStr != "" {
		// Parse the date and time
		parsedTime, err := time.Parse("2006-01-02 15:04", date+" "+timeStr)
		if err != nil {
			log.Printf("❌ Failed to parse meeting time: %v", err)
		} else {
			// Validate that the meeting is in the future
			if parsedTime.Before(time.Now()) {
				log.Printf("⚠️ Meeting date %s is in the past! Adjusting to tomorrow at same time", date)
				// Extract just the time and add it to tomorrow
				hour, minute, _ := parsedTime.Clock()
				tomorrow := time.Now().Add(24 * time.Hour)
				meetingTime = time.Date(tomorrow.Year(), tomorrow.Month(), tomorrow.Day(), hour, minute, 0, 0, tomorrow.Location())
				log.Printf("📅 Adjusted meeting time to: %s", meetingTime.Format("2006-01-02 15:04"))
			} else {
				meetingTime = parsedTime
			}
		}
	}
	
	// Parse duration
	durationMin := 60
	if d, err := time.ParseDuration(duration + "m"); err == nil {
		durationMin = int(d.Minutes())
	}
	
	// Create meeting invite
	meetingLink := os.Getenv("DEFAULT_MEETING_LINK")
	if meetingLink == "" {
		meetingLink = "https://meet.google.com/abc-defg-hij" // Fallback default
	}
	
	meeting := MeetingInvite{
		LeadEmail:    client.Email,
		LeadName:     client.Name,
		MeetingTitle: title,
		Description: fmt.Sprintf(
			"Meeting Type: %s\n\n"+
			"Hi %s,\n\n"+
			"Thank you for scheduling this financial consultation with me. "+
			"During our meeting, we'll review your current debt situation, "+
			"discuss strategies to reduce your credit card debt, and create "+
			"a personalized plan to help you achieve financial freedom.\n\n"+
			"Please have your recent credit card statements and monthly budget "+
			"information available for our discussion.\n\n"+
			"Looking forward to helping you take control of your finances!\n\n"+
			"Best regards,\nJeff\nPersonal Finance Advisor",
			meetingType, client.Name),
		StartTime:   meetingTime,
		EndTime:     meetingTime.Add(time.Duration(durationMin) * time.Minute),
		Location:    "Online Meeting",
		MeetingLink: meetingLink,
	}
	
	// Send the invite if we have an email
	if client.Email != "" {
		if err := SendMeetingInvite(*client, meeting); err != nil {
			log.Printf("❌ Failed to send meeting invite: %v", err)
		} else {
			log.Printf("✅ Meeting invite sent to %s", client.Email)
		}
	} else {
		log.Printf("⚠️ No email address for client, meeting scheduled but invite not sent")
		log.Printf("📧 Meeting details saved for when email is captured")
	}
	
	// Update client status
	client.Status = "scheduled"
	log.Printf("📊 Client status updated to: scheduled")
}

func terminateCall(callID string, controlURL string) error {
	log.Printf("🚨 TERMINATING CALL: %s", callID)
	
	apiKey := os.Getenv("VAPI_PRIVATE_KEY")
	if apiKey == "" {
		return fmt.Errorf("VAPI_PRIVATE_KEY not set")
	}
	
	// Primary method: Use Vapi's call termination API
	url := fmt.Sprintf("https://api.vapi.ai/call/%s/end", callID)
	
	log.Printf("🎛️ Terminating call via Vapi API: %s", url)
	
	// Create the POST request to end the call
	req, err := http.NewRequest("POST", url, nil)
	if err != nil {
		return fmt.Errorf("failed to create termination request: %v", err)
	}
	
	req.Header.Set("Authorization", "Bearer "+apiKey)
	req.Header.Set("Content-Type", "application/json")
	
	// Make the request
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		log.Printf("❌ Primary termination method failed: %v", err)
	} else {
		defer resp.Body.Close()
		body, _ := io.ReadAll(resp.Body)
		
		if resp.StatusCode == http.StatusOK || resp.StatusCode == http.StatusCreated || resp.StatusCode == http.StatusNoContent {
			log.Printf("✅ Call terminated successfully via Vapi API: %s", callID)
			return nil
		} else {
			log.Printf("⚠️ Primary termination failed with status %d: %s", resp.StatusCode, string(body))
		}
	}
	
	// Fallback 1: Use Live Call Control if available
	if controlURL != "" {
		log.Printf("🎛️ Fallback: Using Live Call Control to end call via: %s", controlURL)
		
		// Create the control message to end the call
		controlData := map[string]interface{}{
			"type": "end-call",
		}
		
		jsonData, err := json.Marshal(controlData)
		if err != nil {
			log.Printf("❌ Failed to marshal control data: %v", err)
		} else {
			// Create the POST request to the control URL
			req, err := http.NewRequest("POST", controlURL, bytes.NewBuffer(jsonData))
			if err != nil {
				log.Printf("❌ Failed to create control request: %v", err)
			} else {
				req.Header.Set("Content-Type", "application/json")
				
				// Make the request
				client := &http.Client{Timeout: 10 * time.Second}
				resp, err := client.Do(req)
				if err != nil {
					log.Printf("❌ Control API request failed: %v", err)
				} else {
					defer resp.Body.Close()
					body, _ := io.ReadAll(resp.Body)
					
					if resp.StatusCode == http.StatusOK || resp.StatusCode == http.StatusCreated || resp.StatusCode == http.StatusNoContent {
						log.Printf("✅ Call terminated successfully via Live Call Control: %s", callID)
						return nil
					} else {
						log.Printf("⚠️ Control API failed with status %d: %s", resp.StatusCode, string(body))
					}
				}
			}
		}
	}
	
	// Fallback 2: Try PATCH with status update
	log.Printf("🔄 Final fallback: Attempting status update...")
	url = fmt.Sprintf("https://api.vapi.ai/call/%s", callID)
	
	endCallData := map[string]interface{}{
		"status": "ended",
	}
	
	jsonData, err := json.Marshal(endCallData)
	if err != nil {
		return fmt.Errorf("failed to marshal end call data: %v", err)
	}
	
	req, err = http.NewRequest("PATCH", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return fmt.Errorf("failed to create PATCH request: %v", err)
	}
	
	req.Header.Set("Authorization", "Bearer "+apiKey)
	req.Header.Set("Content-Type", "application/json")
	
	resp, err = client.Do(req)
	if err != nil {
		return fmt.Errorf("PATCH request failed: %v", err)
	}
	defer resp.Body.Close()
	
	body, _ := io.ReadAll(resp.Body)
	
	if resp.StatusCode == http.StatusOK || resp.StatusCode == http.StatusCreated || resp.StatusCode == http.StatusNoContent {
		log.Printf("✅ Call terminated via status update: %s", callID)
		return nil
	}
	
	return fmt.Errorf("all termination methods failed. Last response: %d - %s", resp.StatusCode, string(body))
}

func createOutboundCall(phoneNumber, purpose, message, originCallID string) error {
	apiKey := os.Getenv("VAPI_PRIVATE_KEY")
	if apiKey == "" {
		return fmt.Errorf("VAPI_PRIVATE_KEY not set")
	}
	
	// Create the outbound call request
	outboundCallData := map[string]interface{}{
		"phoneNumberId": os.Getenv("VAPI_PHONE_NUMBER_ID"), // You'll need to set this
		"customer": map[string]interface{}{
			"number": phoneNumber,
		},
		"assistantId": os.Getenv("VAPI_ASSISTANT_ID"), // You'll need to set this
		// Enable recording and monitoring for the call
		"assistantOverrides": map[string]interface{}{
			"recordingEnabled": true,
			"monitorPlan": map[string]interface{}{
				"listenEnabled":  true,
				"controlEnabled": true,
			},
			"firstMessage": fmt.Sprintf("Hi! This is Jeff from our previous conversation. I'm calling about %s. %s", purpose, message),
		},
		// Add metadata to track this call
		"metadata": map[string]interface{}{
			"purpose":        purpose,
			"originCallId":   originCallID,
			"externalCall":   true,
			"requestedBy":    "ai_assistant",
		},
	}
	
	jsonData, err := json.Marshal(outboundCallData)
	if err != nil {
		return fmt.Errorf("failed to marshal outbound call data: %v", err)
	}
	
	// Create the POST request to Vapi's calls endpoint
	req, err := http.NewRequest("POST", "https://api.vapi.ai/call", bytes.NewBuffer(jsonData))
	if err != nil {
		return fmt.Errorf("failed to create outbound call request: %v", err)
	}
	
	req.Header.Set("Authorization", "Bearer "+apiKey)
	req.Header.Set("Content-Type", "application/json")
	
	// Make the request
	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("failed to make outbound call request: %v", err)
	}
	defer resp.Body.Close()
	
	// Read response body
	body, _ := io.ReadAll(resp.Body)
	
	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		return fmt.Errorf("outbound call API request failed with status %d: %s", resp.StatusCode, string(body))
	}
	
	// Parse the response to get call ID
	var callResponse map[string]interface{}
	if err := json.Unmarshal(body, &callResponse); err == nil {
		if callID, ok := callResponse["id"].(string); ok {
			log.Printf("✅ Outbound call created with ID: %s", callID)
			log.Printf("🎧 Call will be recorded and can be monitored via Vapi dashboard")
			
			// Log monitoring information
			if monitorURL, ok := callResponse["monitorUrl"].(string); ok {
				log.Printf("🔍 Monitor call at: %s", monitorURL)
			}
		}
	}
	
	log.Printf("📞 Outbound call response: %s", string(body))
	return nil
}



func generateClientID() string {
	return "client_" + time.Now().Format("20060102150405")
}

func getServerURL() string {
	url := os.Getenv("SERVER_URL")
	log.Printf("SERVER_URL from env: %s", url)
	if url != "" {
		return url
	}
	return "https://vapi-customer-service.onrender.com"
} 