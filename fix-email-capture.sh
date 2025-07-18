#!/bin/bash

echo "📧 Fixing Email Capture Issues"
echo "==============================="
echo ""
echo "Common problem: STT struggles with emails like:"
echo "• 'john dot smith at gmail dot com'"
echo "• 'j.smith@company.com'"
echo "• Mixing letters and spelling"
echo ""
echo "🛠️ SOLUTION OPTIONS:"
echo ""
echo "1️⃣ SWITCH BACK TO OPENAI for Transcriber"
echo "   • OpenAI GPT-4o often handles emails better"
echo "   • More expensive but more accurate"
echo ""
echo "2️⃣ UPDATE JEFF'S PROMPT for better email handling:"
echo "   Add these lines to System Prompt:"
echo ""
echo "   WHEN COLLECTING EMAIL:"
echo "   - Say: 'I'll need your email. Please spell it out slowly,'"
echo "   - 'letter by letter, including the domain.'"
echo "   - After they spell it: 'Let me read that back...'"
echo "   - 'J-O-H-N at G-M-A-I-L dot com. Is that correct?'"
echo "   - If they say yes, convert to: john@gmail.com"
echo "   - If unclear, ask: 'Could you spell that again slowly?'"
echo ""
echo "3️⃣ USE DTMF (Phone Keypad) for email collection:"
echo "   • Enable 'Dial Keypad' in Vapi"
echo "   • Have users type email using phone keys"
echo "   • More reliable but less natural"
echo ""
echo "4️⃣ BEST APPROACH: Phonetic Alphabet"
echo "   Update prompt to say:"
echo "   'Please spell your email using words for letters,'"
echo "   'like A as in Apple, B as in Boy...'"
echo ""
echo "5️⃣ ALTERNATIVE: Skip email on phone"
echo "   • Collect basic info on call"
echo "   • Send SMS/web link for email entry"
echo ""
echo "💡 RECOMMENDED: Try OpenAI transcriber first!"
echo "   It's specifically trained for these scenarios." 