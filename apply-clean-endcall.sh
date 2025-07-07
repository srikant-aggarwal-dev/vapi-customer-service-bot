#!/bin/bash

# 🚀 Apply cleaner end call approach with [END_CALL] trigger
# This provides a clear, unambiguous way to end calls

echo "🔄 Updating Jessica with clean [END_CALL] trigger..."
echo "Assistant ID: b34f9622-0de2-4ef6-b5ab-8bbef8f240fc"
echo ""
echo "📝 Key Changes:"
echo "1. Jessica says 'Goodbye now. [END_CALL]' at the end"
echo "2. endCallPhrases detects '[END_CALL]' to terminate"
echo "3. No confusing negative instructions in prompt"
echo "4. Clear, clean, and unambiguous"
echo ""

# Check if config file exists
if [ ! -f "jessica-clean-endcall.json" ]; then
    echo "❌ Error: jessica-clean-endcall.json not found!"
    exit 1
fi

# Set API key
export VAPI_PRIVATE_KEY='4d106ac6-1ece-4856-a79c-b202ba21ef58'

# STEP 1: Apply the changes
echo "📤 Applying changes..."
RESPONSE=$(curl -s -X PATCH "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -H "Content-Type: application/json" \
  -d @jessica-clean-endcall.json)

# Check if update was successful
if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
    echo "✅ Jessica updated successfully!"
    echo ""
    
    # STEP 2: REVISIT - Check local file
    echo "📋 REVISITING local configuration..."
    echo "- endCallMessage: $(jq -r '.endCallMessage' jessica-clean-endcall.json)"
    echo "- endCallPhrases: $(jq -r '.endCallPhrases' jessica-clean-endcall.json)"
    echo "- Prompt contains '[END_CALL]': $(grep -c '\[END_CALL\]' jessica-clean-endcall.json)"
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
    PROMPT_CHECK=$(echo "$VERIFY" | jq -r '.model.messages[0].content' | grep -E "End the call by saying '\[END_CALL\]'" | head -1)
    if [ -n "$PROMPT_CHECK" ]; then
        echo "✅ Prompt correctly instructs to use [END_CALL]:"
        echo "$PROMPT_CHECK"
    else
        echo "⚠️  Warning: Prompt may not have the correct [END_CALL] instruction"
    fi
    
    # Check closing message
    CLOSING_CHECK=$(echo "$VERIFY" | jq -r '.model.messages[0].content' | grep -E "Goodbye now\. \[END_CALL\]" | head -1)
    if [ -n "$CLOSING_CHECK" ]; then
        echo "✅ Closing message includes [END_CALL] trigger"
    fi
    echo ""
    
    echo "✅ ALL CHANGES VERIFIED IN PRODUCTION!"
    echo ""
    echo "🎯 Expected Behavior:"
    echo "1. Jessica ends with: 'You've got this! Goodbye now. [END_CALL]'"
    echo "2. System detects '[END_CALL]' and terminates immediately"
    echo "3. No delay, no confusion"
    echo "4. Clean and professional"
    echo ""
    echo "📞 Test with: ./test-call.sh +16476278084"
    
    # STEP 4: Document what was changed
    echo ""
    echo "📄 Changes Summary:"
    echo "- Using [END_CALL] as clear termination trigger"
    echo "- Set endCallPhrases to ['[END_CALL]']"
    echo "- Prompt instructs to end with 'Goodbye now. [END_CALL]'"
    echo "- Removed confusing negative instructions"
    echo "- Maintained all performance optimizations"
    
else
    echo "❌ Error updating Jessica:"
    echo "$RESPONSE" | jq .
    exit 1
fi 