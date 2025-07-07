#!/bin/bash

echo "🔧 Applying Jeff's Interruption Fix via API"
echo "=========================================="
echo ""

# Load environment variables
source server/config.env

# Step 1: Update voice settings
echo "📱 Step 1: Updating Voice Settings..."
VOICE_UPDATE=$(curl -s -X PATCH "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "voice": {
      "provider": "11labs",
      "voiceId": "pNInz6obpgDQGcFmaJgB",
      "stability": 0.5,
      "similarityBoost": 0.75,
      "style": 0.0,
      "useSpeakerBoost": true
    },
    "voiceConfig": {
      "interruption": {
        "sensitivity": 0.8,
        "enabled": true
      },
      "backgroundNoiseReduction": {
        "enabled": true
      }
    }
  }')

echo "Voice update response: $(echo $VOICE_UPDATE | jq -r '.id // .error // "Updated"')"

# Step 2: Update transcriber settings
echo ""
echo "🎤 Step 2: Updating Transcriber Settings..."
TRANSCRIBER_UPDATE=$(curl -s -X PATCH "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "transcriber": {
      "provider": "openai",
      "model": "gpt-4o-transcribe",
      "endpointing": {
        "enabled": true,
        "timeout": 1500
      },
      "smartEndpointingEnabled": true
    }
  }')

echo "Transcriber update response: $(echo $TRANSCRIBER_UPDATE | jq -r '.id // .error // "Updated"')"

# Step 3: Update the first message and conversation settings
echo ""
echo "💬 Step 3: Updating Conversation Settings..."
CONVERSATION_UPDATE=$(curl -s -X PATCH "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "firstMessage": "Hello! I'\''m Jeff, a personal finance advisor. I understand how overwhelming debt can feel, and I'\''m here to help. Would you like to talk about your financial situation?",
    "silenceTimeoutSeconds": 5,
    "maxDurationSeconds": 2400,
    "backgroundDenoisingEnabled": true,
    "interruptionThreshold": 800
  }')

echo "Conversation update response: $(echo $CONVERSATION_UPDATE | jq -r '.id // .error // "Updated"')"

# Step 4: Get current assistant config to verify
echo ""
echo "🔍 Step 4: Verifying Settings..."
CURRENT_CONFIG=$(curl -s -X GET "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY")

# Extract key settings
INTERRUPTION_SENSITIVITY=$(echo $CURRENT_CONFIG | jq -r '.voiceConfig.interruption.sensitivity // "Not set"')
SILENCE_TIMEOUT=$(echo $CURRENT_CONFIG | jq -r '.silenceTimeoutSeconds // "Default"')
TRANSCRIBER=$(echo $CURRENT_CONFIG | jq -r '.transcriber.provider // "Default"')

echo ""
echo "✅ CURRENT SETTINGS:"
echo "• Interruption Sensitivity: $INTERRUPTION_SENSITIVITY"
echo "• Silence Timeout: $SILENCE_TIMEOUT seconds"
echo "• Transcriber: $TRANSCRIBER"
echo ""

# If the API updates didn't work fully, provide manual instructions
echo "📋 MANUAL STEPS STILL NEEDED:"
echo ""
echo "Some settings must be changed in the Vapi Dashboard:"
echo ""
echo "1. Go to: https://dashboard.vapi.ai/assistants"
echo "2. Click on 'Jeff' assistant"
echo "3. Scroll to 'Transcriber' → Advanced Settings:"
echo "   • End of Speech Threshold: 1500ms"
echo "   • Speech Detection Sensitivity: 0.3"
echo "4. Scroll to 'Voice' → Advanced Settings:"
echo "   • Interruption Sensitivity: 0.8"
echo "   • Response Delay: 1000ms"
echo "5. Click 'Save'"
echo ""
echo "🧪 TEST THE FIX:"
echo "./test-call.sh +16476278084"
echo ""
echo "Jeff should now wait patiently for you to finish speaking!" 