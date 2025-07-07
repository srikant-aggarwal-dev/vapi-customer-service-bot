#!/bin/bash

# Real-time Vapi Call Monitor
# Monitors calls for Jeff and displays updates as they happen

# Load API key
if [ -f "server/config.env" ]; then
    export $(grep -v '^#' server/config.env | xargs)
fi

if [ -z "$VAPI_PRIVATE_KEY" ]; then
    echo "❌ Error: VAPI_PRIVATE_KEY not found in server/config.env"
    exit 1
fi

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Clear screen and show header
clear
echo -e "${BOLD}${CYAN}🔊 VAPI CALL MONITOR - JEFF THE FINANCIAL ADVISOR${NC}"
echo -e "${BOLD}${CYAN}================================================${NC}"
echo -e "Phone: ${YELLOW}+1 (431) 341-5863${NC} (Manitoba, Canada)"
echo -e "Assistant ID: ${BLUE}b34f9622-0de2-4ef6-b5ab-8bbef8f240fc${NC}"
echo -e "Refreshing every 2 seconds... Press ${RED}Ctrl+C${NC} to stop"
echo ""

# Store seen call IDs to detect new calls
SEEN_CALLS=""
FIRST_RUN=true

while true; do
    # Get the last 5 calls
    RESPONSE=$(curl --location 'https://api.vapi.ai/call?assistantId=b34f9622-0de2-4ef6-b5ab-8bbef8f240fc&limit=5' \
        --header "Authorization: Bearer $VAPI_PRIVATE_KEY" \
        --silent)
    
    # Parse calls
    CALLS=$(echo "$RESPONSE" | jq -r '.[] | @base64' 2>/dev/null)
    
    if [ -z "$CALLS" ]; then
        echo -e "${RED}⚠️  No calls found or API error${NC}"
    else
        # Clear screen for updates (but keep header)
        if [ "$FIRST_RUN" = false ]; then
            # Move cursor to line 7 (after header)
            tput cup 6 0
            tput ed  # Clear from cursor to end of screen
        fi
        FIRST_RUN=false
        
        # Process each call
        while IFS= read -r call_base64; do
            if [ -n "$call_base64" ]; then
                # Decode call data
                CALL=$(echo "$call_base64" | base64 --decode)
                
                # Extract call details
                CALL_ID=$(echo "$CALL" | jq -r '.id')
                STATUS=$(echo "$CALL" | jq -r '.status')
                CUSTOMER=$(echo "$CALL" | jq -r '.customer.number // "Unknown"')
                STARTED=$(echo "$CALL" | jq -r '.startedAt // "Not started"')
                ENDED=$(echo "$CALL" | jq -r '.endedAt // "In progress"')
                END_REASON=$(echo "$CALL" | jq -r '.endedReason // "N/A"')
                COST=$(echo "$CALL" | jq -r '.cost // 0')
                TRANSCRIPT=$(echo "$CALL" | jq -r '.transcript // "No transcript yet"' | tr '\n' ' ' | cut -c 1-100)
                
                # Check if this is a new call
                if [[ ! "$SEEN_CALLS" =~ "$CALL_ID" ]]; then
                    echo -e "${GREEN}${BOLD}🆕 NEW CALL DETECTED!${NC}"
                    SEEN_CALLS="$SEEN_CALLS $CALL_ID"
                fi
                
                # Format status with colors
                case "$STATUS" in
                    "queued")
                        STATUS_COLOR="${YELLOW}📞 QUEUED${NC}"
                        ;;
                    "ringing")
                        STATUS_COLOR="${YELLOW}🔔 RINGING${NC}"
                        ;;
                    "in-progress")
                        STATUS_COLOR="${GREEN}📱 IN PROGRESS${NC}"
                        ;;
                    "forwarding")
                        STATUS_COLOR="${BLUE}↪️  FORWARDING${NC}"
                        ;;
                    "ended")
                        case "$END_REASON" in
                            "assistant-error"|"error")
                                STATUS_COLOR="${RED}❌ ENDED (Error)${NC}"
                                ;;
                            "assistant-not-found")
                                STATUS_COLOR="${RED}❌ ENDED (Assistant not found)${NC}"
                                ;;
                            "silence-timed-out")
                                STATUS_COLOR="${YELLOW}⏱️  ENDED (Silence timeout)${NC}"
                                ;;
                            "voicemail")
                                STATUS_COLOR="${MAGENTA}📬 ENDED (Voicemail)${NC}"
                                ;;
                            *)
                                STATUS_COLOR="${CYAN}✅ ENDED${NC}"
                                ;;
                        esac
                        ;;
                    *)
                        STATUS_COLOR="${BLUE}$STATUS${NC}"
                        ;;
                esac
                
                # Display call info
                echo -e "${BOLD}Call to: ${CYAN}$CUSTOMER${NC}"
                echo -e "Status: $STATUS_COLOR"
                echo -e "Cost: ${GREEN}\$$COST${NC}"
                
                # Show timing
                if [ "$STARTED" != "Not started" ]; then
                    START_TIME=$(date -r $(echo "$STARTED" | xargs -I {} node -e "console.log(Math.floor(new Date('{}').getTime()/1000))") "+%I:%M:%S %p" 2>/dev/null || echo "$STARTED")
                    echo -e "Started: ${YELLOW}$START_TIME${NC}"
                fi
                
                if [ "$ENDED" != "In progress" ] && [ "$ENDED" != "null" ]; then
                    # Calculate duration
                    if [ "$STARTED" != "Not started" ] && [ "$STARTED" != "null" ]; then
                        START_SEC=$(echo "$STARTED" | xargs -I {} node -e "console.log(Math.floor(new Date('{}').getTime()/1000))" 2>/dev/null || echo "0")
                        END_SEC=$(echo "$ENDED" | xargs -I {} node -e "console.log(Math.floor(new Date('{}').getTime()/1000))" 2>/dev/null || echo "0")
                        if [ "$START_SEC" != "0" ] && [ "$END_SEC" != "0" ]; then
                            DURATION=$((END_SEC - START_SEC))
                            MINUTES=$((DURATION / 60))
                            SECONDS=$((DURATION % 60))
                            echo -e "Duration: ${CYAN}${MINUTES}m ${SECONDS}s${NC}"
                        fi
                    fi
                fi
                
                # Show transcript preview
                if [ "$TRANSCRIPT" != "No transcript yet" ] && [ "$TRANSCRIPT" != "null" ]; then
                    echo -e "Last message: ${MAGENTA}\"$TRANSCRIPT...\"${NC}"
                fi
                
                echo -e "${CYAN}─────────────────────────────────────────${NC}"
            fi
        done <<< "$CALLS"
    fi
    
    # Show last update time
    echo -e "\n${YELLOW}Last updated: $(date '+%I:%M:%S %p')${NC}"
    
    # Wait 2 seconds before refreshing
    sleep 2
done 