#!/bin/bash

echo "🚀 Deploying VAPI Customer Service Bot to Render..."

# Check if git repo is clean
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  You have uncommitted changes. Committing them now..."
    git add .
    git commit -m "Deploy to Render: $(date)"
fi

# Push to main branch
echo "📤 Pushing to GitHub main branch..."
git push origin main

echo "✅ Code pushed to GitHub!"
echo ""
echo "🎯 Next Steps:"
echo "1. Go to https://render.com and sign in with GitHub"
echo "2. Click 'New +' → 'Web Service'"
echo "3. Select this repository: $(git remote get-url origin)"
echo "4. Configure:"
echo "   - Name: vapi-customer-service"
echo "   - Environment: Docker" 
echo "   - Plan: Free"
echo "   - Dockerfile Path: ./Dockerfile"
echo ""
echo "5. Add these environment variables in Render dashboard:"
echo "   VAPI_PRIVATE_KEY=4d106ac6-1ece-4856-a79c-b202ba21ef58"
echo "   SMTP_HOST=smtp.gmail.com"
echo "   SMTP_PORT=587"
echo "   SMTP_EMAIL=srikantaggarwal@gmail.com"
echo "   SMTP_PASSWORD=idshuneqdbhgfruo"
echo "   SMTP_FROM_NAME=Srikant Aggarwal"
echo "   DEFAULT_MEETING_LINK=https://meet.google.com/oyr-txmt-jtb"
echo "   PORT=8080"
echo ""
echo "6. Click 'Create Web Service' and wait for deployment"
echo "7. Update your Vapi webhook URL to the Render URL"
echo ""
echo "🔗 Your service will be available at: https://vapi-customer-service-xxxx.onrender.com"
echo "📋 Health check: https://vapi-customer-service-xxxx.onrender.com/health" 