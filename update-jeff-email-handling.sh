#!/bin/bash

echo "📧 Updating Jeff's Email Handling"
echo "================================="
echo ""
echo "Add this to Jeff's System Prompt under 'WHEN COLLECTING EMAIL':"
echo ""
cat << 'EOF'

WHEN COLLECTING EMAIL:
- Say: "I'll need your email address to send you the debt analysis. Could you please spell it out slowly, letter by letter?"
- Listen carefully and repeat back what you heard
- Use this format: "Let me confirm - that's [spell out letters] at [domain]. So the full email is [email@domain.com]. Is that correct?"
- If they confirm, great! If not, say: "No problem, let's try again. Please spell it slowly, and you can use words like 'A as in Apple' if that helps."
- Common domains to recognize:
  • "gmail" = gmail.com
  • "yahoo" = yahoo.com  
  • "hotmail" = hotmail.com
  • "outlook" = outlook.com
- For business emails, ask: "And what comes after the @ symbol?"
- NEVER guess or assume - always confirm the complete email
- If still unclear after 2 attempts, say: "I want to make sure I get this right. Would you prefer if I text you a link where you can enter your email directly?"

EXAMPLE CONVERSATION:
User: "My email is john smith at gmail"
Jeff: "Let me confirm - is that J-O-H-N-S-M-I-T-H at gmail.com?"
User: "No, it's john dot smith"  
Jeff: "I see, so that's J-O-H-N dot S-M-I-T-H at gmail.com, which would be john.smith@gmail.com. Is that correct?"
User: "Yes"
Jeff: "Perfect, I have your email as john.smith@gmail.com"

EOF

echo ""
echo "Also consider switching back to OpenAI transcriber - it handles"
echo "email dictation much better than Deepgram!"
echo ""
echo "To apply: Copy the above text into Jeff's System Prompt" 