#!/bin/bash

# 🚀 Fix Jessica's 21-second delay after "Goodbye now"
# This removes background sound and optimizes settings for faster call termination

echo "🔧 Fixing Jessica's Call Ending Delay..."
echo "Assistant ID: b34f9622-0de2-4ef6-b5ab-8bbef8f240fc"
echo ""
echo "📝 Key Changes:"
echo "1. Removing background sound (was causing delay)"
echo "2. Disabling background denoising"
echo "3. Optimizing transport configuration"
echo "4. Keeping endCallPhrases for immediate termination"
echo ""

# Check if config file exists
if [ ! -f "jessica-fix-delay.json" ]; then
    echo "❌ Error: jessica-fix-delay.json not found!"
    exit 1
fi

# Set API key
export VAPI_PRIVATE_KEY='4d106ac6-1ece-4856-a79c-b202ba21ef58'

# Update Jessica
echo "🔄 Updating Jessica..."
RESPONSE=$(curl -s -X PATCH "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -H "Content-Type: application/json" \
  -d @jessica-fix-delay.json)

# Check if update was successful
if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
    echo "✅ Jessica updated successfully!"
    echo ""
    echo "🔍 Verifying changes..."
    
    # Verify the changes
    VERIFY=$(curl -s -X GET "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
      -H "Authorization: Bearer $VAPI_PRIVATE_KEY")
    
    echo "Background Sound: $(echo "$VERIFY" | jq -r '.backgroundSound')"
    echo "Background Denoising: $(echo "$VERIFY" | jq -r '.backgroundDenoisingEnabled')"
    echo "End Call Phrases: $(echo "$VERIFY" | jq -r '.endCallPhrases')"
    echo "Silence Timeout: $(echo "$VERIFY" | jq -r '.silenceTimeoutSeconds') seconds"
    
    echo ""
    echo "✅ UPDATE COMPLETE!"
    echo ""
    echo "🎯 Expected Results:"
    echo "- Call should end within 1-2 seconds after 'Goodbye now'"
    echo "- No more 21-second delay"
    echo "- Background sound removed"
    echo ""
    echo "📞 Test with: ./test-call.sh +16476278084"
else
    echo "❌ Error updating Jessica:"
    echo "$RESPONSE" | jq .
    exit 1
fi 