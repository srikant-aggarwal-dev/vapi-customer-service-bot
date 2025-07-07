#!/bin/bash

# 💾 Backup Jessica's Current State
# This script creates a timestamped backup of Jessica's assistant configuration

echo "💾 Backing up Jessica's current state..."
echo "Assistant ID: b34f9622-0de2-4ef6-b5ab-8bbef8f240fc"
echo ""

# Check if VAPI_PRIVATE_KEY is set
if [ -z "$VAPI_PRIVATE_KEY" ]; then
    echo "❌ Error: VAPI_PRIVATE_KEY environment variable not set!"
    echo "Please run: export VAPI_PRIVATE_KEY='4d106ac6-1ece-4856-a79c-b202ba21ef58'"
    exit 1
fi

# Create timestamped backup filename
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="jessica-backup-${TIMESTAMP}.json"

echo "📥 Downloading current configuration..."
curl -s -X GET "https://api.vapi.ai/assistant/b34f9622-0de2-4ef6-b5ab-8bbef8f240fc" \
     -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
     | jq '.' > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Backup created successfully!"
    echo "📁 File: $BACKUP_FILE"
    echo "📊 Size: $(ls -lh "$BACKUP_FILE" | awk '{print $5}')"
    echo ""
    echo "🔄 To restore from this backup later:"
    echo "   ./restore-jessica-backup.sh $BACKUP_FILE"
    echo ""
    echo "📋 Current configuration summary:"
    jq -r '"Name: " + .name' "$BACKUP_FILE"
    jq -r '"Voice: " + .voice.provider + " (" + .voice.voiceId + ")"' "$BACKUP_FILE"
    jq -r '"Model: " + .model.provider + "/" + .model.model' "$BACKUP_FILE"
    jq -r '"End Call Phrases: " + (.endCallPhrases | tostring)' "$BACKUP_FILE"
    jq -r '"Silence Timeout: " + (.silenceTimeoutSeconds | tostring) + " seconds"' "$BACKUP_FILE"
else
    echo "❌ Error: Failed to create backup!"
    exit 1
fi 