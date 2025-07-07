#!/bin/bash

# 🚀 Update Jessica's Configuration in VAPI
# This script updates Jessica's assistant configuration with the optimized prompt

echo "🔄 Updating Jessica's Configuration..."
echo "Assistant ID: b34f9622-0de2-4ef6-b5ab-8bbef8f240fc"

# Check if config file exists
if [ ! -f "jessica-patient-final.json" ]; then
    echo "❌ Error: jessica-patient-final.json not found!"
    exit 1
fi

# Check if VAPI_PRIVATE_KEY is set
if [ -z "$VAPI_PRIVATE_KEY" ]; then
    echo "❌ Error: VAPI_PRIVATE_KEY environment variable not set!"
    echo "Please run: export VAPI_PRIVATE_KEY='your-api-key'"
    exit 1
fi

# Read the JSON config
CONFIG=$(cat jessica-patient-final.json)

# Update the assistant
echo "📤 Sending update to VAPI..."
RESPONSE=$(curl -s -X PATCH "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -H "Content-Type: application/json" \
  -d "$CONFIG")

# Check if update was successful
if echo "$RESPONSE" | grep -q '"id"'; then
    echo "✅ Jessica updated successfully!"
    echo ""
    echo "📊 Configuration Summary:"
    echo "- Prompt: Optimized with Google's 5-step framework"
    echo "- Character count: ~6,600 (reduced from ~8,000)"
    echo "- Voice: ElevenLabs Jessica (cgSgspJ2msm6clMCkdW9)"
    echo "- Model: GPT-4o with temperature 0.4"
    echo ""
    echo "🔍 Key improvements:"
    echo "- ✅ All bug fixes preserved"
    echo "- ✅ Removed redundant instructions"
    echo "- ✅ Added CRITICAL RULES section"
    echo "- ✅ Enhanced number pronunciation"
    echo "- ✅ Complete hopeful ending"
    echo ""
    echo "📞 Test the updated Jessica:"
    echo "   ./test-call.sh +16476278084"
else
    echo "❌ Update failed!"
    echo "Response: $RESPONSE"
    exit 1
fi 