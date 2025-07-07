#!/bin/bash

# 🔊 JESSICA REAL-TIME CALL MONITOR WITH LIVE SUMMARIES
# This script monitors Jessica's calls in real-time and provides live summaries

# Configuration
ASSISTANT_ID="b34f9622-0de2-4ef6-b5ab-8bbef8f240fc"
API_KEY="${VAPI_PRIVATE_KEY:-4d106ac6-1ece-4856-a79c-b202ba21ef58}"
REFRESH_INTERVAL=2

# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Track active calls
declare -A ACTIVE_CALLS
declare -A CALL_SUMMARIES

clear
echo -e "${CYAN}🔊 JESSICA REAL-TIME CALL MONITOR${NC}"
echo -e "${CYAN}===================================${NC}"
echo -e "${WHITE}Assistant: Jessica (Credit Card Debt Advisor)${NC}"
echo -e "${WHITE}Monitoring calls in real-time...${NC}"
echo -e "${WHITE}Press Ctrl+C to stop${NC}"
echo ""

# Function to format duration
format_duration() {
    local seconds=$1
    if [ -z "$seconds" ] || [ "$seconds" = "null" ]; then
        echo "0s"
    else
        local minutes=$((seconds / 60))
        local remaining_seconds=$((seconds % 60))
        if [ $minutes -gt 0 ]; then
            echo "${minutes}m ${remaining_seconds}s"
        else
            echo "${remaining_seconds}s"
        fi
    fi
}

# Function to get call transcript
get_transcript() {
    local call_id=$1
    local transcript=$(curl -s -X GET "https://api.vapi.ai/call/$call_id" \
        -H "Authorization: Bearer $API_KEY" | \
        jq -r '.messages[]? | select(.role != "system") | "\(.role): \(.message)"' 2>/dev/null | \
        tail -5)
    
    if [ -z "$transcript" ]; then
        echo "No transcript yet..."
    else
        echo "$transcript"
    fi
}

# Function to analyze call progress
analyze_call_progress() {
    local call_id=$1
    local call_data=$(curl -s -X GET "https://api.vapi.ai/call/$call_id" \
        -H "Authorization: Bearer $API_KEY")
    
    local messages=$(echo "$call_data" | jq -r '.messages[]? | .message' 2>/dev/null)
    
    # Check what stage the call is at
    local stage="Starting"
    local collected_info=""
    
    if echo "$messages" | grep -qi "full name"; then
        stage="Name Collection"
    fi
    
    if echo "$messages" | grep -qi "credit card debt"; then
        stage="Understanding Situation"
    fi
    
    if echo "$messages" | grep -qi "how many.*cards\|number of credit cards"; then
        stage="Qualification Questions"
    fi
    
    if echo "$messages" | grep -qi "total.*debt\|debt amount"; then
        stage="Collecting Debt Amount"
    fi
    
    if echo "$messages" | grep -qi "monthly income"; then
        stage="Collecting Income Info"
    fi
    
    if echo "$messages" | grep -qi "monthly expenses"; then
        stage="Collecting Expenses"
    fi
    
    if echo "$messages" | grep -qi "avalanche method\|debt strategy"; then
        stage="Providing Value/Advice"
    fi
    
    if echo "$messages" | grep -qi "email address"; then
        stage="Email Collection"
    fi
    
    if echo "$messages" | grep -qi "you've got this\|goodbye"; then
        stage="Hopeful Ending"
    fi
    
    # Extract collected information
    if echo "$messages" | grep -qi "thousand dollars"; then
        collected_info="${collected_info}💰 Debt amount mentioned\n"
    fi
    
    if echo "$messages" | grep -qE "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"; then
        collected_info="${collected_info}📧 Email collected\n"
    fi
    
    echo -e "Stage: $stage"
    if [ -n "$collected_info" ]; then
        echo -e "$collected_info"
    fi
}

# Main monitoring loop
while true; do
    # Get recent calls
    CALLS=$(curl -s -X GET "https://api.vapi.ai/call?assistantId=$ASSISTANT_ID&limit=10" \
        -H "Authorization: Bearer $API_KEY")
    
    # Clear screen for fresh update
    clear
    echo -e "${CYAN}🔊 JESSICA REAL-TIME CALL MONITOR${NC}"
    echo -e "${CYAN}===================================${NC}"
    echo -e "${WHITE}Time: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo ""
    
    # Process each call
    echo "$CALLS" | jq -r '.[] | @base64' | while read -r call_encoded; do
        # Decode call data
        call=$(echo "$call_encoded" | base64 -d)
        
        # Extract call details
        call_id=$(echo "$call" | jq -r '.id')
        status=$(echo "$call" | jq -r '.status')
        customer_number=$(echo "$call" | jq -r '.customer.number')
        started_at=$(echo "$call" | jq -r '.startedAt // empty')
        ended_at=$(echo "$call" | jq -r '.endedAt // empty')
        ended_reason=$(echo "$call" | jq -r '.endedReason // empty')
        cost=$(echo "$call" | jq -r '.cost // 0')
        
        # Calculate duration
        if [ -n "$started_at" ] && [ "$started_at" != "null" ] && [ -n "$ended_at" ] && [ "$ended_at" != "null" ]; then
            start_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${started_at%%.*}" "+%s" 2>/dev/null || echo 0)
            end_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${ended_at%%.*}" "+%s" 2>/dev/null || echo 0)
            duration=$((end_epoch - start_epoch))
        else
            duration=0
        fi
        
        # Display based on status
        case "$status" in
            "queued")
                echo -e "${YELLOW}📞 QUEUED${NC} → ${customer_number}"
                echo -e "   Status: Preparing to dial..."
                ;;
            "ringing")
                echo -e "${BLUE}🔔 RINGING${NC} → ${customer_number}"
                echo -e "   Status: Waiting for answer..."
                ;;
            "in-progress")
                echo -e "${GREEN}📱 ACTIVE CALL${NC} → ${customer_number}"
                echo -e "   Duration: $(format_duration $duration)"
                echo -e "   Cost: \$$cost"
                
                # Get call progress analysis
                echo -e "   ${PURPLE}📊 Call Progress:${NC}"
                progress=$(analyze_call_progress "$call_id")
                echo "$progress" | sed 's/^/   /'
                
                # Get recent transcript
                echo -e "   ${CYAN}💬 Recent Conversation:${NC}"
                transcript=$(get_transcript "$call_id")
                echo "$transcript" | sed 's/^/   /' | head -10
                ;;
            "ended")
                # Color based on end reason
                if [ "$ended_reason" = "assistant-said-end-call-phrase" ]; then
                    echo -e "${GREEN}✅ COMPLETED${NC} → ${customer_number}"
                    echo -e "   ${GREEN}Success: Call ended properly after goodbye${NC}"
                elif [ "$ended_reason" = "silence-timeout" ]; then
                    echo -e "${YELLOW}⏱️  TIMEOUT${NC} → ${customer_number}"
                    echo -e "   ${YELLOW}Issue: Ended due to silence${NC}"
                elif [ "$ended_reason" = "customer-did-not-answer" ]; then
                    echo -e "${RED}📵 NO ANSWER${NC} → ${customer_number}"
                elif [ "$ended_reason" = "customer-busy" ]; then
                    echo -e "${RED}🚫 BUSY${NC} → ${customer_number}"
                else
                    echo -e "${WHITE}🔚 ENDED${NC} → ${customer_number}"
                    echo -e "   Reason: ${ended_reason}"
                fi
                
                echo -e "   Duration: $(format_duration $duration)"
                echo -e "   Cost: \$$cost"
                
                # Show final summary for recently ended calls
                if [ $duration -gt 30 ]; then
                    echo -e "   ${PURPLE}📊 Call Summary:${NC}"
                    progress=$(analyze_call_progress "$call_id")
                    echo "$progress" | sed 's/^/   /'
                fi
                ;;
        esac
        
        echo -e "${WHITE}─────────────────────────────────────────${NC}"
    done
    
    # Show statistics
    echo ""
    echo -e "${CYAN}📈 STATISTICS:${NC}"
    
    # Count calls by status
    active_count=$(echo "$CALLS" | jq '[.[] | select(.status == "in-progress")] | length')
    completed_count=$(echo "$CALLS" | jq '[.[] | select(.endedReason == "assistant-said-end-call-phrase")] | length')
    timeout_count=$(echo "$CALLS" | jq '[.[] | select(.endedReason == "silence-timeout")] | length')
    
    echo -e "   Active Calls: ${GREEN}$active_count${NC}"
    echo -e "   Completed Successfully: ${GREEN}$completed_count${NC}"
    echo -e "   Silence Timeouts: ${YELLOW}$timeout_count${NC}"
    
    # Key insights
    echo ""
    echo -e "${CYAN}🔍 KEY INSIGHTS:${NC}"
    
    if [ "$active_count" -gt 0 ]; then
        echo -e "   ${GREEN}• Active calls in progress${NC}"
    fi
    
    if [ "$completed_count" -gt 0 ]; then
        echo -e "   ${GREEN}• Call ending fix is working! (assistant-said-end-call-phrase)${NC}"
    fi
    
    if [ "$timeout_count" -gt 0 ]; then
        echo -e "   ${YELLOW}• Some calls still ending with silence timeout${NC}"
    fi
    
    sleep $REFRESH_INTERVAL
done 