#!/bin/bash

# Test call to Jeff - Personal Finance Advisor
echo "🇨🇦 Making test call to Jeff - Canadian Financial Advisor..."

# Load environment variables
source server/config.env

# Jeff's Assistant ID from Vapi
ASSISTANT_ID="b34f9622-0de2-4ef6-b5ab-8bbef8f240fc"

# Vapi Phone Number ID (from our account)
PHONE_NUMBER_ID="e055f459-f1fc-4fc8-9aaf-67a0921b0ef3"

# Check if phone number is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <phone_number>"
    echo ""
    echo "📞 CANADIAN EXAMPLES:"
    echo "  Toronto:    $0 +14161234567"
    echo "  Vancouver:  $0 +16041234567"
    echo "  Montreal:   $0 +15141234567"
    echo "  Calgary:    $0 +14031234567"
    echo ""
    echo "🇺🇸 US EXAMPLES:"
    echo "  New York:   $0 +12121234567"
    echo "  LA:         $0 +13101234567"
    echo ""
    echo "Note: Phone number must be in E.164 format (+1XXXXXXXXXX)"
    exit 1
fi

PHONE_NUMBER="$1"

# Validate phone number format
if [[ ! $PHONE_NUMBER =~ ^[+]1[0-9]{10}$ ]]; then
    echo "❌ Invalid phone number format!"
    echo "Canadian/US numbers must be: +1XXXXXXXXXX"
    echo "Example: +14161234567"
    exit 1
fi

echo "📞 Calling Jeff at $PHONE_NUMBER..."
echo "🔑 Using Assistant ID: $ASSISTANT_ID"
echo "🇨🇦 Jeff specializes in Canadian debt management and financial planning"

# Make the API call
curl --location 'https://api.vapi.ai/call' \
--header 'Authorization: Bearer '$VAPI_PRIVATE_KEY \
--header 'Content-Type: application/json' \
--data '{
  "assistantId": "'$ASSISTANT_ID'",
  "phoneNumberId": "'$PHONE_NUMBER_ID'",
  "customer": {
    "number": "'$PHONE_NUMBER'"
  }
}' | jq .

echo ""
echo "✅ Call initiated! Jeff should be calling you shortly."
echo "🇨🇦 Jeff will help you with Canadian debt management and financial planning:"
echo "   • Understands Canadian provinces and financial regulations"
echo "   • Provides personalized debt reduction strategies"
echo "   • Can schedule follow-up consultations"
echo "   • Captures client data for ongoing support" 