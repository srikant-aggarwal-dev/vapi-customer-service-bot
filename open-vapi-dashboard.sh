#!/bin/bash

echo "🌐 Opening Vapi Dashboard for Final Settings..."
echo ""
echo "📋 QUICK CHECKLIST - Settings to adjust:"
echo ""
echo "1️⃣ TRANSCRIBER → Advanced Settings:"
echo "   ✓ Enable 'Smart Endpointing'"
echo "   ✓ End of Speech Threshold: 1500ms"
echo "   ✓ Speech Detection Sensitivity: 0.3"
echo ""
echo "2️⃣ VOICE → Advanced Settings:"
echo "   ✓ Enable 'Interruption Sensitivity Override'"
echo "   ✓ Interruption Sensitivity: 0.8"
echo "   ✓ Enable 'Background Noise Suppression'"
echo ""
echo "3️⃣ Click 'Save' at the bottom!"
echo ""

# Open the Vapi dashboard in default browser
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open "https://dashboard.vapi.ai/assistants"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    xdg-open "https://dashboard.vapi.ai/assistants"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows
    start "https://dashboard.vapi.ai/assistants"
else
    echo "Please open manually: https://dashboard.vapi.ai/assistants"
fi

echo "✅ Dashboard opened in your browser!"
echo ""
echo "After saving the settings, test with:"
echo "./test-call.sh +16476278084" 