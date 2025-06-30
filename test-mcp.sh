#!/bin/bash

echo "🧪 Testing MCP Server..."
echo

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test 1: Initialize
echo -e "${BLUE}Test 1: Initialize MCP connection${NC}"
if command -v jq &> /dev/null; then
    echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' | go run server/. mcp 2>/dev/null | jq .
else
    echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' | go run server/. mcp 2>/dev/null
fi
echo

# Test 2: List tools
echo -e "${BLUE}Test 2: List available tools${NC}"
echo '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' | go run server/. mcp 2>/dev/null | jq .
echo

# Test 3: Call capture_lead tool
echo -e "${BLUE}Test 3: Test capture_lead tool${NC}"
echo '{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "name": "capture_lead",
    "arguments": {
      "name": "Test User",
      "email": "test@example.com",
      "phone": "+1234567890",
      "company": "Test Company",
      "status": "qualified"
    }
  }
}' | go run server/. mcp 2>/dev/null | jq .
echo

# Test 4: Call end_call tool
echo -e "${BLUE}Test 4: Test end_call tool${NC}"
echo '{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "tools/call",
  "params": {
    "name": "end_call",
    "arguments": {
      "reason": "User requested to end call"
    }
  }
}' | go run server/. mcp 2>/dev/null | jq .
echo

# Test 5: Test unknown method
echo -e "${BLUE}Test 5: Test error handling (unknown method)${NC}"
echo '{"jsonrpc":"2.0","id":5,"method":"unknown/method"}' | go run server/. mcp 2>/dev/null | jq .
echo

echo -e "${GREEN}✅ MCP Server tests complete!${NC}"
echo
echo "To use with VAPI:"
echo "1. Deploy your MCP server with HTTP/SSE transport support"
echo "2. Add MCP tool in VAPI Dashboard with your server URL"
echo "3. Update assistant to use the MCP tool instead of direct functions" 