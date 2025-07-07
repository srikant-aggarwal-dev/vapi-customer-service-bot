#!/bin/bash

echo "📊 Testing Excel Export Functionality"
echo "====================================="

# Check if server is running
if ! curl -s http://localhost:8080/health > /dev/null 2>&1; then
    echo "❌ Server not running on port 8080"
    echo "💡 Start with: cd server && go run main.go"
    exit 1
fi

# Check current leads
echo -e "\n1. Checking current leads..."
LEAD_COUNT=$(curl -s http://localhost:8080/clients | jq '. | length')
echo "📊 Current leads in system: $LEAD_COUNT"

if [ "$LEAD_COUNT" -eq 0 ]; then
    echo -e "\n2. Creating test leads for demo..."
    
    # Create test lead 1
    curl -s -X POST http://localhost:8080/webhook \
      -H "Content-Type: application/json" \
      -d '{
        "type": "function-call",
        "call": {
          "id": "test-excel-001",
          "status": "active"
        },
        "message": {
          "toolCalls": [{
            "function": {
              "name": "capture_client",
              "arguments": "{\"name\":\"John Smith\",\"email\":\"john.smith@email.com\",\"phone\":\"+14165551234\",\"province\":\"Ontario\",\"total_debt\":25000,\"credit_card_debt\":15000,\"monthly_income\":5000,\"monthly_expenses\":3500,\"minimum_payments\":750,\"interest_rates\":[19.99,22.5],\"debt_sources\":[\"Credit Cards\",\"Personal Loan\"],\"financial_goals\":[\"Debt Free\",\"Emergency Fund\"],\"recommended_action\":\"Debt consolidation\",\"status\":\"qualified\"}"
            }
          }]
        }
      }' > /dev/null

    # Create test lead 2
    curl -s -X POST http://localhost:8080/webhook \
      -H "Content-Type: application/json" \
      -d '{
        "type": "function-call",
        "call": {
          "id": "test-excel-002",
          "status": "active"
        },
        "message": {
          "toolCalls": [{
            "function": {
              "name": "capture_client",
              "arguments": "{\"name\":\"Sarah Johnson\",\"email\":\"sarah.j@email.com\",\"phone\":\"+14165559876\",\"province\":\"British Columbia\",\"total_debt\":35000,\"credit_card_debt\":20000,\"monthly_income\":6500,\"monthly_expenses\":4200,\"minimum_payments\":950,\"interest_rates\":[18.5,24.0,15.2],\"debt_sources\":[\"Credit Cards\",\"Student Loan\",\"Car Loan\"],\"financial_goals\":[\"Homeownership\",\"Debt Reduction\"],\"recommended_action\":\"Avalanche method\",\"status\":\"follow-up\"}"
            }
          }]
        }
      }' > /dev/null

    # Create test lead 3
    curl -s -X POST http://localhost:8080/webhook \
      -H "Content-Type: application/json" \
      -d '{
        "type": "function-call",
        "call": {
          "id": "test-excel-003",
          "status": "active"
        },
        "message": {
          "toolCalls": [{
            "function": {
              "name": "capture_client",
              "arguments": "{\"name\":\"Mike Chen\",\"email\":\"mike.chen@email.com\",\"phone\":\"+16045551111\",\"province\":\"Alberta\",\"total_debt\":45000,\"credit_card_debt\":30000,\"monthly_income\":7200,\"monthly_expenses\":5000,\"minimum_payments\":1200,\"interest_rates\":[21.0,19.5],\"debt_sources\":[\"Credit Cards\",\"Line of Credit\"],\"financial_goals\":[\"Debt Free\",\"Retirement Savings\"],\"recommended_action\":\"Budget restructure\",\"status\":\"initial-assessment\"}"
            }
          }]
        }
      }' > /dev/null

    echo "✅ Created 3 test leads"
    
    # Check updated count
    LEAD_COUNT=$(curl -s http://localhost:8080/clients | jq '. | length')
    echo "📊 Updated leads in system: $LEAD_COUNT"
fi

echo -e "\n3. Testing Excel export (GET method)..."
curl -s -o "test_export_download.xlsx" http://localhost:8080/export/excel
if [ $? -eq 0 ]; then
    echo "✅ Excel file downloaded successfully: test_export_download.xlsx"
    ls -lh test_export_download.xlsx
else
    echo "❌ Failed to download Excel file"
fi

echo -e "\n4. Testing Excel export (POST method with custom filename)..."
RESPONSE=$(curl -s -X POST http://localhost:8080/export/excel \
  -H "Content-Type: application/json" \
  -d '{"filename": "my_custom_leads_report"}')

echo "Response: $RESPONSE"

# Check if file was created
if [ -f "my_custom_leads_report.xlsx" ]; then
    echo "✅ Custom filename Excel file created: my_custom_leads_report.xlsx"
    ls -lh my_custom_leads_report.xlsx
else
    echo "❌ Custom filename Excel file not found"
fi

echo -e "\n5. Summary of created files:"
ls -lh *.xlsx 2>/dev/null || echo "No Excel files found"

echo -e "\n✅ Excel export test complete!"
echo "📁 Open the .xlsx files in Excel/LibreOffice to view the lead data"
echo "📊 The files include:"
echo "   • Lead details with financial information"
echo "   • Proper currency and percentage formatting"
echo "   • Summary sheet with statistics"
echo "   • Professional styling and column widths" 