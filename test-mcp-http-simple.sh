#!/bin/bash

echo "🧪 Testing MCP HTTP Bridge (Simple Version)..."
echo

BASE_URL="http://localhost:8080"

# Test 1: Initialize MCP session
echo "1. Initializing MCP session..."
echo "   POST $BASE_URL/mcp/initialize"
curl -X POST $BASE_URL/mcp/initialize
echo
echo

# Get session ID manually from the above response and use it below
echo "2. Copy the sessionId from above and use it in the following commands:"
echo
echo "   To list tools:"
echo "   curl -X POST $BASE_URL/mcp/request -H \"Content-Type: application/json\" -d '{\"sessionId\": \"YOUR_SESSION_ID\", \"method\": \"tools/list\", \"id\": 1}'"
echo
echo "   To capture a lead:"
echo "   curl -X POST $BASE_URL/mcp/request -H \"Content-Type: application/json\" -d '{\"sessionId\": \"YOUR_SESSION_ID\", \"method\": \"tools/call\", \"params\": {\"name\": \"capture_lead\", \"arguments\": {\"name\": \"Test User\", \"email\": \"test@example.com\", \"status\": \"qualified\"}}, \"id\": 2}'"
echo
echo "   To close session:"
echo "   curl -X DELETE $BASE_URL/mcp/session/YOUR_SESSION_ID"
echo

echo "💡 Once this works locally, you can use your ngrok URL instead:"
echo "   https://YOUR-NGROK-URL.ngrok-free.app/mcp" 