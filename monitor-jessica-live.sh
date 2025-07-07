#!/bin/bash
source server/config.env
CALL_ID="f533fe8c-bd6e-442b-8f21-ff2427a1e0c0"

echo "🔊 MONITORING JESSICA'S ACTIVE CALL"
echo "===================================="
echo "📞 Call ID: $CALL_ID"
echo ""
echo "🎯 WATCHING FOR:"
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
    DURATION=$(echo "$RESPONSE" | jq -r 'if .endedAt then (((.endedAt // now | fromdateiso8601) - (.startedAt | fromdateiso8601)) | floor) else ((now - (.startedAt | fromdateiso8601)) | floor) end')
    
    # Get last few transcript messages
    TRANSCRIPT=$(echo "$RESPONSE" | jq -r '.transcript[-10:] | .[] | "\(.role): \(.message)"' 2>/dev/null || echo "Waiting for transcript...")
    
    clear
    echo "🔊 JESSICA LIVE CALL MONITOR"
    echo "============================"
    echo "📞 Status: $STATUS"
    echo "⏱️  Duration: ${DURATION}s"
    echo "🔚 End Reason: $ENDED_REASON"
    echo "💰 Cost: $$COST"
    echo ""
    echo "📝 RECENT TRANSCRIPT:"
    echo "-------------------"
    echo "$TRANSCRIPT"
    
    if [[ "$STATUS" == "ended" ]]; then
        echo ""
        echo "✅ CALL ENDED!"
        echo "End Reason: $ENDED_REASON"
        if [[ "$ENDED_REASON" == "assistant-said-end-call-phrase" ]]; then
            echo "✅ SUCCESS: Call ended automatically after 'Goodbye now'"
        else
            echo "⚠️  Call ended with: $ENDED_REASON"
        fi
        break
    fi
    
    sleep 2
done
