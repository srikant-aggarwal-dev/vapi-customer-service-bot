#!/bin/bash

# Railway Deployment Script for Vapi Customer Service Bot

echo "🚀 Deploying to Railway Cloud..."
echo ""

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Installing..."
    echo "Run: npm install -g @railway/cli"
    echo "Then: railway login"
    echo "Then run this script again."
    exit 1
fi

echo "📋 Deployment Steps:"
echo "1. Your Go server will be deployed to Railway cloud"
echo "2. You'll get a public URL (e.g., https://your-app.railway.app)"  
echo "3. Update Vapi webhook to use this URL"
echo "4. Next.js client stays local on your company machine"
echo ""

echo "🔧 Current configuration:"
echo "   - Go Server: Will be deployed to Railway"
echo "   - Next.js Client: Runs locally at http://localhost:3000"
echo "   - No ngrok needed!"
echo ""

# Check if already logged in
if ! railway whoami &> /dev/null; then
    echo "🔑 Please login to Railway first:"
    echo "   railway login"
    exit 1
fi

echo "🚀 Deploying..."
railway up

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📋 Next steps:"
echo "1. Get your Railway URL: railway domain"
echo "2. Update Vapi webhook URL to: https://your-app.railway.app/webhook"
echo "3. Kill ngrok process (no longer needed)"
echo "4. Test with a phone call"
echo ""
echo "🔍 Useful commands:"
echo "   - View logs: railway logs"
echo "   - Check status: railway status" 
echo "   - Open dashboard: railway open" 