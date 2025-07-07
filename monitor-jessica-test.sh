#!/bin/bash
source server/config.env
CALL_ID="095b29fe-ad60-42c4-b9ff-a1eeadc5b838"

echo "🔊 MONITORING JESSICA TEST CALL"
echo "================================"
echo "Testing for:"
echo "1. Number pronunciation (should say 'five thousand dollars' not '5 dollar 000')"
echo "2. Automatic call ending after 'Goodbye now'"
echo ""

while true; do
    RESPONSE=$(curl -s "https://api.vapi.ai/call/$CALL_ID" -H "Authorization: Bearer $VAPI_PRIVATE_KEY")
    STATUS=$(echo "$RESPONSE" | jq -r '.status')
    ENDED_REASON=$(echo "$RESPONSE" | jq -r '.endedReason // "Still in progress"')
    COST=$(echo "$RESPONSE" | jq -r '.cost')
    TRANSCRIPT=$(echo "$RESPONSE" | jq -r '.transcript' | tail -c 500)
    
    clear
    echo "🔊 JESSICA TEST CALL MONITOR"
    echo "============================"
    echo "📞 Status: $STATUS"
    echo "🔚 End Reason: $ENDED_REASON"
    echo "💰 Cost: $$COST"
    echo ""
    echo "📝 Last Messages:"
    echo "$TRANSCRIPT"
    echo ""
    echo "🔍 Watching for:"
    echo "- Number pronunciation"
    echo "- 'Goodbye now' → automatic call end"
    echo ""
    echo "Press Ctrl+C to stop monitoring"
    
    if [ "$STATUS" = "ended" ]; then
        echo ""
        echo "✅ CALL ENDED!"
        echo "End Reason: $ENDED_REASON"
        if [ "$ENDED_REASON" = "assistant-said-end-call-phrase" ]; then
            echo "🎉 SUCCESS: Call ended automatically after 'Goodbye now'!"
        fi
        break
    fi
    
    sleep 2
done
