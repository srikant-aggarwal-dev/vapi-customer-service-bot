# VapiLead AI - Lead Generation Voice Agent

A complete AI-powered lead generation and qualification system using [Vapi](https://vapi.ai) for voice interactions, with a Go backend server and Next.js frontend.

## 🎯 What This Does

**Alex**, your AI lead generation assistant, can:

- 📞 **Conduct natural voice conversations** with prospects
- 🔍 **Qualify leads** by asking strategic questions about budget, timeline, and needs
- 📊 **Score leads automatically** based on qualification criteria
- 💾 **Capture contact information** and business details
- 📈 **Track lead status** (qualified, unqualified, follow-up)
- 🎯 **Present opportunities** and schedule follow-ups

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Next.js Web   │───▶│   Go Server     │───▶│   Vapi AI       │
│   Dashboard     │    │   (Lead Mgmt)   │    │   (Voice Agent) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

- **Frontend**: Next.js TypeScript web app with Tailwind CSS
- **Backend**: Go server with Gin framework
- **Voice AI**: Vapi with OpenAI GPT-4 and 11Labs voice
- **Lead Storage**: In-memory (can be extended to database)

## 🚀 Quick Start

### Prerequisites

- **Go 1.19+**
- **Node.js 18+**
- **Vapi account** ([sign up here](https://vapi.ai))
- **OpenAI API key**
- **11Labs API key** (optional, for better voice)

### 1. Start the Go Server

```bash
cd server

# Install dependencies
go mod tidy

# Create environment file
cp .env.example .env
# Edit .env with your API keys

# Run server
go run main.go
```

Server runs on `http://localhost:8080`

### 2. Start the Web Client

```bash
cd client

# Install dependencies
npm install

# Run development server
npm run dev
```

Web app runs on `http://localhost:3000`

## 🔧 Configuration

### Environment Variables (.env)

```env
# Vapi Configuration
VAPI_API_KEY=your_vapi_api_key_here
VAPI_PHONE_NUMBER_ID=your_phone_number_id_here

# Server Configuration
PORT=8080
SERVER_URL=http://localhost:8080
WEBHOOK_SECRET=your-webhook-secret-key

# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# 11Labs Configuration (optional)
ELEVENLABS_API_KEY=your_elevenlabs_api_key_here
```

### Vapi Assistant Setup

The Go server automatically provides the assistant configuration at:
`GET /assistant`

Key features:

- **GPT-4 powered** conversation
- **Lead qualification prompts**
- **Function calling** for data capture
- **Professional 11Labs voice**
- **15-minute call limit**

## 📊 API Endpoints

### Server (Port 8080)

- `GET /health` - Health check
- `GET /assistant` - Vapi assistant configuration
- `POST /webhook` - Vapi webhook events
- `GET /leads` - Get all captured leads
- `GET /leads/:id` - Get specific lead

### Lead Data Structure

```json
{
  "id": "lead_20231211143022",
  "name": "John Smith",
  "email": "john@company.com",
  "phone": "+1-555-123-4567",
  "company": "Acme Corp",
  "industry": "Manufacturing",
  "budget": "$10k-50k",
  "timeline": "Q1 2024",
  "painPoints": ["inefficient processes", "high costs"],
  "score": 85,
  "status": "qualified",
  "callId": "call_abc123",
  "createdAt": "2023-12-11T14:30:22Z"
}
```

## 🎭 How Alex Works

### Conversation Flow

1. **Warm Introduction**: "Hi! I'm Alex, helping businesses streamline operations..."
2. **Discovery**: Learn about their role, company, and industry
3. **Pain Point Identification**: Uncover challenges and frustrations
4. **Qualification**: Ask about budget, timeline, decision-making
5. **Value Presentation**: Highlight relevant solutions
6. **Next Steps**: Schedule follow-up or demo

### Lead Scoring Algorithm

```go
score := 0
if lead.Email != "" { score += 20 }      // Contact info
if lead.Phone != "" { score += 15 }      // Phone contact
if lead.Company != "" { score += 10 }    // Company info
if lead.Budget != "" { score += 25 }     // Budget qualified
if lead.Timeline != "" { score += 20 }   // Timeline defined
// Max score: 90
```

## 🎨 Web Dashboard Features

### Voice Demo Tab

- **Start/End calls** with Alex
- **Real-time call status**
- **Feature explanations**
- **Lead statistics** overview

### Leads Dashboard Tab

- **Lead cards** with full details
- **Status filtering** (qualified/follow-up/unqualified)
- **Score-based sorting**
- **Contact information** display
- **Auto-refresh** every 30 seconds

## 🔗 Vapi Integration

### Assistant Configuration

The system uses Vapi's function calling feature:

```json
{
  "name": "capture_lead",
  "description": "Capture qualified lead information",
  "parameters": {
    "name": "string",
    "email": "string",
    "phone": "string",
    "company": "string",
    "budget": "string",
    "timeline": "string",
    "status": "qualified|unqualified|follow-up"
  }
}
```

### Webhook Events

The server handles these Vapi events:

- `call-start` - Call initiated
- `call-end` - Call completed
- `function-call` - Lead data captured
- `hang` - Call hung up

## 🚀 Deployment

### Production Considerations

1. **Database**: Replace in-memory storage with PostgreSQL/MySQL
2. **Authentication**: Add API key authentication
3. **Rate Limiting**: Implement call rate limits
4. **Monitoring**: Add logging and metrics
5. **HTTPS**: Use TLS certificates
6. **Environment**: Use production Vapi environment

### Example Docker Setup

```dockerfile
# Go Server
FROM golang:1.21-alpine
WORKDIR /app
COPY server/ .
RUN go build -o main
EXPOSE 8080
CMD ["./main"]

# Next.js Client
FROM node:18-alpine
WORKDIR /app
COPY client/ .
RUN npm ci && npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

## 🎯 Use Cases

- **Sales Teams**: Qualify inbound leads automatically
- **Marketing**: Score website visitors via voice chat
- **SaaS**: Qualify trial users for upgrades
- **Agencies**: Qualify potential clients
- **Real Estate**: Qualify property inquiries
- **Healthcare**: Qualify patient consultations

## 🛠️ Extending the System

### Add CRM Integration

```go
func handleLeadCapture(event WebhookEvent) {
    // ... existing code ...

    // Send to CRM
    hubspot.CreateContact(lead)
    salesforce.CreateLead(lead)
    pipedrive.CreatePerson(lead)
}
```

### Add Email Notifications

```go
func notifyNewLead(lead Lead) {
    if lead.Score > 70 {
        sendSlackAlert(lead)
        emailSalesTeam(lead)
    }
}
```

### Add Analytics

```go
type Analytics struct {
    CallsToday      int
    ConversionRate  float64
    AvgCallDuration time.Duration
    TopSources      []string
}
```

## 📋 Next Steps

1. **Get Vapi API key** from [vapi.ai](https://vapi.ai)
2. **Set up OpenAI account** for GPT-4 access
3. **Configure environment** variables
4. **Test voice calling** with the demo
5. **Customize Alex's personality** and questions
6. **Connect to your CRM** system
7. **Deploy to production**

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

MIT License - see LICENSE file for details

---

**Built with ❤️ using [Vapi](https://vapi.ai), Go, and Next.js**
