#!/bin/bash

# Test Canadian calling after Vapi account upgrade
echo "🇨🇦 Testing Jeff with Canadian number after upgrade..."

# Load environment variables
source server/config.env

# Jeff's Assistant ID from Vapi
ASSISTANT_ID="b34f9622-0de2-4ef6-b5ab-8bbef8f240fc"

# Vapi Phone Number ID (from our account)
PHONE_NUMBER_ID="e055f459-f1fc-4fc8-9aaf-67a0921b0ef3"

# Your Canadian number
CANADIAN_NUMBER="+16476278084"

echo "📞 Calling Jeff at your Canadian number: $CANADIAN_NUMBER"
echo "🔑 Using Assistant ID: $ASSISTANT_ID"
echo "💳 Using upgraded Vapi account with international calling"

# Make the API call
curl --location 'https://api.vapi.ai/call' \
--header 'Authorization: Bearer '$VAPI_PRIVATE_KEY \
--header 'Content-Type: application/json' \
--data '{
  "assistantId": "'$ASSISTANT_ID'",
  "phoneNumberId": "'$PHONE_NUMBER_ID'",
  "customer": {
    "number": "'$CANADIAN_NUMBER'"
  }
}' | jq .

echo ""
echo "✅ Call initiated to Canada!"
echo "🇨🇦 Jeff will call you at $CANADIAN_NUMBER shortly"
echo "💡 This call will use your upgraded Vapi plan" 