#!/bin/bash

# Update Vapi with Twilio Canadian Number Integration
echo "🔗 Configuring Vapi + Twilio Canadian Number Integration..."
echo ""

# Load environment variables
source server/config.env

# Collect Twilio credentials
echo "🔑 TWILIO CREDENTIALS NEEDED:"
echo "Please have the following ready from your Twilio Console:"
echo ""
read -p "Enter your Twilio Account SID: " TWILIO_SID
read -p "Enter your Twilio Auth Token: " TWILIO_TOKEN
read -p "Enter your Canadian Phone Number (+1XXXXXXXXXX): " CANADIAN_NUMBER

echo ""
echo "📋 STEP 1: Create SIP Trunk Credential in Vapi"
echo "This will connect your Twilio account to Vapi..."

# Create SIP trunk credential
CREDENTIAL_RESPONSE=$(curl -s -X POST "https://api.vapi.ai/credential" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -d '{
    "provider": "byo-sip-trunk",
    "name": "Twilio Canadian Trunk",
    "gateways": [{
      "ip": "sip.twilio.com"
    }],
    "outboundLeadingPlusEnabled": true,
    "outboundAuthenticationPlan": {
      "authUsername": "'$TWILIO_SID'",
      "authPassword": "'$TWILIO_TOKEN'"
    }
  }')

# Extract credential ID
CREDENTIAL_ID=$(echo $CREDENTIAL_RESPONSE | jq -r '.id')

echo "✅ SIP Trunk Credential Created: $CREDENTIAL_ID"
echo ""

echo "📞 STEP 2: Associate Canadian Phone Number with SIP Trunk"

# Create phone number resource
PHONE_RESPONSE=$(curl -s -X POST "https://api.vapi.ai/phone-number" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -d '{
    "provider": "byo-phone-number",
    "name": "Jeff Canadian Number",
    "number": "'$CANADIAN_NUMBER'",
    "numberE164CheckEnabled": false,
    "credentialId": "'$CREDENTIAL_ID'"
  }')

# Extract phone number ID
PHONE_NUMBER_ID=$(echo $PHONE_RESPONSE | jq -r '.id')

echo "✅ Canadian Phone Number Associated: $PHONE_NUMBER_ID"
echo ""

echo "🤖 STEP 3: Update Jeff's Assistant Configuration"

# Update assistant to use the new phone number
ASSISTANT_RESPONSE=$(curl -s -X PATCH "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -d '{
    "phoneNumberId": "'$PHONE_NUMBER_ID'",
    "firstMessage": "Hello! I'\''m Jeff, your personal finance advisor calling from Canada. I understand how overwhelming debt can feel, and I'\''m here to help you create a plan that works for your situation. What province are you calling from?"
  }')

echo "✅ Jeff's Assistant Updated with Canadian Number"
echo ""

echo "🎉 SETUP COMPLETE!"
echo ""
echo "📊 Summary:"
echo "• Twilio Account SID: $TWILIO_SID"
echo "• Canadian Phone Number: $CANADIAN_NUMBER"
echo "• Vapi Credential ID: $CREDENTIAL_ID"
echo "• Vapi Phone Number ID: $PHONE_NUMBER_ID"
echo ""
echo "💰 Monthly Costs:"
echo "• Twilio Canadian Number: $1.15 CAD/month"
echo "• Per-minute calling: $0.0140 CAD/minute"
echo "• Total estimated (100 mins): ~$2.50 CAD/month"
echo ""
echo "🔄 Next Steps:"
echo "1. Test the integration: ./test-jeff-canadian-twilio.sh"
echo "2. Update any webhooks to point to your Canadian number"
echo "3. Enjoy Jeff's Canadian presence!"
echo ""
echo "🚀 Jeff can now call Canadian numbers without restrictions!" 