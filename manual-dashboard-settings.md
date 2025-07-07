# Manual Dashboard Settings for Jeff

## ⚠️ Settings That Need Manual Configuration

The following settings from Morgan's configuration need to be manually set in the Vapi dashboard because they're not supported via the API:

### 📊 **TRANSCRIBER Settings**

1. Go to Jeff's assistant in dashboard
2. Navigate to "TRANSCRIBER" section
3. Set these values:
   - **Confidence Threshold**: `0.4`
   - **Use Numerals**: `✅ Enabled`

### 🎹 **KEYPAD INPUT Settings**

1. Go to "ADVANCED" section
2. Navigate to "Keypad Input Settings"
3. Set these values:
   - **Enable Keypad Input**: `✅ Enabled`
   - **Timeout**: `2` seconds
   - **Delimiter**: `#`

### 📈 **ANALYSIS Settings**

1. Go to "ANALYSIS" section
2. Configure these prompts:

**Summary Prompt:**

```
You are an expert note-taker. You will be given a transcript of a call with a financial advisor. Summarize the call in 2-3 sentences, focusing on the debt situation discussed and any next steps mentioned.
```

**Success Evaluation Prompt:**

```
You are an expert call evaluator. You will be given a transcript of a call with a financial advisor. Determine if the call was successful based on whether the advisor: 1) Understood the client's debt situation, 2) Provided helpful guidance, 3) Collected contact information, 4) Scheduled follow-up or consultation.
```

**Structured Data Prompt:**

```
Extract key financial information from this call: debt amount, interest rates, monthly payment capacity, email address, and scheduled consultation details.
```

### 🎛️ **ADVANCED Settings Verification**

Double-check these were applied correctly:

- **Start Speaking Plan**: Wait `0.4` seconds
- **Smart Endpointing**: `✅ Enabled`
- **Silence Timeout**: `30` seconds
- **Maximum Duration**: `600` seconds (10 minutes)

## ✅ **Already Applied via API**

These settings are already configured and don't need manual changes:

- ✅ Model: GPT-4o, Temperature: 0.5, Max Tokens: 250
- ✅ Voice: Cartesia Morgan
- ✅ Transcriber: Deepgram Nova-2
- ✅ Background Sound: Custom lounge audio
- ✅ Smart Endpointing: Configured
- ✅ Recording: Enabled
- ✅ Background Denoising: Enabled
- ✅ Backchanneling: Enabled

## 📞 **Test After Configuration**

Once you've set the manual dashboard settings, test with:

```bash
./test-call.sh +16476278084
```

Jeff should now have **identical** settings to Morgan:

- Same natural pauses and timing
- Same email accuracy and transcription
- Same conversation flow and duration limits
- Same voice quality and background sound
