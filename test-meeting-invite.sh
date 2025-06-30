#!/bin/bash

echo "Testing Meeting Invite Functionality"
echo "===================================="

# Test the meeting scheduling endpoint directly
echo -e "\n1. Testing meeting schedule webhook..."
curl -X POST http://localhost:8080/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "type": "function-call",
    "call": {
      "id": "test-call-123",
      "status": "active"
    },
    "message": {
      "toolCalls": [{
        "function": {
          "name": "schedule_meeting",
          "arguments": "{\"date\":\"2025-01-15\",\"time\":\"14:00\",\"duration\":\"30\",\"title\":\"Product Demo\",\"meeting_type\":\"demo\"}"
        }
      }]
    }
  }'

echo -e "\n\n2. Checking if meeting was logged..."
curl -s http://localhost:8080/leads | jq '.[] | select(.CallID == "test-call-123")'

echo -e "\n\n3. Test complete! Check server logs for meeting scheduling details."
echo "If email is configured, check for calendar invite." 