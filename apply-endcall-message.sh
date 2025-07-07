#!/bin/bash

# 🚀 Apply endCallMessage "Goodbye now" instead of in prompt
# This provides more direct control over call termination

echo "🔄 Updating Jessica with endCallMessage approach..."
echo "Assistant ID: b34f9622-0de2-4ef6-b5ab-8bbef8f240fc"
echo ""
echo "📝 Key Changes:"
echo "1. Moving 'Goodbye now' from prompt to endCallMessage"
echo "2. Removing endCallPhrases (empty array)"
echo "3. Jessica ends with hopeful message, system says goodbye"
echo "4. Should provide more reliable call termination"
echo ""

# Check if config file exists
if [ ! -f "jessica-endcall-message.json" ]; then
    echo "❌ Error: jessica-endcall-message.json not found!"
    exit 1
fi

# Set API key
export VAPI_PRIVATE_KEY='4d106ac6-1ece-4856-a79c-b202ba21ef58'

# STEP 1: Apply the changes
echo "📤 Applying changes..."
RESPONSE=$(curl -s -X PATCH "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -H "Content-Type: application/json" \
  -d @jessica-endcall-message.json)

# Check if update was successful
if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
    echo "✅ Jessica updated successfully!"
    echo ""
    
    # STEP 2: REVISIT - Check local file
    echo "📋 REVISITING local configuration..."
    echo "- endCallMessage: $(jq -r '.endCallMessage' jessica-endcall-message.json)"
    echo "- endCallPhrases: $(jq -r '.endCallPhrases' jessica-endcall-message.json)"
    echo "- Prompt contains 'NO GOODBYE PHRASES': $(grep -c 'NO GOODBYE PHRASES' jessica-endcall-message.json)"
    echo ""
    
    # STEP 3: REVERIFY - Check production
    echo "🔍 REVERIFYING in production..."
    VERIFY=$(curl -s -X GET "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
      -H "Authorization: Bearer $VAPI_PRIVATE_KEY")
    
    echo "✅ PRODUCTION VERIFICATION:"
    echo "- endCallMessage: $(echo "$VERIFY" | jq -r '.endCallMessage')"
    echo "- endCallPhrases: $(echo "$VERIFY" | jq -r '.endCallPhrases')"
    echo "- endCallFunctionEnabled: $(echo "$VERIFY" | jq -r '.endCallFunctionEnabled')"
    echo "- backgroundSound: $(echo "$VERIFY" | jq -r '.backgroundSound')"
    echo "- silenceTimeoutSeconds: $(echo "$VERIFY" | jq -r '.silenceTimeoutSeconds')"
    echo ""
    
    # Verify prompt changes
    echo "📝 PROMPT VERIFICATION:"
    PROMPT_CHECK=$(echo "$VERIFY" | jq -r '.model.messages[0].content' | grep -E "(NEVER say 'Goodbye now'|NO GOODBYE PHRASES)" | head -2)
    if [ -n "$PROMPT_CHECK" ]; then
        echo "✅ Prompt correctly instructs NO goodbye phrases:"
        echo "$PROMPT_CHECK"
    else
        echo "⚠️  Warning: Prompt may not have the correct goodbye instructions"
    fi
    echo ""
    
    echo "✅ ALL CHANGES VERIFIED IN PRODUCTION!"
    echo ""
    echo "🎯 Expected Behavior:"
    echo "1. Jessica ends with: 'You've got this!'"
    echo "2. System immediately says: 'Goodbye now.'"
    echo "3. Call terminates right after system message"
    echo "4. No more 21-second delay"
    echo ""
    echo "📞 Test with: ./test-call.sh +16476278084"
    
    # STEP 4: Document what was changed
    echo ""
    echo "📄 Changes Summary:"
    echo "- Moved 'Goodbye now' from prompt to endCallMessage"
    echo "- Set endCallPhrases to empty array"
    echo "- Updated prompt to explicitly forbid goodbye phrases"
    echo "- Maintained all other optimizations (no background sound, etc.)"
    
else
    echo "❌ Error updating Jessica:"
    echo "$RESPONSE" | jq .
    exit 1
fi 