#!/bin/bash

# Test Jeff's Canadian Twilio number
echo "🇨🇦 Testing Jeff's Canadian Twilio + Vapi Integration..."

# Load environment variables
source server/config.env

# Jeff's Assistant ID from Vapi
ASSISTANT_ID="b34f9622-0de2-4ef6-b5ab-8bbef8f240fc"

# Jeff's Canadian Phone Number ID (Manitoba number: +14313415863)
CANADIAN_PHONE_NUMBER_ID="9453af42-f8ff-4cc9-90a3-c02a5de4b59c"

# Your Canadian number to call
YOUR_NUMBER="+16476278084"

# Check if custom Canadian number is provided
if [ ! -z "$1" ]; then
    YOUR_NUMBER="$1"
fi

echo ""
echo "📞 Calling Jeff with Canadian integration..."
echo "🤖 Assistant: Jeff (Financial Advisor)"
echo "📱 Your Number: $YOUR_NUMBER"
echo "🇨🇦 Jeff's Number: +1-431-341-5863 (Manitoba)"
echo "🆔 Phone Number ID: $CANADIAN_PHONE_NUMBER_ID"
echo ""
echo "🔄 This call will now work because:"
echo "   • Jeff has a Canadian phone number (via Twilio)"
echo "   • No international calling restrictions"
echo "   • Much cheaper than Vapi upgrade ($1.15/month vs $400/month)"
echo ""

# Make the API call with the Canadian phone number ID
echo "🚀 Initiating call..."
curl --location 'https://api.vapi.ai/call' \
--header 'Authorization: Bearer '$VAPI_PRIVATE_KEY \
--header 'Content-Type: application/json' \
--data '{
  "assistantId": "'$ASSISTANT_ID'",
  "customer": {
    "number": "'$YOUR_NUMBER'"
  },
  "phoneNumberId": "'$CANADIAN_PHONE_NUMBER_ID'"
}' | jq .

echo ""
echo "📊 Expected Results:"
echo "✅ Call should connect successfully"
echo "✅ Jeff will have Canadian caller ID: +1-431-341-5863"
echo "✅ No 'international calling' errors"
echo "✅ Much more affordable per-minute rates"
echo ""
echo "💰 Cost Analysis:"
echo "• This call cost: ~$0.014 CAD/minute (vs $0.18 USD with Vapi upgrade)"
echo "• Monthly number cost: $1.15 CAD (vs $400 USD Vapi upgrade)"
echo "• Total savings: ~$500+ CAD/month!" 