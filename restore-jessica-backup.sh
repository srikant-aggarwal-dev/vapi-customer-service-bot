#!/bin/bash

# 🔄 Restore Jessica from Backup
# This script restores Jessica's assistant configuration from the backup file

echo "🔄 Restoring Jessica from Backup..."
echo "Assistant ID: b34f9622-0de2-4ef6-b5ab-8bbef8f240fc"
echo ""

# Check if backup file exists
if [ ! -f "jessica-current-state-backup.json" ]; then
    echo "❌ Error: jessica-current-state-backup.json not found!"
    echo "Please make sure you have a backup file to restore from."
    exit 1
fi

# Check if VAPI_PRIVATE_KEY is set
if [ -z "$VAPI_PRIVATE_KEY" ]; then
    echo "❌ Error: VAPI_PRIVATE_KEY environment variable not set!"
    echo "Please run: export VAPI_PRIVATE_KEY='your-api-key'"
    exit 1
fi

# Extract only the configuration fields (remove metadata)
echo "📤 Preparing configuration for restore..."
jq 'del(.id, .orgId, .createdAt, .updatedAt, .isServerUrlSecretSet)' jessica-current-state-backup.json > jessica-restore-config.json

# Update the assistant
echo "📤 Restoring Jessica's configuration..."
RESPONSE=$(curl -s -X PATCH "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -H "Content-Type: application/json" \
  -d @jessica-restore-config.json)

# Check if restore was successful
if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
    echo "✅ Jessica restored successfully!"
    echo ""
    echo "📊 Restored Configuration:"
    echo "- Name: $(echo "$RESPONSE" | jq -r '.name')"
    echo "- Voice: $(echo "$RESPONSE" | jq -r '.voice.provider') ($(echo "$RESPONSE" | jq -r '.voice.voiceId'))"
    echo "- Model: $(echo "$RESPONSE" | jq -r '.model.provider')/$(echo "$RESPONSE" | jq -r '.model.model')"
    echo "- End Call Phrases: $(echo "$RESPONSE" | jq -r '.endCallPhrases')"
    echo "- Silence Timeout: $(echo "$RESPONSE" | jq -r '.silenceTimeoutSeconds') seconds"
    echo ""
    echo "🎯 Key Features Restored:"
    echo "- ✅ Asks for take-home pay (after taxes)"
    echo "- ✅ Ends calls with 'Goodbye' trigger"
    echo "- ✅ Name and email spelling confirmation"
    echo "- ✅ Complete hopeful ending message"
    echo ""
    echo "📞 Test the restored Jessica:"
    echo "   ./test-call.sh +16476278084"
    
    # Clean up temporary file
    rm -f jessica-restore-config.json
else
    echo "❌ Restore failed!"
    echo "Response: $RESPONSE"
    rm -f jessica-restore-config.json
    exit 1
fi

echo ""
echo "✅ Jessica has been restored to her saved state!" 