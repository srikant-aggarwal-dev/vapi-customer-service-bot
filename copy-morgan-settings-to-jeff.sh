#!/bin/bash

echo "📋 Copying Morgan's Settings to Jeff"
echo "===================================="
echo ""

# Load environment variables
source server/config.env

# First, let's get Morgan's assistant configuration
echo "🔍 Step 1: Getting Morgan's configuration..."
echo ""

# You'll need to replace this with Morgan's actual assistant ID
# Check your Vapi dashboard to find Morgan's ID
MORGAN_ID="YOUR_MORGAN_ASSISTANT_ID_HERE"

echo "📝 To find Morgan's ID:"
echo "1. Go to https://dashboard.vapi.ai/assistants"
echo "2. Find Morgan in your assistants list"
echo "3. Click on Morgan and copy the ID from the URL"
echo ""
echo "Then update this script with Morgan's ID and run it again."
echo ""

# Get Morgan's configuration
echo "🔍 Getting Morgan's current settings..."
MORGAN_CONFIG=$(curl -s -X GET "https://api.vapi.ai/assistant/$MORGAN_ID" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY")

if echo "$MORGAN_CONFIG" | jq -e '.id' > /dev/null 2>&1; then
    echo "✅ Successfully retrieved Morgan's config"
    
    # Extract key settings from Morgan
    VOICE_PROVIDER=$(echo "$MORGAN_CONFIG" | jq -r '.voice.provider')
    VOICE_ID=$(echo "$MORGAN_CONFIG" | jq -r '.voice.voiceId')
    VOICE_MODEL=$(echo "$MORGAN_CONFIG" | jq -r '.voice.model // empty')
    VOICE_LANGUAGE=$(echo "$MORGAN_CONFIG" | jq -r '.voice.language // empty')
    
    # Model settings
    MODEL_PROVIDER=$(echo "$MORGAN_CONFIG" | jq -r '.model.provider')
    MODEL_NAME=$(echo "$MORGAN_CONFIG" | jq -r '.model.model')
    MODEL_TEMPERATURE=$(echo "$MORGAN_CONFIG" | jq -r '.model.temperature // 0.7')
    MODEL_MAX_TOKENS=$(echo "$MORGAN_CONFIG" | jq -r '.model.maxTokens // 150')
    
    # Timing settings
    SILENCE_TIMEOUT=$(echo "$MORGAN_CONFIG" | jq -r '.silenceTimeoutSeconds // 10')
    RESPONSE_DELAY=$(echo "$MORGAN_CONFIG" | jq -r '.responseDelaySeconds // 1')
    LLM_DELAY=$(echo "$MORGAN_CONFIG" | jq -r '.llmRequestDelaySeconds // 0.1')
    
    echo ""
    echo "📊 Morgan's Settings:"
    echo "• Voice: $VOICE_PROVIDER - $VOICE_ID"
    echo "• Model: $MODEL_PROVIDER - $MODEL_NAME"
    echo "• Temperature: $MODEL_TEMPERATURE"
    echo "• Max Tokens: $MODEL_MAX_TOKENS"
    echo "• Silence Timeout: $SILENCE_TIMEOUT seconds"
    echo "• Response Delay: $RESPONSE_DELAY seconds"
    echo ""
    
    # Apply Morgan's settings to Jeff
    echo "🔄 Step 2: Applying Morgan's settings to Jeff..."
    
    # Build voice config
    VOICE_CONFIG="{
        \"provider\": \"$VOICE_PROVIDER\",
        \"voiceId\": \"$VOICE_ID\""
    
    if [ "$VOICE_MODEL" != "null" ] && [ "$VOICE_MODEL" != "" ]; then
        VOICE_CONFIG="$VOICE_CONFIG,\"model\": \"$VOICE_MODEL\""
    fi
    
    if [ "$VOICE_LANGUAGE" != "null" ] && [ "$VOICE_LANGUAGE" != "" ]; then
        VOICE_CONFIG="$VOICE_CONFIG,\"language\": \"$VOICE_LANGUAGE\""
    fi
    
    VOICE_CONFIG="$VOICE_CONFIG}"
    
    # Update Jeff with Morgan's settings
    UPDATE_RESPONSE=$(curl -s -X PATCH "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
      -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"voice\": $VOICE_CONFIG,
        \"model\": {
          \"provider\": \"$MODEL_PROVIDER\",
          \"model\": \"$MODEL_NAME\",
          \"temperature\": $MODEL_TEMPERATURE,
          \"maxTokens\": $MODEL_MAX_TOKENS
        },
        \"silenceTimeoutSeconds\": $SILENCE_TIMEOUT,
        \"responseDelaySeconds\": $RESPONSE_DELAY,
        \"llmRequestDelaySeconds\": $LLM_DELAY
      }")
    
    # Check if update was successful
    if echo "$UPDATE_RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
        echo "✅ SUCCESS! Jeff now has Morgan's exact settings!"
        echo ""
        echo "🎯 Settings Applied:"
        echo "• Voice: $VOICE_PROVIDER - $VOICE_ID"
        echo "• Model: $MODEL_PROVIDER - $MODEL_NAME"
        echo "• Temperature: $MODEL_TEMPERATURE"
        echo "• Max Tokens: $MODEL_MAX_TOKENS"
        echo "• Silence Timeout: $SILENCE_TIMEOUT seconds"
        echo "• Response Delay: $RESPONSE_DELAY seconds"
        echo ""
        echo "📞 Ready to test! Use: ./test-call.sh +16476278084"
        echo ""
        echo "🎭 Jeff should now have:"
        echo "• Same natural pauses as Morgan"
        echo "• Same email accuracy"
        echo "• Same conversational flow"
        echo "• Same voice quality"
    else
        echo "❌ Error updating Jeff. Response:"
        echo "$UPDATE_RESPONSE"
    fi
    
else
    echo "❌ Could not retrieve Morgan's config. Please check the assistant ID."
    echo ""
    echo "🔍 To find Morgan's ID:"
    echo "1. Go to https://dashboard.vapi.ai/assistants"
    echo "2. Find Morgan in your list"
    echo "3. Click on Morgan"
    echo "4. Copy the ID from the URL (format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)"
    echo "5. Replace MORGAN_ID in this script"
    echo ""
fi

echo ""
echo "💡 Manual Settings Still Needed:"
echo "Some advanced settings can only be copied manually in the dashboard:"
echo ""
echo "1. Go to https://dashboard.vapi.ai/assistants"
echo "2. Open Morgan's assistant"
echo "3. Note the Transcriber → Advanced Settings"
echo "4. Open Jeff's assistant"
echo "5. Copy the same Advanced Settings from Morgan to Jeff"
echo ""
echo "📋 Typical settings to copy:"
echo "• Interruption Sensitivity"
echo "• End of Speech Threshold"
echo "• Speech Detection Sensitivity"
echo "• Smart Endpointing settings" 