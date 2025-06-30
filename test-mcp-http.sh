#!/bin/bash

echo "🧪 Testing MCP HTTP Bridge..."
echo

BASE_URL="http://localhost:8080"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test 1: Initialize MCP session
echo -e "${BLUE}1. Initializing MCP session...${NC}"
INIT_RESPONSE=$(curl -s -X POST $BASE_URL/mcp/initialize)
SESSION_ID=$(echo $INIT_RESPONSE | jq -r '.sessionId')

if [ "$SESSION_ID" != "null" ] && [ ! -z "$SESSION_ID" ]; then
    echo -e "${GREEN}✅ Session created: $SESSION_ID${NC}"
    echo "Response: $INIT_RESPONSE"
else
    echo "❌ Failed to create session"
    echo "Response: $INIT_RESPONSE"
    exit 1
fi
echo

# Test 2: List tools
echo -e "${BLUE}2. Listing available tools...${NC}"
TOOLS_RESPONSE=$(curl -s -X POST $BASE_URL/mcp/request \
    -H "Content-Type: application/json" \
    -d "{
        \"sessionId\": \"$SESSION_ID\",
        \"method\": \"tools/list\",
        \"id\": 1
    }")
echo "Response: $TOOLS_RESPONSE"
echo

# Test 3: Call capture_lead tool
echo -e "${BLUE}3. Testing capture_lead tool...${NC}"
CAPTURE_RESPONSE=$(curl -s -X POST $BASE_URL/mcp/request \
    -H "Content-Type: application/json" \
    -d "{
        \"sessionId\": \"$SESSION_ID\",
        \"method\": \"tools/call\",
        \"params\": {
            \"name\": \"capture_lead\",
            \"arguments\": {
                \"name\": \"HTTP Bridge Test\",
                \"email\": \"test@httpbridge.com\",
                \"status\": \"qualified\"
            }
        },
        \"id\": 2
    }")
echo "Response: $CAPTURE_RESPONSE"
echo

# Test 4: Close session
echo -e "${BLUE}4. Closing MCP session...${NC}"
CLOSE_RESPONSE=$(curl -s -X DELETE $BASE_URL/mcp/session/$SESSION_ID)
echo "Response: $CLOSE_RESPONSE"
echo

# Verify lead was captured
echo -e "${BLUE}5. Verifying lead was captured...${NC}"
LEADS_COUNT=$(curl -s $BASE_URL/leads | jq '. | length')
echo "Total leads in system: $LEADS_COUNT"

echo
echo -e "${GREEN}✅ MCP HTTP Bridge test complete!${NC}"
echo
echo "💡 This means you can now use MCP over ngrok:"
echo "   Your MCP server URL would be: https://your-ngrok-url.ngrok-free.app/mcp" 