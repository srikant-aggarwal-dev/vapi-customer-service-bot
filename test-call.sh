#!/bin/bash

# Test call to VAPI assistant
echo "Making test call to VAPI assistant..."

# You need to get your Assistant ID from VAPI Dashboard
# Go to Assistants -> Click on "Alex" -> Copy the ID from the URL or details
ASSISTANT_ID="YOUR_ASSISTANT_ID_HERE"

# Your phone number in E.164 format (e.g., +14155551234)
PHONE_NUMBER="YOUR_PHONE_NUMBER_HERE"

# Make the API call
curl --location 'https://api.vapi.ai/call' \
--header 'Authorization: Bearer '$VAPI_PRIVATE_KEY \
--header 'Content-Type: application/json' \
--data '{
  "assistantId": "'$ASSISTANT_ID'",
  "customer": {
    "number": "'$PHONE_NUMBER'"
  }
}' 