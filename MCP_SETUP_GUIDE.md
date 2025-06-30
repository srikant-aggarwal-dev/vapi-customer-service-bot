# MCP Setup Guide for VAPI Lead Generation Bot

## Overview

This guide explains how to use Model Context Protocol (MCP) instead of direct webhook-based function calling in your VAPI lead generation bot.

## What is MCP?

MCP (Model Context Protocol) is an open standard that provides a unified way for AI assistants to access tools and data. Instead of hardcoding functions in your assistant configuration, MCP allows tools to be dynamically discovered and used.

## Benefits of Using MCP

1. **Standardization**: Your tools work with any MCP-compatible system
2. **Dynamic Tool Discovery**: Add/remove tools without changing VAPI configuration
3. **Better Separation**: Business logic stays in your MCP server
4. **Reusability**: Same tools can be used across different AI platforms

## Architecture

```
VAPI Assistant <--MCP Protocol--> Your MCP Server <--> Lead Database
                                         |
                                         ├── capture_lead tool
                                         └── end_call tool
```

## Setup Instructions

### 1. Run the MCP Server

Your Go server now supports MCP mode. To run it:

```bash
cd server
go run . mcp
```

This starts the server in MCP mode, listening on stdin/stdout for MCP commands.

### 2. Test the MCP Server Locally

You can test the MCP server using a simple JSON-RPC client:

```bash
# Initialize the connection
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' | go run . mcp

# List available tools
echo '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' | go run . mcp
```

### 3. Configure VAPI to Use MCP

In your VAPI dashboard:

1. **Create an MCP Tool**:

   - Go to Dashboard > Tools
   - Click "Create Tool"
   - Select "MCP" as the tool type
   - Name: "Lead Generation Tools"
   - Server URL: You'll need to host your MCP server (see deployment options below)

2. **Update Your Assistant**:
   - Remove the existing function definitions
   - Add the MCP tool you created
   - Update the system prompt to mention the dynamically loaded tools

### 4. MCP Server Deployment Options

Since MCP uses stdio transport by default, you need a way to make it accessible to VAPI:

#### Option A: Built-in HTTP Bridge (Recommended) ✨

**Good news!** Your server now includes an HTTP bridge for MCP. Just run your normal HTTP server:

```bash
cd server && go run main.go
```

This exposes MCP through these HTTP endpoints:

- `POST /mcp/initialize` - Start a new MCP session
- `POST /mcp/request` - Send MCP requests
- `DELETE /mcp/session/:id` - Close a session

**With ngrok running**, your MCP endpoints are available at:

```
https://your-ngrok-url.ngrok-free.app/mcp/initialize
https://your-ngrok-url.ngrok-free.app/mcp/request
```

Test it locally:

```bash
# Quick test
./test-mcp-http-simple.sh

# Full test (requires jq)
./test-mcp-http.sh
```

#### Option B: Use Cloud MCP Providers

Use existing cloud-hosted MCP providers:

- **Zapier MCP**: Access to 7,000+ app integrations
- **Composio MCP**: Pre-built tool integrations

#### Option C: Deploy with Process Managers

Use services like Railway or Render that can expose stdio-based services directly.

## How It Works

1. When a VAPI call starts, it connects to your MCP server
2. VAPI calls `initialize` to establish the connection
3. VAPI calls `tools/list` to discover available tools
4. During the conversation, when the AI needs to capture a lead or end the call, VAPI calls `tools/call` with the appropriate tool name
5. Your MCP server processes the request and returns the result

## Running Both HTTP and MCP Modes

Your server supports both modes:

- **HTTP Mode** (default): `go run .` - Runs the traditional webhook server
- **MCP Mode**: `go run . mcp` - Runs as an MCP server

## Example VAPI Assistant Configuration with MCP

```json
{
  "name": "Alex - Lead Gen (MCP)",
  "model": {
    "provider": "openai",
    "model": "gpt-4",
    "tools": [
      {
        "type": "mcp",
        "name": "leadGenTools",
        "server": {
          "url": "https://your-mcp-server-url.com"
        }
      }
    ]
  },
  "voice": {
    "provider": "11labs",
    "voiceId": "21m00Tcm4TlvDq8ikWAM"
  },
  "firstMessage": "Hi there! I'm Alex...",
  "systemPrompt": "You are Alex... You have access to dynamically loaded tools including capture_lead and end_call..."
}
```

## Troubleshooting

1. **Tools not appearing**: Check MCP server logs for initialization errors
2. **Function calls failing**: Ensure tool names match exactly
3. **Connection issues**: Verify your MCP server is accessible from VAPI

## Migration Path

1. Keep your existing HTTP server running
2. Deploy the MCP server alongside
3. Create a test assistant using MCP
4. Once verified, migrate your main assistant
5. Eventually deprecate the webhook-based approach

## Next Steps

1. Choose a deployment method for your MCP server
2. Update your VAPI assistant configuration
3. Test thoroughly before switching production traffic
4. Monitor logs for any issues

## Resources

- [MCP Specification](https://modelcontextprotocol.io)
- [VAPI MCP Documentation](https://docs.vapi.ai/tools/mcp)
- [MCP Server Examples](https://github.com/modelcontextprotocol/servers)
