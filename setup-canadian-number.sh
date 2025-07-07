#!/bin/bash

# Setup script for Canadian phone number integration with Vapi
echo "🇨🇦 Setting up Canadian phone number with VoIP.ms + Vapi..."

# Load environment variables
source server/config.env

echo ""
echo "📋 STEP 1: VoIP.ms Account Setup"
echo "1. Go to https://voip.ms and create account"
echo "2. Add $20 CAD to your account"
echo "3. Purchase a Canadian phone number in your preferred area:"
echo "   • Toronto: 416, 647, 437"
echo "   • Vancouver: 604, 778, 236"
echo "   • Montreal: 514, 438"
echo "   • Calgary: 403, 587, 825"
echo ""

echo "📋 STEP 2: Get SIP Credentials from VoIP.ms"
echo "1. Go to Main Menu → Sub Accounts"
echo "2. Create a new Sub Account"
echo "3. Note down:"
echo "   • Username: (your sub account)"
echo "   • Password: (your SIP password)"
echo "   • Server: toronto.voip.ms (or your preferred server)"
echo "   • Your DID number: +1XXXXXXXXXX"
echo ""

echo "📋 STEP 3: Create Vapi SIP Trunk Credential"
echo "Run this curl command with your VoIP.ms details:"
echo ""

cat << 'EOF'
curl -X POST "https://api.vapi.ai/credential" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -d '{
    "provider": "byo-sip-trunk",
    "name": "VoIP.ms Canadian Trunk",
    "gateways": [{
      "ip": "toronto.voip.ms"
    }],
    "outboundLeadingPlusEnabled": true,
    "outboundAuthenticationPlan": {
      "authUsername": "YOUR_VOIPMS_USERNAME",
      "authPassword": "YOUR_VOIPMS_PASSWORD"
    }
  }'
EOF

echo ""
echo ""
echo "📋 STEP 4: Add Canadian Phone Number to Vapi"
echo "Use the credential ID from step 3:"
echo ""

cat << 'EOF'
curl -X POST "https://api.vapi.ai/phone-number" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -d '{
    "provider": "byo-phone-number",
    "name": "Canadian Number",
    "number": "YOUR_CANADIAN_NUMBER",
    "numberE164CheckEnabled": false,
    "credentialId": "YOUR_CREDENTIAL_ID_FROM_STEP_3"
  }'
EOF

echo ""
echo ""
echo "📋 STEP 5: Test Your Canadian Number"
echo "After setup, update your assistant to use the new Canadian number!"
echo ""
echo "💰 COST BREAKDOWN:"
echo "• VoIP.ms phone number: ~$2-3 CAD/month"
echo "• Outbound calls: ~$0.01 CAD/minute within Canada"
echo "• Inbound calls: Usually free or very low cost"
echo ""
echo "✅ Benefits:"
echo "• 🇨🇦 True Canadian phone number"
echo "• 📞 Can call other Canadian numbers domestically"
echo "• 💰 Much cheaper than Vapi's international rates"
echo "• 🏠 Local presence for your Canadian clients" 