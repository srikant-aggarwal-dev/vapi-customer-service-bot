#!/bin/bash

# Quick setup: Get Jeff a new Canadian number TODAY
echo "🚀 Quick Setup: Get Jeff a Canadian number in 30 minutes!"

echo ""
echo "📞 STEP 1: Get Canadian Number (5 minutes)"
echo "1. Go to https://voip.ms"
echo "2. Create account → Add $20 CAD"
echo "3. Browse Numbers → Select Toronto 647 area code"
echo "4. Choose a number like: +1-647-XXX-XXXX"
echo "5. Purchase it ($2-3 CAD/month)"
echo ""

echo "🔐 STEP 2: Get SIP Credentials (5 minutes)"
echo "1. Go to Main Menu → Sub Accounts"
echo "2. Create new Sub Account"
echo "3. Write down:"
echo "   • Username: your_subaccount"
echo "   • Password: (set SIP password)"
echo "   • Server: toronto.voip.ms"
echo "   • Your new number: +1647XXXXXXX"
echo ""

echo "🔗 STEP 3: Connect to Vapi (10 minutes)"
echo "Update these commands with your real details:"
echo ""

# Load environment variables
source server/config.env

cat << 'EOF'
# Replace YOUR_VOIPMS_USERNAME and YOUR_VOIPMS_PASSWORD with real values

# Create SIP credential
curl -X POST "https://api.vapi.ai/credential" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -d '{
    "provider": "byo-sip-trunk",
    "name": "Jeff Canadian Number",
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
echo "# Save the credentialId from above, then:"
echo ""

cat << 'EOF'
# Add your Canadian number (replace YOUR_NEW_CANADIAN_NUMBER)
curl -X POST "https://api.vapi.ai/phone-number" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -d '{
    "provider": "byo-phone-number",
    "name": "Jeff Toronto Number",
    "number": "YOUR_NEW_CANADIAN_NUMBER",
    "numberE164CheckEnabled": false,
    "credentialId": "YOUR_CREDENTIAL_ID_FROM_ABOVE"
  }'
EOF

echo ""
echo "🧪 STEP 4: Test Jeff's New Number (5 minutes)"
echo "Update your test script with the new Canadian phone number ID!"
echo ""

echo "✅ IMMEDIATE BENEFITS:"
echo "• 🇨🇦 Jeff calls FROM a Canadian number"
echo "• 📞 Can call your +16476278084 domestically"
echo "• 💰 No international calling fees"
echo "• 🏢 Professional Toronto business presence"
echo "• ⚡ Working today!"
echo ""

echo "💡 SUGGESTED CANADIAN NUMBERS:"
echo "• 647-XXX-XXXX (Toronto mobile-style)"
echo "• 416-XXX-XXXX (Toronto traditional)"
echo "• 437-XXX-XXXX (Toronto newer)"
echo ""

echo "After setup, Jeff will call FROM his Canadian number TO any number!" 