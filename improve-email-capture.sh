#!/bin/bash

echo "🎯 Improving Email Capture Accuracy for Jeff"
echo "==========================================="
echo ""
echo "PROBLEM: Deepgram STT struggles with spelled-out emails, especially:"
echo "• Non-English names (Shirisha, Pradeep, etc.)"
echo "• Similar sounding letters (B/P, D/T, M/N)"
echo "• Fast spelling over phone"
echo ""
echo "SOLUTION OPTIONS:"
echo ""
echo "1️⃣ UPGRADE STT MODEL (Recommended)"
echo "   In Vapi Dashboard → Jeff's Assistant → Transcriber:"
echo "   • Provider: OpenAI"
echo "   • Model: whisper-1"
echo "   • Cost: ~$0.006/minute extra"
echo "   • Benefit: Much better with names & spelling"
echo ""
echo "2️⃣ UPDATE JEFF'S PROMPTING"
echo "   Add to system message:"
echo "   ```"
echo "   When collecting email:"
echo "   - Ask them to speak slowly"
echo "   - Repeat back each letter: 'S as in Sam, H as in Hotel...'"
echo "   - Use phonetic alphabet if unclear"
echo "   - Confirm the full email twice"
echo "   ```"
echo ""
echo "3️⃣ USE EMAIL VALIDATION TOOL"
echo "   Add a function to Jeff that:"
echo "   • Validates email format"
echo "   • Checks common misspellings"
echo "   • Suggests corrections"
echo ""
echo "4️⃣ ALTERNATIVE: TEXT-BASED COLLECTION"
echo "   • 'I'll text you a link to enter your email'"
echo "   • Send SMS with form link"
echo "   • 100% accurate, no transcription errors"
echo ""
echo "QUICK FIX - Update System Message:"
cat << 'EOF'

When collecting email, use this approach:
1. "Could you please spell your email slowly, one letter at a time?"
2. Repeat each letter back: "S as in Sierra... H as in Hotel..."
3. After getting full email, spell it back completely
4. If any confusion, use NATO phonetic alphabet:
   A=Alpha, B=Bravo, C=Charlie, D=Delta, E=Echo, F=Foxtrot,
   G=Golf, H=Hotel, I=India, J=Juliet, K=Kilo, L=Lima,
   M=Mike, N=November, O=Oscar, P=Papa, Q=Quebec, R=Romeo,
   S=Sierra, T=Tango, U=Uniform, V=Victor, W=Whiskey,
   X=X-ray, Y=Yankee, Z=Zulu

Example:
User: "It's shirisha"
Jeff: "Let me spell that back - S as in Sierra, H as in Hotel, I as in India, R as in Romeo, I as in India, S as in Sierra, H as in Hotel, A as in Alpha. So that's SHIRISHA, correct?"
EOF

echo ""
echo "📊 COMPARISON:"
echo "Deepgram nova-2: Fast but struggles with names"
echo "OpenAI Whisper: Slower but much more accurate"
echo "Cost difference: ~$0.36/hour extra for Whisper"
echo ""
echo "💡 For a financial advisor bot, accuracy > speed!" 