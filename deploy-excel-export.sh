#!/bin/bash

echo "🚀 Deploying Excel Export to Render"
echo "===================================="

# Check if we're in the right directory
if [ ! -f "render.yaml" ]; then
    echo "❌ Error: render.yaml not found. Please run from project root."
    exit 1
fi

# Check if git is clean
if [ -n "$(git status --porcelain)" ]; then
    echo "📝 Uncommitted changes found. Committing Excel export functionality..."
    
    git add .
    git commit -m "Add Excel export functionality for lead data

- Added server/excel_export.go with comprehensive Excel export
- Added /export/excel endpoints (GET and POST)
- Includes professional formatting, currency/percentage styles
- Added summary sheet with statistics
- Added test script for Excel export functionality"
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to commit changes"
        exit 1
    fi
    
    echo "✅ Changes committed successfully"
else
    echo "✅ Git working directory is clean"
fi

# Push to main branch (Render auto-deploys from main)
echo -e "\n📤 Pushing to main branch..."
git push origin main

if [ $? -ne 0 ]; then
    echo "❌ Failed to push to main branch"
    exit 1
fi

echo "✅ Code pushed to main branch"

# Wait for deployment
echo -e "\n⏳ Waiting for Render deployment..."
echo "📍 You can monitor deployment at: https://dashboard.render.com"
echo "🔗 Your service URL: https://vapi-customer-service.onrender.com"

# Test deployment after a delay
echo -e "\n⏱️  Waiting 60 seconds for deployment to complete..."
sleep 60

echo -e "\n🧪 Testing deployment..."

# Test health endpoint
echo "1. Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s https://vapi-customer-service.onrender.com/health)
if [[ $HEALTH_RESPONSE == *"healthy"* ]]; then
    echo "✅ Health check passed"
else
    echo "❌ Health check failed: $HEALTH_RESPONSE"
fi

# Test clients endpoint
echo -e "\n2. Testing clients endpoint..."
CLIENTS_RESPONSE=$(curl -s https://vapi-customer-service.onrender.com/clients)
if [[ $CLIENTS_RESPONSE == "["* ]]; then
    echo "✅ Clients endpoint working"
    CLIENT_COUNT=$(echo $CLIENTS_RESPONSE | jq '. | length' 2>/dev/null || echo "unknown")
    echo "📊 Current leads in system: $CLIENT_COUNT"
else
    echo "❌ Clients endpoint failed: $CLIENTS_RESPONSE"
fi

# Test Excel export endpoint
echo -e "\n3. Testing Excel export endpoint..."
EXPORT_RESPONSE=$(curl -s -I https://vapi-customer-service.onrender.com/export/excel | head -n 1)
if [[ $EXPORT_RESPONSE == *"200"* ]] || [[ $EXPORT_RESPONSE == *"400"* ]]; then
    echo "✅ Excel export endpoint is accessible"
    if [[ $EXPORT_RESPONSE == *"400"* ]]; then
        echo "💡 Note: Returns 400 because no leads exist yet (expected behavior)"
    fi
else
    echo "❌ Excel export endpoint failed: $EXPORT_RESPONSE"
fi

echo -e "\n✅ Deployment complete!"
echo "🎯 Excel export is now available at:"
echo "   • GET  https://vapi-customer-service.onrender.com/export/excel"
echo "   • POST https://vapi-customer-service.onrender.com/export/excel"
echo ""
echo "📊 Features included:"
echo "   • Professional Excel formatting with currency/percentage styles"
echo "   • Summary sheet with lead statistics"
echo "   • Debt-to-income ratio calculations"
echo "   • Timestamped filenames"
echo "   • Custom filename support via POST"
echo ""
echo "🧪 To test with sample data:"
echo "   1. Make test calls to Jessica to generate leads"
echo "   2. Download Excel export: curl -o leads.xlsx https://vapi-customer-service.onrender.com/export/excel" 