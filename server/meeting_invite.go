package main

import (
	"bytes"
	"crypto/tls"
	"encoding/base64"
	"fmt"
	"log"
	"net/smtp"
	"os"
	"strings"
	"time"
	// Uncomment these imports if you want to use Google Calendar API
	// "context"
	// "google.golang.org/api/calendar/v3"
	// "google.golang.org/api/option"
)

// MeetingInvite represents a meeting invitation
type MeetingInvite struct {
	LeadEmail    string
	LeadName     string
	MeetingTitle string
	Description  string
	StartTime    time.Time
	EndTime      time.Time
	Location     string // Can be a physical location or meeting link
	MeetingLink  string // Zoom/Google Meet/Teams link
}

// SendMeetingInvite sends a meeting invitation to a client
// This is the main function you'll call from your webhook handler
func SendMeetingInvite(client Client, meetingDetails MeetingInvite) error {
	// Option 1: Use Google Calendar API (requires OAuth setup)
	// Uncomment this if you have Google Calendar API credentials set up
	// return sendGoogleCalendarInvite(client, meetingDetails)

	// Option 2: Send ICS file via email (simpler, no OAuth required)
	return sendICSInviteEmail(client, meetingDetails)
}

/* Uncomment this function if you want to use Google Calendar API
// sendGoogleCalendarInvite creates a Google Calendar event and invites the lead
func sendGoogleCalendarInvite(lead Lead, meeting MeetingInvite) error {
	ctx := context.Background()

	// Initialize Google Calendar service
	// You'll need to set up OAuth2 credentials first
	// Download credentials.json from Google Cloud Console
	service, err := calendar.NewService(ctx, option.WithCredentialsFile("credentials.json"))
	if err != nil {
		return fmt.Errorf("failed to create calendar service: %v", err)
	}

	// Create the event
	event := &calendar.Event{
		Summary:     meeting.MeetingTitle,
		Description: meeting.Description,
		Location:    meeting.Location,
		Start: &calendar.EventDateTime{
			DateTime: meeting.StartTime.Format(time.RFC3339),
			TimeZone: "America/New_York", // Adjust timezone as needed
		},
		End: &calendar.EventDateTime{
			DateTime: meeting.EndTime.Format(time.RFC3339),
			TimeZone: "America/New_York",
		},
		Attendees: []*calendar.EventAttendee{
			{
				Email:       lead.Email,
				DisplayName: lead.Name,
			},
		},
		ConferenceData: &calendar.ConferenceData{
			CreateRequest: &calendar.CreateConferenceRequest{
				RequestId: fmt.Sprintf("lead-%s-%d", lead.ID, time.Now().Unix()),
				ConferenceSolutionKey: &calendar.ConferenceSolutionKey{
					Type: "hangoutsMeet", // Creates Google Meet link automatically
				},
			},
		},
		// Send email notifications to attendees
		RemindersUseDefault: false,
		Reminders: &calendar.EventReminders{
			UseDefault: false,
			Overrides: []*calendar.EventReminder{
				{Method: "email", Minutes: 60},    // 1 hour before
				{Method: "popup", Minutes: 15},    // 15 minutes before
			},
		},
	}

	// Add custom meeting link if provided (e.g., Zoom)
	if meeting.MeetingLink != "" {
		event.Description = fmt.Sprintf("%s\n\nJoin meeting: %s", meeting.Description, meeting.MeetingLink)
		event.Location = meeting.MeetingLink
	}

	// Insert the event
	calendarId := "primary" // Use primary calendar
	createdEvent, err := service.Events.Insert(calendarId, event).
		ConferenceDataVersion(1).
		SendUpdates("all"). // Send invites to all attendees
		Do()
	if err != nil {
		return fmt.Errorf("failed to create calendar event: %v", err)
	}

	log.Printf("✅ Meeting invite sent via Google Calendar: %s", createdEvent.HtmlLink)
	return nil
}
*/

// sendICSInviteEmail sends a meeting invitation as an ICS file attachment via email
func sendICSInviteEmail(client Client, meeting MeetingInvite) error {
	// Generate ICS file content
	icsContent := generateICSFile(client, meeting)

	// Email configuration from environment variables
	smtpHost := os.Getenv("SMTP_HOST")
	if smtpHost == "" {
		smtpHost = "smtp.gmail.com" // Default to Gmail
	}
	smtpPort := os.Getenv("SMTP_PORT")
	if smtpPort == "" {
		smtpPort = "587"
	}
	senderEmail := os.Getenv("SMTP_EMAIL")
	if senderEmail == "" {
		return fmt.Errorf("SMTP_EMAIL environment variable not set")
	}
	senderPassword := os.Getenv("SMTP_PASSWORD")
	if senderPassword == "" {
		return fmt.Errorf("SMTP_PASSWORD environment variable not set")
	}
	senderName := os.Getenv("SMTP_FROM_NAME")
	if senderName == "" {
		senderName = "Personal Finance Advisor"
	}

	// Create email headers
	headers := make(map[string]string)
	headers["From"] = fmt.Sprintf("%s <%s>", senderName, senderEmail)
	headers["To"] = client.Email
	headers["Subject"] = fmt.Sprintf("Meeting Invitation: %s", meeting.MeetingTitle)
	headers["MIME-Version"] = "1.0"
	headers["Content-Type"] = `multipart/mixed; boundary="boundary123"`

	// Create email body with ICS attachment
	var emailBody bytes.Buffer
	
	// Write headers
	for k, v := range headers {
		emailBody.WriteString(fmt.Sprintf("%s: %s\r\n", k, v))
	}
	emailBody.WriteString("\r\n")

	// Write email content
	emailBody.WriteString("--boundary123\r\n")
	emailBody.WriteString("Content-Type: text/plain; charset=\"UTF-8\"\r\n")
	emailBody.WriteString("\r\n")
	emailBody.WriteString(fmt.Sprintf("Hi %s,\r\n\r\n", client.Name))
	emailBody.WriteString(fmt.Sprintf("You have been invited to: %s\r\n\r\n", meeting.MeetingTitle))
	emailBody.WriteString(fmt.Sprintf("When: %s - %s\r\n", 
		meeting.StartTime.Format("Mon, Jan 2, 2006 3:04 PM MST"),
		meeting.EndTime.Format("3:04 PM MST")))
	if meeting.Location != "" {
		emailBody.WriteString(fmt.Sprintf("Where: %s\r\n", meeting.Location))
	}
	if meeting.MeetingLink != "" {
		emailBody.WriteString(fmt.Sprintf("Join online: %s\r\n", meeting.MeetingLink))
	}
	emailBody.WriteString(fmt.Sprintf("\r\n%s\r\n", meeting.Description))
	emailBody.WriteString("\r\nPlease add this meeting to your calendar.\r\n")
	emailBody.WriteString("\r\nBest regards,\r\n")
	emailBody.WriteString(fmt.Sprintf("%s\r\n", senderName))
	emailBody.WriteString("\r\n")

	// Attach ICS file
	emailBody.WriteString("--boundary123\r\n")
	emailBody.WriteString("Content-Type: text/calendar; charset=\"UTF-8\"; method=REQUEST\r\n")
	emailBody.WriteString("Content-Transfer-Encoding: base64\r\n")
	emailBody.WriteString(fmt.Sprintf("Content-Disposition: attachment; filename=\"%s.ics\"\r\n", 
		strings.ReplaceAll(meeting.MeetingTitle, " ", "_")))
	emailBody.WriteString("\r\n")
	emailBody.WriteString(base64.StdEncoding.EncodeToString([]byte(icsContent)))
	emailBody.WriteString("\r\n")
	emailBody.WriteString("--boundary123--\r\n")

	// Send email
	auth := smtp.PlainAuth("", senderEmail, senderPassword, smtpHost)
	
	// Create TLS config for secure connection
	tlsConfig := &tls.Config{
		ServerName: smtpHost,
	}

	// Connect to SMTP server
	conn, err := tls.Dial("tcp", smtpHost+":"+smtpPort, tlsConfig)
	if err != nil {
		// Try non-TLS connection
		auth = smtp.PlainAuth("", senderEmail, senderPassword, smtpHost)
		err = smtp.SendMail(
			smtpHost+":"+smtpPort,
			auth,
			senderEmail,
			[]string{client.Email},
			emailBody.Bytes(),
		)
		if err != nil {
			return fmt.Errorf("failed to send email: %v", err)
		}
	} else {
		conn.Close()
		// Use TLS connection
		err = smtp.SendMail(
			smtpHost+":"+smtpPort,
			auth,
			senderEmail,
			[]string{client.Email},
			emailBody.Bytes(),
		)
		if err != nil {
			return fmt.Errorf("failed to send email with TLS: %v", err)
		}
	}

	log.Printf("✅ Meeting invite sent via email to %s", client.Email)
	return nil
}

// generateICSFile creates an ICS (iCalendar) file content
func generateICSFile(client Client, meeting MeetingInvite) string {
	// Generate unique IDs
	uid := fmt.Sprintf("%s-%d@financeadvisor.com", client.ID, time.Now().Unix())
	timestamp := time.Now().Format("20060102T150405Z")
	
	var ics strings.Builder
	ics.WriteString("BEGIN:VCALENDAR\r\n")
	ics.WriteString("VERSION:2.0\r\n")
	ics.WriteString("PRODID:-//Personal Finance Advisor//Debt Management System//EN\r\n")
	ics.WriteString("METHOD:REQUEST\r\n")
	ics.WriteString("BEGIN:VEVENT\r\n")
	ics.WriteString(fmt.Sprintf("UID:%s\r\n", uid))
	ics.WriteString(fmt.Sprintf("DTSTAMP:%s\r\n", timestamp))
	ics.WriteString(fmt.Sprintf("DTSTART:%s\r\n", meeting.StartTime.Format("20060102T150405Z")))
	ics.WriteString(fmt.Sprintf("DTEND:%s\r\n", meeting.EndTime.Format("20060102T150405Z")))
	ics.WriteString(fmt.Sprintf("SUMMARY:%s\r\n", meeting.MeetingTitle))
	ics.WriteString(fmt.Sprintf("DESCRIPTION:%s\r\n", strings.ReplaceAll(meeting.Description, "\n", "\\n")))
	
	if meeting.Location != "" {
		ics.WriteString(fmt.Sprintf("LOCATION:%s\r\n", meeting.Location))
	}
	
	// Add organizer
	ics.WriteString("ORGANIZER;CN=Jeff - Personal Finance Advisor:mailto:advisor@financehelp.com\r\n")
	
	// Add attendee
	ics.WriteString(fmt.Sprintf("ATTENDEE;CN=%s;RSVP=TRUE;PARTSTAT=NEEDS-ACTION:mailto:%s\r\n", 
		client.Name, client.Email))
	
	// Add alarm (reminder)
	ics.WriteString("BEGIN:VALARM\r\n")
	ics.WriteString("TRIGGER:-PT15M\r\n")
	ics.WriteString("ACTION:DISPLAY\r\n")
	ics.WriteString("DESCRIPTION:Meeting reminder\r\n")
	ics.WriteString("END:VALARM\r\n")
	
	ics.WriteString("STATUS:CONFIRMED\r\n")
	ics.WriteString("TRANSP:OPAQUE\r\n")
	ics.WriteString("END:VEVENT\r\n")
	ics.WriteString("END:VCALENDAR\r\n")
	
	return ics.String()
}

// Example function to integrate with your webhook handler
func handleScheduleMeeting(client Client, args map[string]interface{}) error {
	// Extract meeting details from function arguments
	meetingTitle := "Financial Planning Consultation"
	if title, ok := args["title"].(string); ok {
		meetingTitle = title
	}
	
	// Parse meeting time
	meetingTime := time.Now().Add(24 * time.Hour) // Default to tomorrow
	if dateStr, ok := args["date"].(string); ok {
		if timeStr, ok := args["time"].(string); ok {
			// Parse the date and time
			parsedTime, err := time.Parse("2006-01-02 15:04", dateStr+" "+timeStr)
			if err == nil {
				meetingTime = parsedTime
			}
		}
	}
	
	// Create meeting invite
	meeting := MeetingInvite{
		LeadEmail:    client.Email,
		LeadName:     client.Name,
		MeetingTitle: meetingTitle,
		Description: fmt.Sprintf(
			"Hi %s,\n\nThank you for trusting me with your financial situation. "+
			"In this consultation, we'll review your debt situation and create "+
			"a personalized plan to help you achieve financial freedom.\n\n"+
			"Looking forward to helping you!\n\nBest regards,\nJeff\nPersonal Finance Advisor",
			client.Name),
		StartTime:   meetingTime,
		EndTime:     meetingTime.Add(60 * time.Minute),
		Location:    "Online Meeting",
		MeetingLink: "https://meet.google.com/abc-defg-hij", // Replace with your meeting link
	}
	
	// Send the invite
	return SendMeetingInvite(client, meeting)
}

// Function to create a Calendly-style booking link
func generateBookingLink(client Client) string {
	// Option 1: Use Calendly
	calendlyURL := "https://calendly.com/your-username/60min-financial-consultation"
	
	// Pre-fill client information in the booking link
	params := fmt.Sprintf("?name=%s&email=%s", 
		strings.ReplaceAll(client.Name, " ", "+"),
		client.Email)
	
	return calendlyURL + params
}

// Function to integrate with cal.com API
func createCalComBooking(client Client, timeSlot time.Time) error {
	// This is an example of how to use cal.com API
	// You'll need to sign up for cal.com and get API credentials
	
	// calcomAPIKey := os.Getenv("CALCOM_API_KEY")
	// bookingData := map[string]interface{}{
	// 	"eventTypeId": 12345, // Your event type ID from cal.com
	// 	"start":       timeSlot.Format(time.RFC3339),
	// 	"responses": map[string]string{
	// 		"name":     client.Name,
	// 		"email":    client.Email,
	// 		"province": client.Province,
	// 	},
	// }
	
	// Make API call to cal.com...
	
	return nil
} 