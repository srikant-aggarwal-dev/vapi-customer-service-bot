package main

// createLeadGenAssistantMCP creates an assistant configuration that uses MCP
func createLeadGenAssistantMCP() VapiAssistant {
	assistant := VapiAssistant{
		FirstMessage: "Hi there! I'm Alex, an AI assistant helping businesses streamline their operations. I'd love to learn about your company and see if we might be able to help. Do you have a few minutes to chat?",
		Server: struct {
			URL      string   `json:"url"`
			Secret   string   `json:"secret,omitempty"`
		}{
			URL:    "https://5d4b-70-50-65-123.ngrok-free.app/webhook",
			Secret: "vapi-webhook-secret-2024",
		},
		ServerMessages: []string{
			"tool-calls",
			"function-call",
			"status-update",
			"transcript",
			"hang",
			"end-of-call-report",
			"conversation-update",
		},
		EndCallMessage:             "Thank you so much for your time! I'll have someone from our team reach out to you soon. Have a great day!",
		MaxDurationSeconds:         1800, // 30 minutes
		SilenceTimeoutSeconds:      300,  // 5 minutes
		BackgroundDenoisingEnabled: true,
		MonitorPlan: struct {
			ListenEnabled  bool `json:"listenEnabled"`
			ControlEnabled bool `json:"controlEnabled"`
		}{
			ListenEnabled:  false,
			ControlEnabled: true,
		},
	}

	// Configure the AI model
	assistant.Model.Provider = "openai"
	assistant.Model.Model = "gpt-4"
	assistant.Model.Messages = []struct {
		Role    string `json:"role"`
		Content string `json:"content"`
	}{
		{
			Role: "system",
			Content: `You are Alex, a friendly AI lead generation specialist. Your goal is to:

1. BUILD RAPPORT: Start conversations warmly and establish trust
2. QUALIFY LEADS: Ask strategic questions to understand their business needs
3. CAPTURE INFORMATION: Collect contact details and business information
4. CREATE URGENCY: Highlight pain points and potential solutions

QUALIFICATION CRITERIA:
- Company size and industry
- Current challenges/pain points
- Budget range for solutions
- Decision-making timeline
- Decision-maker status

CONVERSATION FLOW:
1. Warm introduction and rapport building
2. Discover their role and company
3. Uncover pain points and challenges
4. Gauge budget and timeline
5. Qualify decision-making authority
6. Present value proposition
7. Schedule follow-up

TONE: Professional but conversational, enthusiastic about helping, consultative not pushy.

ENDING CALLS:
- When user wants to end: Say goodbye warmly and use the end_call tool
- The tools will be provided dynamically via MCP

You have access to tools that will be dynamically loaded. Use capture_lead when you have lead information and end_call when the user wants to end the conversation.`,
		},
	}

	// Instead of defining functions directly, we'll use MCP
	// The tools will be dynamically loaded from the MCP server
	assistant.Model.Functions = []Function{}

	// Configure voice
	assistant.Voice.Provider = "11labs"
	assistant.Voice.VoiceID = "21m00Tcm4TlvDq8ikWAM"

	return assistant
} 