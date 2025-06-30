#!/bin/bash

# Email Configuration for Meeting Invites
echo "Setting up email configuration..."

# Your email settings
export SMTP_HOST=smtp.gmail.com
export SMTP_PORT=587
export SMTP_EMAIL=srikantaggarwal@gmail.com
export SMTP_PASSWORD="idshuneqdbhgfruo"  # Your app password (spaces removed)
export SMTP_FROM_NAME="Srikant Aggarwal"

# Meeting Configuration
export DEFAULT_MEETING_LINK="https://meet.google.com/oyr-txmt-jtb"

# VAPI Configuration (already set)
export VAPI_PRIVATE_KEY=4d106ac6-1ece-4856-a79c-b202ba21ef58

echo "Environment variables set!"
echo ""
echo "SUCCESS! Email configuration is ready."
echo ""
echo "Next steps:"
echo "1. Update DEFAULT_MEETING_LINK with your actual meeting link"
echo "2. Run: source setup-email.sh"
echo "3. Restart your server to use the new email settings" 