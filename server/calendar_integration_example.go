package main

import (
	"fmt"
	"time"
)

// Example of how to add calendar functions to your webhook handler
// This shows the concept - you would implement the actual API calls

func handleCalendarFunctions(toolName string, args map[string]interface{}) (interface{}, error) {
	switch toolName {
	case "check_availability":
		// Extract parameters
		date, _ := args["date"].(string)
		timeStr, _ := args["time"].(string)
		duration, _ := args["duration"].(string)
		
		// Here you would:
		// 1. Connect to Google Calendar API / Calendly / Cal.com / etc.
		// 2. Check if the slot is available
		// 3. Return the result
		
		// Example response:
		return map[string]interface{}{
			"available": true,
			"message": fmt.Sprintf("The slot on %s at %s for %s minutes is available", date, timeStr, duration),
		}, nil
		
	case "book_appointment":
		// Extract parameters
		date, _ := args["date"].(string)
		timeStr, _ := args["time"].(string)
		customerName, _ := args["customer_name"].(string)
		customerEmail, _ := args["customer_email"].(string)
		purpose, _ := args["purpose"].(string)
		
		// Here you would:
		// 1. Create the calendar event
		// 2. Send confirmation email
		// 3. Return booking details
		
		// Example response:
		return map[string]interface{}{
			"success": true,
			"booking_id": fmt.Sprintf("APT-%d", time.Now().Unix()),
			"message": fmt.Sprintf("Appointment booked for %s on %s at %s", customerName, date, timeStr),
			"details": map[string]string{
				"date": date,
				"time": timeStr,
				"purpose": purpose,
				"confirmation_sent_to": customerEmail,
			},
		}, nil
		
	case "get_available_slots":
		// Extract parameters
		date, _ := args["date"].(string)
		
		// Here you would:
		// 1. Query calendar for the specified date
		// 2. Calculate available slots based on business hours
		// 3. Return list of available times
		
		// Example response:
		return map[string]interface{}{
			"date": date,
			"available_slots": []string{
				"09:00", "09:30", "10:00", "10:30",
				"14:00", "14:30", "15:00", "15:30",
			},
			"timezone": "America/New_York",
		}, nil
		
	case "cancel_appointment":
		// Extract parameters
		bookingID, _ := args["booking_id"].(string)
		
		// Here you would:
		// 1. Find and cancel the appointment
		// 2. Send cancellation notification
		
		return map[string]interface{}{
			"success": true,
			"message": fmt.Sprintf("Appointment %s has been cancelled", bookingID),
		}, nil
	}
	
	return nil, fmt.Errorf("calendar function not found: %s", toolName)
}

// Calendar-related functions to add to your VapiAssistant
var calendarFunctions = []Function{
	{
		Name:        "check_availability",
		Description: "Check if a specific time slot is available for booking",
		Parameters: struct {
			Type       string                 `json:"type"`
			Properties map[string]interface{} `json:"properties"`
			Required   []string               `json:"required"`
		}{
			Type: "object",
			Properties: map[string]interface{}{
				"date": map[string]string{
					"type":        "string",
					"description": "Date in YYYY-MM-DD format",
				},
				"time": map[string]string{
					"type":        "string",
					"description": "Time in HH:MM format (24-hour)",
				},
				"duration": map[string]string{
					"type":        "string",
					"description": "Duration in minutes (default: 30)",
				},
			},
			Required: []string{"date", "time"},
		},
	},
	{
		Name:        "book_appointment",
		Description: "Book an appointment at a specific date and time",
		Parameters: struct {
			Type       string                 `json:"type"`
			Properties map[string]interface{} `json:"properties"`
			Required   []string               `json:"required"`
		}{
			Type: "object",
			Properties: map[string]interface{}{
				"date": map[string]string{
					"type":        "string",
					"description": "Date in YYYY-MM-DD format",
				},
				"time": map[string]string{
					"type":        "string",
					"description": "Time in HH:MM format (24-hour)",
				},
				"purpose": map[string]string{
					"type":        "string",
					"description": "Purpose of the appointment",
				},
				"customer_name": map[string]string{
					"type":        "string",
					"description": "Customer's full name",
				},
				"customer_email": map[string]string{
					"type":        "string",
					"description": "Customer's email address",
				},
			},
			Required: []string{"date", "time", "customer_name"},
		},
	},
	{
		Name:        "get_available_slots",
		Description: "Get available appointment slots for a specific date",
		Parameters: struct {
			Type       string                 `json:"type"`
			Properties map[string]interface{} `json:"properties"`
			Required   []string               `json:"required"`
		}{
			Type: "object",
			Properties: map[string]interface{}{
				"date": map[string]string{
					"type":        "string",
					"description": "Date in YYYY-MM-DD format (e.g., 2024-06-15)",
				},
			},
			Required: []string{"date"},
		},
	},
} 