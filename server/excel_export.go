package main

import (
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/xuri/excelize/v2"
)

// ExportClientsToExcel exports all client data to an Excel file
func ExportClientsToExcel(clients []Client, filename string) error {
	// Create a new Excel file
	f := excelize.NewFile()
	defer func() {
		if err := f.Close(); err != nil {
			log.Printf("Error closing Excel file: %v", err)
		}
	}()

	// Create a new worksheet
	sheetName := "Leads"
	index, err := f.NewSheet(sheetName)
	if err != nil {
		return fmt.Errorf("failed to create worksheet: %v", err)
	}

	// Set the active sheet
	f.SetActiveSheet(index)

	// Define headers
	headers := []string{
		"ID", "Name", "Email", "Phone", "Province", "Status", "Call ID",
		"Total Debt", "Credit Card Debt", "Monthly Income", "Monthly Expenses",
		"Minimum Payments", "Debt-to-Income Ratio", "Interest Rates",
		"Debt Sources", "Financial Goals", "Recommended Action", "Created At",
	}

	// Set headers with formatting
	headerStyle, err := f.NewStyle(&excelize.Style{
		Font: &excelize.Font{
			Bold: true,
			Size: 12,
		},
		Fill: excelize.Fill{
			Type:    "pattern",
			Color:   []string{"#E6E6FA"},
			Pattern: 1,
		},
		Alignment: &excelize.Alignment{
			Horizontal: "center",
			Vertical:   "center",
		},
		Border: []excelize.Border{
			{Type: "left", Color: "000000", Style: 1},
			{Type: "top", Color: "000000", Style: 1},
			{Type: "bottom", Color: "000000", Style: 1},
			{Type: "right", Color: "000000", Style: 1},
		},
	})
	if err != nil {
		return fmt.Errorf("failed to create header style: %v", err)
	}

	// Write headers
	for i, header := range headers {
		cell := fmt.Sprintf("%s1", string(rune('A'+i)))
		f.SetCellValue(sheetName, cell, header)
		f.SetCellStyle(sheetName, cell, cell, headerStyle)
	}

	// Create styles for different data types
	currencyStyle, _ := f.NewStyle(&excelize.Style{
		NumFmt: 164, // Currency format
	})

	percentStyle, _ := f.NewStyle(&excelize.Style{
		NumFmt: 10, // Percentage format
	})

	dateStyle, _ := f.NewStyle(&excelize.Style{
		NumFmt: 22, // Date format
	})

	// Write client data
	for i, client := range clients {
		row := i + 2 // Start from row 2 (after headers)

		// Basic information
		f.SetCellValue(sheetName, fmt.Sprintf("A%d", row), client.ID)
		f.SetCellValue(sheetName, fmt.Sprintf("B%d", row), client.Name)
		f.SetCellValue(sheetName, fmt.Sprintf("C%d", row), client.Email)
		f.SetCellValue(sheetName, fmt.Sprintf("D%d", row), client.Phone)
		f.SetCellValue(sheetName, fmt.Sprintf("E%d", row), client.Province)
		f.SetCellValue(sheetName, fmt.Sprintf("F%d", row), client.Status)
		f.SetCellValue(sheetName, fmt.Sprintf("G%d", row), client.CallID)

		// Financial information with currency formatting
		f.SetCellValue(sheetName, fmt.Sprintf("H%d", row), client.TotalDebt)
		f.SetCellStyle(sheetName, fmt.Sprintf("H%d", row), fmt.Sprintf("H%d", row), currencyStyle)

		f.SetCellValue(sheetName, fmt.Sprintf("I%d", row), client.CreditCardDebt)
		f.SetCellStyle(sheetName, fmt.Sprintf("I%d", row), fmt.Sprintf("I%d", row), currencyStyle)

		f.SetCellValue(sheetName, fmt.Sprintf("J%d", row), client.MonthlyIncome)
		f.SetCellStyle(sheetName, fmt.Sprintf("J%d", row), fmt.Sprintf("J%d", row), currencyStyle)

		f.SetCellValue(sheetName, fmt.Sprintf("K%d", row), client.MonthlyExpenses)
		f.SetCellStyle(sheetName, fmt.Sprintf("K%d", row), fmt.Sprintf("K%d", row), currencyStyle)

		f.SetCellValue(sheetName, fmt.Sprintf("L%d", row), client.MinimumPayments)
		f.SetCellStyle(sheetName, fmt.Sprintf("L%d", row), fmt.Sprintf("L%d", row), currencyStyle)

		// Calculate and format debt-to-income ratio
		debtToIncome := 0.0
		if client.MonthlyIncome > 0 {
			debtToIncome = (client.MinimumPayments / client.MonthlyIncome)
		}
		f.SetCellValue(sheetName, fmt.Sprintf("M%d", row), debtToIncome)
		f.SetCellStyle(sheetName, fmt.Sprintf("M%d", row), fmt.Sprintf("M%d", row), percentStyle)

		// Convert arrays to comma-separated strings
		interestRatesStr := ""
		if len(client.InterestRates) > 0 {
			rates := make([]string, len(client.InterestRates))
			for j, rate := range client.InterestRates {
				rates[j] = fmt.Sprintf("%.2f%%", rate)
			}
			interestRatesStr = strings.Join(rates, ", ")
		}
		f.SetCellValue(sheetName, fmt.Sprintf("N%d", row), interestRatesStr)

		debtSourcesStr := strings.Join(client.DebtSources, ", ")
		f.SetCellValue(sheetName, fmt.Sprintf("O%d", row), debtSourcesStr)

		financialGoalsStr := strings.Join(client.FinancialGoals, ", ")
		f.SetCellValue(sheetName, fmt.Sprintf("P%d", row), financialGoalsStr)

		f.SetCellValue(sheetName, fmt.Sprintf("Q%d", row), client.RecommendedAction)

		// Format creation date
		f.SetCellValue(sheetName, fmt.Sprintf("R%d", row), client.CreatedAt)
		f.SetCellStyle(sheetName, fmt.Sprintf("R%d", row), fmt.Sprintf("R%d", row), dateStyle)
	}

	// Auto-fit columns
	for i := 0; i < len(headers); i++ {
		col := string(rune('A' + i))
		f.SetColWidth(sheetName, col, col, 15)
	}

	// Set wider columns for text-heavy fields
	f.SetColWidth(sheetName, "B", "B", 20) // Name
	f.SetColWidth(sheetName, "C", "C", 25) // Email
	f.SetColWidth(sheetName, "O", "O", 30) // Debt Sources
	f.SetColWidth(sheetName, "P", "P", 30) // Financial Goals
	f.SetColWidth(sheetName, "Q", "Q", 35) // Recommended Action

	// Add summary sheet
	if err := addSummarySheet(f, clients); err != nil {
		log.Printf("Failed to add summary sheet: %v", err)
	}

	// Save the Excel file
	if err := f.SaveAs(filename); err != nil {
		return fmt.Errorf("failed to save Excel file: %v", err)
	}

	return nil
}

// addSummarySheet adds a summary sheet with statistics
func addSummarySheet(f *excelize.File, clients []Client) error {
	summarySheet := "Summary"
	_, err := f.NewSheet(summarySheet)
	if err != nil {
		return err
	}

	// Calculate statistics
	totalClients := len(clients)
	totalDebt := 0.0
	totalIncome := 0.0
	statusCounts := make(map[string]int)
	provinceCounts := make(map[string]int)

	for _, client := range clients {
		totalDebt += client.TotalDebt
		totalIncome += client.MonthlyIncome
		statusCounts[client.Status]++
		if client.Province != "" {
			provinceCounts[client.Province]++
		}
	}

	avgDebt := 0.0
	avgIncome := 0.0
	if totalClients > 0 {
		avgDebt = totalDebt / float64(totalClients)
		avgIncome = totalIncome / float64(totalClients)
	}

	// Create title style
	titleStyle, _ := f.NewStyle(&excelize.Style{
		Font: &excelize.Font{
			Bold: true,
			Size: 16,
		},
		Alignment: &excelize.Alignment{
			Horizontal: "center",
		},
	})

	// Create header style
	headerStyle, _ := f.NewStyle(&excelize.Style{
		Font: &excelize.Font{
			Bold: true,
			Size: 12,
		},
		Fill: excelize.Fill{
			Type:    "pattern",
			Color:   []string{"#E6E6FA"},
			Pattern: 1,
		},
	})

	// Add title
	f.SetCellValue(summarySheet, "A1", "Lead Generation Summary Report")
	f.SetCellStyle(summarySheet, "A1", "A1", titleStyle)
	f.MergeCell(summarySheet, "A1", "D1")

	// Add generation date
	f.SetCellValue(summarySheet, "A2", "Generated: "+time.Now().Format("January 2, 2006 at 3:04 PM"))

	// Overall statistics
	f.SetCellValue(summarySheet, "A4", "Overall Statistics")
	f.SetCellStyle(summarySheet, "A4", "A4", headerStyle)

	f.SetCellValue(summarySheet, "A5", "Total Leads:")
	f.SetCellValue(summarySheet, "B5", totalClients)

	f.SetCellValue(summarySheet, "A6", "Total Debt Amount:")
	f.SetCellValue(summarySheet, "B6", totalDebt)

	f.SetCellValue(summarySheet, "A7", "Average Debt per Lead:")
	f.SetCellValue(summarySheet, "B7", avgDebt)

	f.SetCellValue(summarySheet, "A8", "Average Monthly Income:")
	f.SetCellValue(summarySheet, "B8", avgIncome)

	// Status breakdown
	f.SetCellValue(summarySheet, "A10", "Status Breakdown")
	f.SetCellStyle(summarySheet, "A10", "A10", headerStyle)

	row := 11
	for status, count := range statusCounts {
		f.SetCellValue(summarySheet, fmt.Sprintf("A%d", row), status+":")
		f.SetCellValue(summarySheet, fmt.Sprintf("B%d", row), count)
		row++
	}

	// Province breakdown
	f.SetCellValue(summarySheet, "D10", "Province Breakdown")
	f.SetCellStyle(summarySheet, "D10", "D10", headerStyle)

	row = 11
	for province, count := range provinceCounts {
		f.SetCellValue(summarySheet, fmt.Sprintf("D%d", row), province+":")
		f.SetCellValue(summarySheet, fmt.Sprintf("E%d", row), count)
		row++
	}

	// Set column widths
	f.SetColWidth(summarySheet, "A", "A", 25)
	f.SetColWidth(summarySheet, "B", "B", 15)
	f.SetColWidth(summarySheet, "D", "D", 20)
	f.SetColWidth(summarySheet, "E", "E", 15)

	return nil
}

// GenerateExcelFilename creates a timestamped filename for Excel exports
func GenerateExcelFilename() string {
	return fmt.Sprintf("leads_export_%s.xlsx", time.Now().Format("20060102_150405"))
} 