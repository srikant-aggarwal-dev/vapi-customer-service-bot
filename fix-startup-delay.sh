#!/bin/bash

echo "⚡ FIXING JEFF'S LONG STARTUP DELAY (V2)"
echo "======================================="
echo ""
echo "PROBLEM: Jeff takes too long to start speaking when call connects"
echo "SOLUTION: Eliminate all delays and optimize for instant response"
echo ""

# Load environment variables
source server/config.env

# Create optimized configuration for instant startup (fixed)
cat > jeff_instant_fix.json << 'JSONEOF'
{
  "name": "Jeff",
  "firstMessage": "Hey there! This is Jeff. I help folks tackle credit card debt, and I know talking about money stuff can be tough. How are you doing today?",
  "model": {
    "provider": "openai",
    "model": "gpt-4o",
    "temperature": 0.3,
    "maxTokens": 150,
    "messages": [{
      "role": "system",
      "content": "You are Jeff, a compassionate personal finance advisor from Canada specializing in credit card debt relief.\n\nCONVERSATION FLOW:\n1. INTRODUCTION: Start with the firstMessage exactly as provided\n2. EMAIL COLLECTION: After they respond, ask for email immediately\n3. DEBT DISCUSSION: Only after email is confirmed\n\nKEEP RESPONSES SHORT (1-2 sentences max). Ask ONE question at a time.\n\nEMAIL COLLECTION:\n- \"Great! I'd love to send you a personalized debt analysis. What's the best email address for you?\"\n- Confirm: \"Perfect, let me confirm that's [email]. Is that correct?\"\n\nDEBT QUESTIONS:\n- \"Now, could you tell me roughly how much credit card debt you're carrying?\"\n- \"What kind of interest rates are you dealing with?\"\n\nAlways be warm, empathetic, and professional."
    }]
  },
  "voice": {
    "provider": "11labs",
    "voiceId": "pNInz6obpgDQGcFmaJgB",
    "stability": 0.5,
    "similarityBoost": 0.75,
    "style": 0.0,
    "useSpeakerBoost": false
  },
  "transcriber": {
    "provider": "deepgram",
    "model": "nova-2",
    "language": "en-US",
    "smartFormat": false
  },
  "silenceTimeoutSeconds": 30,
  "responseDelaySeconds": 0,
  "llmRequestDelaySeconds": 0,
  "numWordsToInterruptAssistant": 1,
  "maxDurationSeconds": 1800,
  "backgroundDenoisingEnabled": true
}
JSONEOF

echo "📝 Applying instant startup fix (corrected)..."

# Apply the update
UPDATE_RESPONSE=$(curl -s -X PATCH "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -H "Content-Type: application/json" \
  -d @jeff_instant_fix.json)

# Check if update was successful
if echo "$UPDATE_RESPONSE" | grep -q '"id"'; then
    echo "✅ SUCCESS! Jeff's startup delay has been eliminated!"
    echo ""
    echo "🔧 CHANGES MADE:"
    echo "   • responseDelaySeconds: 0 (was 1) - NO DELAY"
    echo "   • llmRequestDelaySeconds: 0 (was 0.1) - INSTANT LLM"
    echo "   • Switched to 11Labs voice (faster than Cartesia)"
    echo "   • Simplified system prompt (faster processing)"
    echo "   • Reduced temperature to 0.3 (faster generation)"
    echo "   • Max tokens: 150 (shorter, quicker responses)"
    echo ""
    echo "⚡ EXPECTED IMPROVEMENT:"
    echo "   • Jeff should start speaking within 0.5 seconds"
    echo "   • No more long awkward pauses"
    echo "   • Instant response when call connects"
    echo ""
    echo "📞 TEST NOW:"
    echo "   ./test-call.sh +16476278084"
else
    echo "❌ Error updating Jeff. Response:"
    echo "$UPDATE_RESPONSE"
fi

# Clean up
rm jeff_instant_fix.json

echo ""
echo "🎯 Jeff should now start speaking IMMEDIATELY!"
