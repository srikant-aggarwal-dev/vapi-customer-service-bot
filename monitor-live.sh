#!/bin/bash
source server/config.env
CALL_ID="9ae76c75-65f2-41d0-88e0-ce70ed26fcac"

echo "🔊 MONITORING JESSICA'S LIVE TEST CALL"
echo "====================================="
echo "📞 Call ID: $CALL_ID"
echo ""
echo "🎯 TESTING FOR:"
echo "1. Number pronunciation: Should say 'five thousand dollars'"
echo "2. Automatic ending: Should end after 'Goodbye now'"
echo ""
echo "Press Ctrl+C to stop monitoring"
echo ""

while true; do
    RESPONSE=$(curl -s "https://api.vapi.ai/call/$CALL_ID" -H "Authorization: Bearer $VAPI_PRIVATE_KEY")
    STATUS=$(echo "$RESPONSE" | jq -r '.status')
    ENDED_REASON=$(echo "$RESPONSE" | jq -r '.endedReason // "Still active"')
    COST=$(echo "$RESPONSE" | jq -r '.cost')
    
    # Get last few transcript messages
    TRANSCRIPT=$(echo "$RESPONSE" | jq -r '.transcript[-5:] | .[] | "\(.role): \(.message)"' 2>/dev/null || echo "Waiting for transcript...")
    
    clear
    echo "🔊 JESSICA LIVE CALL MONITOR"
    echo "============================"
    echo "📞 Status: $STATUS"
    echo "🔚 End Reason: $ENDED_REASON"
    echo "💰 Cost: $$COST"
    echo ""
    echo "📝 Recent Conversation:"
    echo "------------------------"
    echo "$TRANSCRIPT"
    echo ""
    
    if [ "$STATUS" = "ended" ]; then
        echo "✅ CALL ENDED!"
        echo "End Reason: $ENDED_REASON"
        if [ "$ENDED_REASON" = "assistant-said-end-call-phrase" ]; then
            echo "🎉 SUCCESS: Jessica ended the call automatically!"
        else
            echo "❌ Call ended with: $ENDED_REASON"
        fi
        break
    fi
    
    sleep 2
done
