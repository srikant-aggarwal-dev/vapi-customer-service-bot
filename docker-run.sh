#!/bin/bash

# Docker deployment script for Vapi Customer Service Bot

echo "🐳 Building Docker container..."
docker-compose build

echo "🚀 Starting Docker container..."
docker-compose up -d

echo "⏳ Waiting for container to start..."
sleep 3

echo "🔍 Checking container status..."
docker-compose ps

echo "📊 Checking health endpoint..."
curl -s http://localhost:8080/health | jq || echo "Health check failed - container may still be starting"

echo ""
echo "✅ Docker deployment complete!"
echo ""
echo "🌐 Service URLs:"
echo "   - Go Server:    http://localhost:8080"
echo "   - Health Check: http://localhost:8080/health"
echo "   - Clients API:  http://localhost:8080/clients"
echo ""
echo "📋 Useful commands:"
echo "   - View logs:    docker-compose logs -f"
echo "   - Stop:         docker-compose down"
echo "   - Restart:      docker-compose restart"
echo ""

# For IT teams - show them how to expose this properly
echo "🏢 For Production Deployment:"
echo "   1. Deploy container to company cloud (AWS/Azure/GCP)"
echo "   2. Set up load balancer with public IP"
echo "   3. Update Vapi webhook URL to: https://your-domain.com/webhook"
echo "   4. No more ngrok needed!" 