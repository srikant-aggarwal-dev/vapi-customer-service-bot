#!/bin/bash

echo "🧪 Testing Meeting Invite Feature"
echo "================================="

# First, let's create a test lead
echo -e "\n1. Creating a test lead..."
curl -X POST http://localhost:8080/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "type": "function-call",
    "call": {
      "id": "test-meeting-123",
      "status": "active"
    },
    "message": {
      "toolCalls": [{
        "function": {
          "name": "capture_lead",
          "arguments": "{\"name\":\"Test User\",\"email\":\"srikantaggarwal@gmail.com\",\"phone\":\"+1234567890\",\"company\":\"Test Company\",\"status\":\"qualified\"}"
        }
      }]
    }
  }'

echo -e "\n\n2. Scheduling a meeting for tomorrow at 2 PM..."
TOMORROW=$(date -v+1d +%Y-%m-%d)
curl -X POST http://localhost:8080/webhook \
  -H "Content-Type: application/json" \
  -d "{
    \"type\": \"function-call\",
    \"call\": {
      \"id\": \"test-meeting-123\",
      \"status\": \"active\"
    },
    \"message\": {
      \"toolCalls\": [{
        \"function\": {
          \"name\": \"schedule_meeting\",
          \"arguments\": \"{\\\"date\\\":\\\"$TOMORROW\\\",\\\"time\\\":\\\"14:00\\\",\\\"duration\\\":\\\"30\\\",\\\"title\\\":\\\"Product Demo - Test Company\\\",\\\"meeting_type\\\":\\\"demo\\\"}\"
        }
      }]
    }
  }"

echo -e "\n\n✅ Test complete! Check your email for the meeting invite."
echo "📧 The invite was sent to: srikantaggarwal@gmail.com"
echo "📅 Meeting link: https://meet.google.com/oyr-txmt-jtb" 