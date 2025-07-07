#!/bin/bash

# 🚀 Update Jessica with Improved Name and Email Collection
# This script updates Jessica to always ask for spelling of names and emails

echo "🔄 Updating Jessica with Name & Email Improvements..."
echo "Assistant ID: b34f9622-0de2-4ef6-b5ab-8bbef8f240fc"
echo ""
echo "📝 Key Improvements:"
echo "1. Always asks to spell names (no more wrong names like 'Sudett' instead of 'Sudip')"
echo "2. Always asks to spell emails letter by letter"
echo "3. Uses phonetic alphabet for unclear letters (B as in Boy, P as in Peter)"
echo "4. Confirms both name pronunciation and spelling"
echo ""

# Check if config file exists
if [ ! -f "jessica-improved-name-email.json" ]; then
    echo "❌ Error: jessica-improved-name-email.json not found!"
    exit 1
fi

# Check if VAPI_PRIVATE_KEY is set
if [ -z "$VAPI_PRIVATE_KEY" ]; then
    echo "❌ Error: VAPI_PRIVATE_KEY environment variable not set!"
    echo "Please run: export VAPI_PRIVATE_KEY='your-api-key'"
    exit 1
fi

# Read the JSON config
CONFIG=$(cat jessica-improved-name-email.json)

# Update the assistant
echo "📤 Sending update to VAPI..."
RESPONSE=$(curl -s -X PATCH "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -H "Content-Type: application/json" \
  -d "$CONFIG")

# Check if update was successful
if echo "$RESPONSE" | grep -q '"id"'; then
    echo "✅ Jessica updated successfully!"
    echo ""
    echo "🎯 New Conversation Flow:"
    echo ""
    echo "NAME COLLECTION:"
    echo "Jessica: 'Before we chat, could I get your full name please?'"
    echo "User: 'Sudip Pantacharya'"
    echo "Jessica: 'I want to make sure I have your name right - could you please spell that for me?'"
    echo "User: 'S-U-D-I-P P-A-N-T-A-C-H-A-R-Y-A'"
    echo "Jessica: 'Perfect! So that's Sudip Pantacharya. Did I pronounce that correctly?'"
    echo ""
    echo "EMAIL COLLECTION:"
    echo "Jessica: 'What's the best email address to reach you?'"
    echo "User: 'prudent.sudip@gmail.com'"
    echo "Jessica: 'Could you please spell that out for me, letter by letter?'"
    echo "User: 'P-R-U-D-E-N-T dot S-U-D-I-P at gmail'"
    echo "Jessica: 'So the full email is prudent.sudip@gmail.com. Is that correct?'"
    echo ""
    echo "📞 Test the updated Jessica:"
    echo "   ./test-call.sh +16476278084"
else
    echo "❌ Update failed!"
    echo "Response: $RESPONSE"
    exit 1
fi

echo ""
echo "✅ Jessica will now always ask for spelling to ensure accuracy!"
echo "No more wrong names or incorrect emails!" 