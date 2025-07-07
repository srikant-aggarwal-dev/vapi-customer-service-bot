# Jeff's Financial Analysis Prompts

## 🏦 CUSTOM FINANCIAL ADVISOR ANALYSIS PROMPTS

These prompts need to be **manually configured** in the Vapi dashboard under Jeff's assistant settings.

### 📊 SUMMARY PROMPT

```
You are analyzing a financial consultation call. Create a comprehensive summary focusing on:

**Client Financial Profile:**
- Current debt situation (amounts, types, interest rates)
- Monthly income and expenses
- Credit score and history
- Financial goals and timeline

**Key Discussion Points:**
- Main financial concerns raised
- Debt consolidation opportunities discussed
- Budget optimization suggestions made
- Investment or savings recommendations

**Action Items:**
- Specific next steps agreed upon
- Follow-up meeting scheduled
- Documents needed from client
- Referrals or resources provided

**Advisor Notes:**
- Client's financial literacy level
- Emotional state regarding finances
- Potential red flags or concerns
- Recommended priority order for actions

Format as a professional financial consultation summary.
```

### ✅ SUCCESS EVALUATION PROMPT

```
Evaluate this financial consultation call for success based on:

**Engagement Quality (1-10):**
- Client felt heard and understood
- Advisor demonstrated expertise
- Clear communication throughout
- Client remained engaged

**Goal Achievement (1-10):**
- Identified client's financial priorities
- Provided actionable debt solutions
- Established clear next steps
- Built trust and rapport

**Information Gathering (1-10):**
- Collected complete financial picture
- Understood client's goals and timeline
- Identified all debt obligations
- Assessed risk tolerance

**Overall Success Score:** Average of above scores

**Success Indicators:**
- Client scheduled follow-up meeting
- Client expressed relief or optimism
- Specific action plan created
- Client asked clarifying questions

**Areas for Improvement:**
- Any missed opportunities
- Communication gaps
- Additional resources needed
```

### 🔧 STRUCTURED DATA EXTRACTION PROMPT

```
Extract the following financial data from this consultation call:

**CLIENT INFORMATION:**
- Name: [if provided]
- Age: [if mentioned]
- Employment Status: [employed/unemployed/self-employed]
- Monthly Income: $[amount]
- Location: [city/province if mentioned]

**DEBT PROFILE:**
- Total Debt Amount: $[sum all debts]
- Credit Card Debt: $[amount] at [interest rate]%
- Student Loans: $[amount] at [interest rate]%
- Mortgage: $[amount] at [interest rate]%
- Other Loans: $[amount] at [interest rate]%
- Monthly Debt Payments: $[total]

**FINANCIAL GOALS:**
- Primary Goal: [debt elimination/homeownership/retirement/etc.]
- Timeline: [timeframe mentioned]
- Target Amount: $[if specific amount mentioned]

**CONSULTATION OUTCOME:**
- Strategy Recommended: [debt consolidation/budget plan/etc.]
- Next Steps: [specific actions]
- Follow-up: [scheduled date/time]
- Urgency Level: [low/medium/high]

**CONTACT PREFERENCES:**
- Preferred Contact: [phone/email/text]
- Best Time to Call: [if mentioned]
- Email Provided: [if given]

Return as structured JSON format.
```

## 📱 HOW TO APPLY THESE PROMPTS

1. **Go to Vapi Dashboard:** https://dashboard.vapi.ai
2. **Navigate to:** Assistants → Select Jeff
3. **Scroll down to:** "Analysis" section
4. **Configure each prompt:**
   - **Summary Prompt:** Copy the Summary Prompt above
   - **Success Evaluation:** Copy the Success Evaluation Prompt above
   - **Structured Data:** Copy the Structured Data Extraction Prompt above
5. **Save Changes**

These prompts will help Jeff provide detailed financial consultation summaries, evaluate call success, and extract structured financial data for follow-up and record-keeping.
