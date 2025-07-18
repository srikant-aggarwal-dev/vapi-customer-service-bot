#!/bin/bash

echo "🎤 Speech-to-Text (STT) Models Available in Vapi"
echo "================================================"
echo ""
echo "CURRENT: OpenAI gpt-4o-transcribe ✅"
echo ""
echo "AVAILABLE STT PROVIDERS & MODELS:"
echo ""
echo "1️⃣ DEEPGRAM (Default)"
echo "   📍 nova-2-phonecall"
echo "   ✅ Pros: Optimized for phone calls, fast"
echo "   ❌ Cons: Struggles with names/spelling"
echo "   💰 Cost: ~$0.0098/minute"
echo "   ⚡ Speed: 50-100ms latency"
echo "   🎯 Use: Basic phone conversations"
echo ""
echo "   📍 nova-2"
echo "   ✅ Pros: General purpose, better accuracy"
echo "   ❌ Cons: Not optimized for phone audio"
echo "   💰 Cost: ~$0.0098/minute"
echo "   ⚡ Speed: 50-100ms latency"
echo ""
echo "2️⃣ OPENAI ⭐"
echo "   📍 gpt-4o-transcribe (CURRENT)"
echo "   ✅ Pros: Best for names, spelling, accents"
echo "   ✅ Pros: Handles interruptions well"
echo "   💰 Cost: ~$0.006/minute"
echo "   ⚡ Speed: 100-200ms latency"
echo "   🎯 Use: Complex names, international callers"
echo ""
echo "   📍 gpt-4o-mini-transcribe"
echo "   ✅ Pros: Cheaper than 4o, still accurate"
echo "   💰 Cost: ~$0.004/minute"
echo "   ⚡ Speed: 80-150ms latency"
echo ""
echo "3️⃣ AZURE SPEECH SERVICES"
echo "   📍 azure-stt"
echo "   ✅ Pros: Enterprise-grade, HIPAA compliant"
echo "   ❌ Cons: Requires Azure setup"
echo "   💰 Cost: ~$0.01/minute"
echo "   ⚡ Speed: 100-200ms latency"
echo "   🎯 Use: Healthcare, compliance needed"
echo ""
echo "4️⃣ ASSEMBLY AI"
echo "   📍 assemblyai"
echo "   ✅ Pros: Good accuracy, detailed transcripts"
echo "   ❌ Cons: Higher latency"
echo "   💰 Cost: ~$0.01/minute"
echo "   ⚡ Speed: 200-400ms latency"
echo ""
echo "5️⃣ GOOGLE CLOUD SPEECH"
echo "   📍 google-stt"
echo "   ✅ Pros: Good multilingual support"
echo "   ❌ Cons: Requires GCP setup"
echo "   💰 Cost: ~$0.009/minute"
echo "   ⚡ Speed: 100-200ms latency"
echo ""
echo "⚠️ IMPORTANT NOTES:"
echo "• Gemini does NOT offer STT - it's only for conversation AI"
echo "• Google Cloud Speech is separate from Gemini"
echo "• OpenAI models best for complex names/accents"
echo "• Deepgram fastest but less accurate on names"
echo ""
echo "🎯 FOR JEFF (FINANCIAL ADVISOR):"
echo "BEST: OpenAI gpt-4o-transcribe"
echo "• Handles 'Shirisha Kandalai' correctly"
echo "• Worth extra $0.36/hour for accuracy"
echo "• Critical for capturing emails/names"
echo ""
echo "💡 TO CHANGE STT MODEL:"
echo "1. Vapi Dashboard → Jeff's Assistant"
echo "2. Scroll to 'Transcriber' section"
echo "3. Select Provider & Model"
echo "4. Save changes"
echo ""
echo "📊 COST COMPARISON (per hour):"
echo "• Deepgram: ~$0.59/hour"
echo "• OpenAI 4o-mini: ~$0.24/hour"
echo "• OpenAI 4o: ~$0.36/hour ⭐"
echo "• Azure/Google: ~$0.60/hour" 