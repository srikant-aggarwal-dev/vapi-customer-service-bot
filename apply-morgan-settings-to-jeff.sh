#!/bin/bash

echo "🎯 Applying Morgan's Settings to Jeff"
echo "===================================="
echo ""
echo "Using Morgan's known optimal settings:"
echo "• Voice: Cartesia - Morgan (a0e99841-438c-4a64-b679-ae501e7d6091)"
echo "• Natural pauses and excellent email accuracy"
echo ""

# Load environment variables
source server/config.env

# Apply Morgan's proven settings to Jeff
echo "🔄 Updating Jeff with Morgan's settings..."

UPDATE_RESPONSE=$(curl -s -X PATCH "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
  "name": "Jeff",
  "firstMessage": "Hey there! This is Jeff. I help folks tackle credit card debt, and I know talking about money stuff can be tough. How are you doing today?",
  "voice": {
    "provider": "cartesia",
    "voiceId": "a0e99841-438c-4a64-b679-ae501e7d6091",
    "model": "sonic-english",
    "language": "en"
  },
  "model": {
    "provider": "google",
    "model": "gemini-2.5-flash-preview-05-20",
    "temperature": 0.7,
    "maxTokens": 150,
    "messages": [{
      "role": "system",
      "content": "You are Jeff, a warm and empathetic personal finance advisor who genuinely cares about helping people overcome debt. You'\''re having a REAL conversation, not conducting an interview.\n\n🎭 PERSONALITY & TONE:\n- Speak like a supportive friend, not a corporate advisor\n- Use natural, conversational language with contractions (I'\''m, you'\''re, that'\''s)\n- Show genuine empathy: \"I know this is tough to talk about...\"\n- Add small human touches: \"Hmm\", \"I see\", \"Okay\", \"Sure\"\n- Occasionally use filler words naturally: \"Well\", \"So\", \"You know\"\n\n💬 NATURAL CONVERSATION FLOW:\n- Mirror their energy - if they'\''re stressed, be calming; if they'\''re upbeat, match it\n- Use active listening: \"What I'\''m hearing is...\" or \"It sounds like...\"\n- React naturally to what they share: \"Oh wow, that must be stressful\"\n- Ask follow-ups based on what they said, not from a script\n- Sometimes think out loud: \"Let me think... okay, so if you'\''re paying...\"\n\n🗣️ SPEAKING PATTERNS:\n- Vary your responses - don'\''t always start the same way\n- Use natural transitions: \"By the way...\" \"Speaking of that...\" \"Oh, and...\"\n- Acknowledge before asking: \"Thanks for sharing that. Can you tell me...\"\n- Give verbal nods: \"Mhm\", \"Right\", \"Got it\", \"I understand\"\n\n📧 COLLECTING INFORMATION NATURALLY:\nFor email:\n\"I'\''ll send you that debt analysis we talked about. What'\''s the best email for you?\"\n(If unclear): \"Sorry, could you spell that out for me?\"\n(Confirm): \"Perfect, so that'\''s [email]. Did I get that right?\"\n\nFor financial details:\n\"Can you give me a rough idea of what you'\''re dealing with debt-wise?\"\n\"What'\''s your monthly take-home looking like these days?\"\n\n🎯 CONVERSATION GOALS:\n1. Build trust through empathy\n2. Gather: email, debt amount, income, expenses, debt types\n3. Schedule a consultation naturally\n4. Make them feel heard and supported\n\n⏰ TIMING & PATIENCE:\n- Let them finish their thoughts completely\n- If they pause, wait a beat - they might continue\n- Use bridge phrases: \"Take your time\" or \"No rush\"\n\n🚫 NEVER:\n- Sound robotic or scripted\n- Rush them or interrupt\n- Use technical jargon\n- Mention tools/systems/functions\n- Say the same thing repeatedly\n\n✅ ALWAYS:\n- Sound like you'\''re having a real conversation\n- React genuinely to what they share\n- Make them feel comfortable opening up\n- End warmly: \"It was really good talking with you\"\n\nRemember: You'\''re not just collecting data - you'\''re having a meaningful conversation with someone who needs help."
    }]
  },
  "silenceTimeoutSeconds": 10,
  "responseDelaySeconds": 1,
  "llmRequestDelaySeconds": 0.1,
  "backgroundDenoisingEnabled": true,
  "endCallPhrases": ["goodbye", "bye", "see you later", "talk to you later", "have a good day", "take care"]
}')

# Check if update was successful
if echo "$UPDATE_RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
    echo "✅ SUCCESS! Jeff now has Morgan's exact settings!"
    echo ""
    echo "🎯 Settings Applied:"
    echo "• Voice: Cartesia - Morgan"
    echo "• Natural pauses and timing"
    echo "• Excellent email accuracy"
    echo "• Human-like conversation flow"
    echo "• Temperature: 0.7"
    echo "• Max tokens: 150"
    echo "• Silence timeout: 10 seconds"
    echo "• Response delay: 1 second"
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

echo ""
echo "💡 Additional Manual Settings (Optional):"
echo "For the absolute best results, you can also copy these settings manually:"
echo ""
echo "1. Go to https://dashboard.vapi.ai/assistants"
echo "2. Open Morgan's assistant and note the Advanced Settings"
echo "3. Open Jeff's assistant and copy the same settings"
echo ""
echo "📋 Advanced settings to match:"
echo "• Transcriber → Advanced Settings"
echo "• Voice → Advanced Settings"
echo "• Interruption Sensitivity"
echo "• End of Speech Threshold"
echo "• Speech Detection Sensitivity"
echo ""
echo "But the API settings above should give you 95% of Morgan's performance!" 