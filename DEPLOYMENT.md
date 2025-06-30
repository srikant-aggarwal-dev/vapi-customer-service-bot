# Deployment Guide

## Overview

This guide helps you deploy your Vapi Customer Service Bot to cloud platforms, solving company security policies that prohibit ngrok.

## Render Deployment (Recommended - Free Tier)

### Architecture After Deployment

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Vapi Cloud    │────│ Render Cloud    │    │ Company Machine │
│  (External)     │    │  (Go Server)    │    │ (Next.js Client)│
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Benefits:**

- ✅ No external access to company machines
- ✅ Company security policy compliant
- ✅ Production-ready deployment
- ✅ Free hosting (Render free tier)
- ✅ Automatic HTTPS/SSL
- ✅ Easy GitHub integration

### Step-by-Step Render Deployment

#### 1. Prepare Your Repository

Make sure your code is pushed to GitHub:

```bash
git add .
git commit -m "Prepare for Render deployment"
git push origin main
```

#### 2. Create Render Account

1. Go to [render.com](https://render.com)
2. Sign up using your GitHub account
3. This will give Render access to your repositories

#### 3. Deploy the Service

1. **From Render Dashboard:**

   - Click "New +" → "Web Service"
   - Connect your GitHub repository
   - Select this repository

2. **Configure the Service:**
   - **Name**: `vapi-customer-service`
   - **Environment**: `Docker`
   - **Plan**: `Free`
   - **Region**: Choose closest to you
   - **Branch**: `main`
   - **Dockerfile Path**: `./Dockerfile`

#### 4. Set Environment Variables

In Render dashboard, add these environment variables:

```
VAPI_PRIVATE_KEY=4d106ac6-1ece-4856-a79c-b202ba21ef58
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_EMAIL=srikantaggarwal@gmail.com
SMTP_PASSWORD=idshuneqdbhgfruo
SMTP_FROM_NAME=Srikant Aggarwal
DEFAULT_MEETING_LINK=https://meet.google.com/oyr-txmt-jtb
PORT=8080
```

**Important**: The `SERVER_URL` will be automatically set by Render to your service URL.

#### 5. Deploy

1. Click "Create Web Service"
2. Render will build and deploy your service
3. You'll get a URL like: `https://vapi-customer-service-abcd.onrender.com`

#### 6. Update Vapi Webhook

1. Go to your Vapi dashboard
2. Update your assistant's webhook URL to: `https://your-render-url.onrender.com/webhook`
3. Make sure the webhook is enabled

#### 7. Test Your Deployment

1. **Health Check**: Visit `https://your-render-url.onrender.com/health`
2. **Assistant Config**: Visit `https://your-render-url.onrender.com/assistant`
3. **Make Test Call**: Call your Vapi number

### Local Development After Deployment

```bash
# Terminal 1: Local Next.js client (runs on company machine)
cd client && npm run dev
# Runs on http://localhost:3000

# No need to run server locally - it's on Render!
```

### Render Free Tier Limits

- **750 hours/month** of runtime (enough for most use cases)
- **512 MB RAM**
- **Automatic sleep** after 15 minutes of inactivity
- **Automatic wake** on incoming requests
- **Custom domains** supported

## Railway Deployment (Alternative)

## Architecture After Deployment

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Vapi Cloud    │────│ Railway Cloud   │    │ Company Machine │
│  (External)     │    │  (Go Server)    │    │ (Next.js Client)│
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Benefits:**

- ✅ No external access to company machines
- ✅ Company security policy compliant
- ✅ Production-ready deployment
- ✅ Free hosting (Railway free tier)

## Prerequisites

1. **Railway Account**: Sign up at [railway.app](https://railway.app)
2. **Railway CLI**: Install the command line tool
3. **Git**: Your code should be in a git repository

## Step-by-Step Deployment

### 1. Install Railway CLI

```bash
npm install -g @railway/cli
```

### 2. Login to Railway

```bash
railway login
```

This will open your browser for authentication.

### 3. Initialize Railway Project

```bash
railway init
```

Choose:

- "Create new project"
- Give it a name like "vapi-customer-service"
- Link to your current directory

### 4. Deploy Your Application

```bash
chmod +x deploy-railway.sh
./deploy-railway.sh
```

Or manually:

```bash
railway up
```

### 5. Get Your Public URL

```bash
railway domain
```

This will give you a URL like: `https://vapi-customer-service-production.railway.app`

### 6. Update Vapi Configuration

In your Vapi dashboard, update the webhook URL to:

```
https://your-app.railway.app/webhook
```

### 7. Stop ngrok (No Longer Needed!)

```bash
# Kill ngrok process
pkill ngrok
```

### 8. Test Your Deployment

1. **Health Check**: Visit `https://your-app.railway.app/health`
2. **Make a Test Call**: Call your Vapi number
3. **Check Logs**: `railway logs` to see webhook activity

## Environment Variables

Railway will automatically use your `server/config.env` file, but you may want to set these as Railway environment variables:

```bash
railway variables set VAPI_PRIVATE_KEY=your_key_here
railway variables set SMTP_EMAIL=your_email@company.com
# etc...
```

## Local Development Setup

After deployment, your local setup becomes:

```bash
# Terminal 1: Local Next.js client (company machine)
cd client && npm run dev
# Runs on http://localhost:3000

# Terminal 2: No server needed locally!
# Server runs on Railway cloud
```

## Monitoring & Maintenance

### View Logs

```bash
railway logs
```

### Check Status

```bash
railway status
```

### Update Deployment

```bash
# After making code changes:
git add .
git commit -m "Update server"
railway up
```

### Railway Dashboard

```bash
railway open
```

## Troubleshooting

### Deployment Fails

- Check `railway logs` for errors
- Ensure Dockerfile builds locally: `docker build -t test .`
- Verify all environment variables are set

### Webhooks Not Working

- Confirm Railway URL is correct in Vapi dashboard
- Check webhook endpoint: `curl https://your-app.railway.app/health`
- Monitor logs: `railway logs --follow`

### Build Issues

- Railway uses your Dockerfile
- Test locally: `docker-compose up --build`
- Check Railway build logs in dashboard

## Cost

- **Railway Free Tier**: $0/month, includes:
  - 500 hours of usage
  - 1GB RAM
  - 1GB storage
  - Custom domain

Perfect for development and small production workloads!

## Security Benefits

✅ **No ngrok** on company machines
✅ **No external access** to company network
✅ **Standard cloud deployment** (IT approved)
✅ **HTTPS by default** (Railway provides SSL)
✅ **Professional setup** for production use
