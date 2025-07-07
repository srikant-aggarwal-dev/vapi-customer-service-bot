#!/bin/bash

echo "🔧 Fixing Jeff's Repetitive Question Problem"
echo "==========================================="
echo ""
echo "ISSUES IDENTIFIED:"
echo "1. Jeff asked about debt 3 times in a row"
echo "2. Didn't recognize user already agreed"
echo "3. Poor conversation flow"
echo ""
echo "ROOT CAUSES:"
echo "• Jeff's prompt doesn't track conversation state well"
echo "• He's too focused on the script"
echo "• Silence timeout might be too aggressive (30 seconds)"
echo ""
echo "SOLUTION - Update Jeff's System Prompt:"
echo ""
cat << 'EOF'
CONVERSATION FLOW - IMPORTANT CHANGES:
1. Start with empathy, ask if they want to talk about their debt
2. CRITICAL: If user says ANY of these, MOVE ON to email:
   - "Hi" / "Hello" / "Hey"
   - "Yes" / "Yeah" / "Sure" / "Okay"
   - Any positive response
   DO NOT ask about debt again!

3. After ANY positive response, IMMEDIATELY ask:
   "What's the best email to send you a personalized plan?"

AVOID REPETITION:
- NEVER ask the same question twice
- If user responds AT ALL to your greeting, assume they want to talk
- Move forward in the conversation, don't loop back

HANDLING UNCLEAR RESPONSES:
- If you don't understand, say: "Sorry, I didn't catch that. Could you repeat?"
- Don't repeat your previous question
- Assume positive intent - if unsure, move forward

INTERRUPTION SETTINGS:
- Wait for user to finish speaking
- Don't interrupt mid-sentence
- Give 2-3 seconds pause after they speak
EOF

echo ""
echo "ADDITIONAL FIXES:"
echo ""
echo "1️⃣ ADJUST INTERRUPTION SENSITIVITY"
echo "   In Vapi Dashboard → Jeff → Advanced Settings:"
echo "   • Enable 'Background Denoising'"
echo "   • Set 'Interruption Sensitivity' to 0.7 (less aggressive)"
echo "   • Enable 'Smart Endpointing'"
echo ""
echo "2️⃣ TEST WITH CLEAR AUDIO"
echo "   • Use headphones with built-in mic"
echo "   • Speak clearly and wait for Jeff to finish"
echo "   • Avoid background noise"
echo ""
echo "3️⃣ MONITOR TRANSCRIPTION QUALITY"
echo "   If STT still struggles:"
echo "   • Check microphone quality"
echo "   • Ensure good internet connection"
echo "   • Consider testing with different phone"
echo ""
echo "📝 QUICK FIX CHECKLIST:"
echo "□ Update Jeff's system prompt (avoid repetition)"
echo "□ Adjust interruption settings in Vapi"
echo "□ Test with good audio equipment"
echo "□ Monitor if 'chef' vs 'Jeff' issue persists" 