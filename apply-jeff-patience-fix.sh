#!/bin/bash

echo "🧘 Applying Jeff's Patience Fix"
echo "==============================="
echo ""

# Load environment variables
source server/config.env

# Update Jeff with patience-focused system prompt
echo "📝 Updating Jeff with patience rules..."

UPDATE_RESPONSE=$(curl -s -X PATCH "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -H "Content-Type: application/json" \
  -d @- << 'EOF'
{
  "name": "Jeff",
  "firstMessage": "Hello! I'm Jeff, a personal finance advisor. I understand how overwhelming debt can feel, and I'm here to help. Would you like to talk about your financial situation?",
  "model": {
    "provider": "google",
    "model": "gemini-2.5-flash-preview-05-20",
    "messages": [{
      "role": "system",
      "content": "You are Jeff, a compassionate personal finance advisor helping people manage credit card debt.\n\n🔴 CRITICAL PATIENCE RULES - MUST FOLLOW:\n1. ALWAYS wait for complete silence for at least 2-3 seconds before responding\n2. If someone pauses or says 'um' or 'uh', WAIT - they are still thinking\n3. NEVER interrupt, even if you think you know what they'll say\n4. Count to 3 in your head after they stop before you speak\n5. If they start speaking again while you're talking, IMMEDIATELY STOP\n\nCONVERSATION STYLE:\n- Give brief acknowledgments: 'I see', 'Mm-hmm', 'I understand'\n- Keep responses SHORT (1-2 sentences max)\n- Ask ONE question at a time\n- WAIT for their COMPLETE answer\n\nABSOLUTE FORBIDDEN WORDS/PHRASES:\n- NEVER say: 'function', 'tool', 'system', 'capture', 'save', 'store', 'record'\n- NEVER say: 'let me call', 'let me use', 'I'll activate', 'I'll trigger'\n- NEVER announce any actions - just DO them silently\n\nKEY INFO TO GATHER:\n- Email (confirm it sounds right)\n- Total debt amount\n- Monthly income\n- Monthly expenses\n- Debt types\n- Financial goals\n\nWHEN COLLECTING EMAIL:\n- Ask them to say it naturally\n- Confirm: 'Got it, [email]. Is that correct?'\n- If unclear, ask them to repeat slowly\n\nSCHEDULING MEETINGS:\n- Say: 'I'd be happy to schedule a consultation. Would tomorrow or Friday work better?'\n- Ask for preferred time naturally\n- Never mention tools or systems\n\nENDING CALLS:\nWhen user says goodbye/bye/thanks/hang up/talk later:\n1. Say ONLY: 'Thanks for calling. Take care!'\n2. Use end_call function immediately\n3. Don't say anything else\n\nREMEMBER: Patience is your #1 priority. Better to wait too long than interrupt."
    }]
  },
  "silenceTimeoutSeconds": 10,
  "responseDelaySeconds": 1,
  "backgroundDenoisingEnabled": true
}
EOF
)

# Check if update was successful
if echo "$UPDATE_RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
    echo "✅ SUCCESS! Jeff has been updated with patience rules."
    echo ""
    echo "🎯 What I've done:"
    echo "• Added strong patience instructions to Jeff's behavior"
    echo "• Set him to wait 2-3 seconds before responding"
    echo "• Increased silence timeout to 10 seconds"
    echo "• Added response delay of 1 second"
    echo ""
else
    echo "❌ Update failed. Error:"
    echo "$UPDATE_RESPONSE" | jq .
    echo ""
fi

echo "📋 DASHBOARD SETTINGS STILL NEEDED:"
echo ""
echo "For best results, also adjust these in Vapi Dashboard:"
echo ""
echo "1. Go to: https://dashboard.vapi.ai/assistants"
echo "2. Click on 'Jeff' assistant"
echo ""
echo "3. In 'Transcriber' section, click Advanced Settings:"
echo "   • Provider: OpenAI (keep as is)"
echo "   • Model: gpt-4o-transcribe (keep as is)"
echo "   • Enable 'Smart Endpointing' ✓"
echo "   • End of Speech Threshold: 1500ms"
echo "   • Speech Detection Sensitivity: 0.3"
echo ""
echo "4. In 'Voice' section, click Advanced Settings:"
echo "   • Provider: ElevenLabs (keep as is)"
echo "   • Voice: Adam (keep as is)"
echo "   • Enable 'Interruption Sensitivity Override' ✓"
echo "   • Interruption Sensitivity: 0.8"
echo "   • Enable 'Background Noise Suppression' ✓"
echo ""
echo "5. Click 'Save' at the bottom"
echo ""
echo "🧪 TEST THE FIX:"
echo "./test-call.sh +16476278084"
echo ""
echo "Jeff should now:"
echo "✓ Wait patiently for you to finish"
echo "✓ Not interrupt mid-sentence"
echo "✓ Give you time to think"
echo "✓ Respond only after you're done speaking" 