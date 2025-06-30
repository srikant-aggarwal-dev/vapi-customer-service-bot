#!/bin/bash

echo "🧪 Testing MCP Server (Simple Version)..."
echo

# Function to run MCP command and show output
run_mcp_test() {
    local test_name="$1"
    local json_input="$2"
    
    echo "📍 $test_name"
    echo "Input: $json_input"
    echo -n "Output: "
    echo "$json_input" | go run server/. mcp 2>/dev/null
    echo
}

# Test 1: Initialize
run_mcp_test "Test 1: Initialize MCP connection" \
    '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}'

# Test 2: List tools
run_mcp_test "Test 2: List available tools" \
    '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'

# Test 3: Capture lead
run_mcp_test "Test 3: Capture a lead" \
    '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"capture_lead","arguments":{"name":"Test User","email":"test@example.com","phone":"+1234567890","company":"Test Company","status":"qualified"}}}'

# Test 4: End call
run_mcp_test "Test 4: End call" \
    '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"end_call","arguments":{"reason":"User requested to end call"}}}'

echo "✅ Tests complete!"
echo
echo "💡 To use MCP with VAPI:"
echo "   1. Deploy MCP server with HTTP/SSE transport"
echo "   2. Add MCP tool in VAPI Dashboard"
echo "   3. Use the MCP server URL in VAPI configuration" 