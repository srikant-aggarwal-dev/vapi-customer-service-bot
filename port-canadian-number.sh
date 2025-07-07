#!/bin/bash

# Port your existing Canadian number to VoIP.ms for Vapi integration
echo "🇨🇦 Porting your Canadian number +16476278084 to VoIP.ms..."

echo ""
echo "🔄 STEP 1: Number Portability Check"
echo "1. Go to https://voip.ms"
echo "2. Sign up for account"
echo "3. Go to 'Number Portability' section"
echo "4. Enter your number: +16476278084"
echo "5. Check if it's portable (most Canadian numbers are!)"
echo ""

echo "📋 STEP 2: Gather Required Information"
echo "You'll need from your current provider:"
echo "• Account number"
echo "• PIN/Password"
echo "• Billing address"
echo "• Account holder name"
echo "• Current provider name"
echo ""

echo "💰 STEP 3: Costs"
echo "• VoIP.ms porting fee: ~$25 CAD (one-time)"
echo "• Monthly cost: ~$2-3 CAD/month"
echo "• Call rates: ~$0.01 CAD/minute within Canada"
echo ""

echo "⏱️ STEP 4: Timeline"
echo "• Business numbers: 3-10 business days"
echo "• Residential numbers: 1-5 business days"
echo "• No service interruption during port"
echo ""

echo "🔧 STEP 5: Setup with Vapi (after porting)"
echo "Once ported, you'll get SIP credentials from VoIP.ms:"
echo "• Username: your_account@voip.ms"
echo "• Password: your_sip_password"
echo "• Server: toronto.voip.ms"
echo ""

echo "Then run this command to add to Vapi:"
cat << 'EOF'

# Step 1: Create SIP Trunk Credential
curl -X POST "https://api.vapi.ai/credential" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -d '{
    "provider": "byo-sip-trunk",
    "name": "My Canadian Number - VoIP.ms",
    "gateways": [{
      "ip": "toronto.voip.ms"
    }],
    "outboundLeadingPlusEnabled": true,
    "outboundAuthenticationPlan": {
      "authUsername": "YOUR_VOIPMS_USERNAME",
      "authPassword": "YOUR_VOIPMS_SIP_PASSWORD"
    }
  }'

# Step 2: Add Your Canadian Number
curl -X POST "https://api.vapi.ai/phone-number" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -d '{
    "provider": "byo-phone-number",
    "name": "My Canadian Number",
    "number": "16476278084",
    "numberE164CheckEnabled": false,
    "credentialId": "CREDENTIAL_ID_FROM_STEP_1"
  }'
EOF

echo ""
echo ""
echo "✅ BENEFITS of Using Your Number:"
echo "• 🇨🇦 Jeff appears as a Canadian business"
echo "• 📞 Can call any Canadian number domestically"
echo "• 💰 Much cheaper than international rates"
echo "• 🏠 Familiar number for you and your clients"
echo "• 📱 You keep your existing number!"
echo ""

echo "🚀 ALTERNATIVE: Get a Second Canadian Number"
echo "If you don't want to port your personal number:"
echo "1. Get a NEW Canadian business number from VoIP.ms"
echo "2. Choose same area code (647) for Toronto presence"
echo "3. Much faster setup (instant)"
echo "4. Keep your personal number separate" 