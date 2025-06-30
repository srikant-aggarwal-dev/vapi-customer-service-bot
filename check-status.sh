#!/bin/bash

echo "🔍 VAPI Lead Gen System Status Check"
echo "===================================="
echo ""

# Check Ngrok
echo "1️⃣ NGROK STATUS:"
if curl -s http://localhost:4040 > /dev/null 2>&1; then
    echo "   ✅ Running"
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*' | grep -o '[^"]*$' | head -1)
    echo "   📡 URL: $NGROK_URL"
else
    echo "   ❌ Not Running"
    echo "   💡 Start with: ngrok http 8080"
fi
echo ""

# Check Server
echo "2️⃣ SERVER STATUS:"
if curl -s http://localhost:8080/health > /dev/null 2>&1; then
    echo "   ✅ Running on port 8080"
    HEALTH=$(curl -s http://localhost:8080/health | jq -r '.status')
    echo "   💚 Health: $HEALTH"
else
    echo "   ❌ Not Running"
    echo "   💡 Start with: cd server && go run main.go"
fi
echo ""

# Check Webhook Config
echo "3️⃣ WEBHOOK CONFIG:"
if curl -s http://localhost:8080/assistant > /dev/null 2>&1; then
    WEBHOOK_URL=$(curl -s http://localhost:8080/assistant | jq -r '.serverUrl')
    echo "   📮 Webhook URL: $WEBHOOK_URL"
    
    # Check if ngrok URL matches webhook URL
    if [ ! -z "$NGROK_URL" ] && [ ! -z "$WEBHOOK_URL" ]; then
        if [[ "$WEBHOOK_URL" == *"$NGROK_URL"* ]]; then
            echo "   ✅ Webhook URL matches Ngrok URL"
        else
            echo "   ⚠️  Webhook URL doesn't match Ngrok URL!"
            echo "   💡 Restart server after ngrok URL changes"
        fi
    fi
fi
echo ""

# Check Recent Leads
echo "4️⃣ RECENT LEADS:"
if curl -s http://localhost:8080/leads > /dev/null 2>&1; then
    LEAD_COUNT=$(curl -s http://localhost:8080/leads | jq '. | length')
    echo "   📊 Total leads captured: $LEAD_COUNT"
fi
echo ""

# Check processes
echo "5️⃣ RUNNING PROCESSES:"
if pgrep -f "ngrok" > /dev/null; then
    echo "   ✅ Ngrok process found"
else
    echo "   ❌ Ngrok process not found"
fi

if pgrep -f "go run main.go" > /dev/null; then
    echo "   ✅ Go server process found"
else
    echo "   ❌ Go server process not found"
fi
echo ""

echo "===================================="
echo "📌 Quick Commands:"
echo "   • Start ngrok: ngrok http 8080"
echo "   • Start server (HTTP): cd server && go run main.go"
echo "   • Start server (MCP): cd server && go run . mcp"
echo "   • View ngrok: http://localhost:4040"
echo "   • View leads: http://localhost:8080/leads"
echo "   • Test MCP: ./test-mcp.sh"
echo ""
echo "🔄 MCP OPTIONS:"
echo "   • Standalone MCP: cd server && go run . mcp"
echo "   • MCP via HTTP: Already running! Access at /mcp endpoints"
echo "   • Test HTTP bridge: ./test-mcp-http-simple.sh"
echo "   • With ngrok: https://YOUR-NGROK-URL/mcp"
echo "   • See MCP_SETUP_GUIDE.md for details" 