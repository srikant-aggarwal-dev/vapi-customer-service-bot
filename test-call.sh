#!/bin/bash

# Load environment variables
source server/config.env

# Test call to VAPI assistant
echo "Making test call to VAPI assistant..."

# Jeff's Assistant ID from VAPI Dashboard
ASSISTANT_ID="b34f9622-0de2-4ef6-b5ab-8bbef8f240fc"

# Jeff's Canadian Phone Number ID (Twilio import)
PHONE_NUMBER_ID="ceaf1a47-5241-4dcf-9649-e33747e87031"

# Your phone number in E.164 format
PHONE_NUMBER="${1:-+16476278084}"

# Make the API call (using PRIVATE key for server-side API calls)
curl --location 'https://api.vapi.ai/call' \
--header 'Authorization: Bearer '$VAPI_PRIVATE_KEY \
--header 'Content-Type: application/json' \
--data '{
  "assistantId": "'$ASSISTANT_ID'",
  "phoneNumberId": "'$PHONE_NUMBER_ID'",
  "customer": {
    "number": "'$PHONE_NUMBER'"
  }
}' 