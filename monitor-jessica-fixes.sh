#!/bin/bash
source server/config.env
CALL_ID="f533fe8c-bd6e-442b-8f21-ff2427a1e0c0"

echo "🔊 MONITORING JESSICA WITH ALL FIXES"
echo "===================================="
echo "📞 Call ID: $CALL_ID"
echo ""
echo "🎯 TESTING FOR:"
echo "1. Natural patience (no excessive 'take your time')"
echo "2. Number pronunciation ('five thousand dollars')"
echo "3. Complete hopeful ending (3-4 sentences)"
echo "4. Automatic call ending after 'Goodbye now'"
echo ""

while true; do
    RESPONSE=$(curl -s "https://api.vapi.ai/call/$CALL_ID" -H "Authorization: Bearer $VAPI_PRIVATE_KEY")
    STATUS=$(echo "$RESPONSE" | jq -r '.status')
    ENDED_REASON=$(echo "$RESPONSE" | jq -r '.endedReason // "Still active"')
    COST=$(echo "$RESPONSE" | jq -r '.cost')
    
    # Get last few transcript messages
    TRANSCRIPT=$(echo "$RESPONSE" | jq -r '.transcript[-8:] | .[] | "\(.role): \(.message)"' 2>/dev/null || echo "Waiting for transcript...")
    
    clear
    echo "🔊 JESSICA TEST - ALL FIXES APPLIED"
    echo "==================================="
    echo "📞 Status: $STATUS"
    echo "🔚 End Reason: $ENDED_REASON"
    echo "💰 Cost: $$COST"
    echo ""
    echo "📝 Recent Conversation:"
    echo "------------------------"
    echo "$TRANSCRIPT"
    echo ""
    echo "👀 Watching for:"
    echo "- Natural conversation flow"
    echo "- Proper number pronunciation"
    echo "- Full hopeful ending message"
    echo "- Automatic call termination"
    echo ""
    
    if [ "$STATUS" = "ended" ]; then
        echo "✅ CALL ENDED!"
        echo "End Reason: $ENDED_REASON"
        if [ "$ENDED_REASON" = "assistant-said-end-call-phrase" ]; then
            echo "🎉 SUCCESS: Call ended automatically after 'Goodbye now'!"
        else
            echo "❌ Call ended with: $ENDED_REASON"
        fi
        
        # Get full transcript for analysis
        echo ""
        echo "📋 Full Call Analysis:"
        echo "====================="
        FULL_TRANSCRIPT=$(echo "$RESPONSE" | jq -r '.transcript')
        
        # Check for excessive patience language
        PATIENCE_COUNT=$(echo "$FULL_TRANSCRIPT" | grep -i "take your time" | wc -l)
        echo "- 'Take your time' count: $PATIENCE_COUNT"
        
        # Check for number pronunciation
        if echo "$FULL_TRANSCRIPT" | grep -q "dollar.*000"; then
            echo "- ❌ Found incorrect number pronunciation"
        else
            echo "- ✅ No incorrect number pronunciation found"
        fi
        
        # Check for hopeful ending
        if echo "$FULL_TRANSCRIPT" | grep -q "getting out of debt is absolutely possible"; then
            echo "- ✅ Found complete hopeful ending message"
        else
            echo "- ❌ Missing complete hopeful ending"
        fi
        
        break
    fi
    
    sleep 2
done
