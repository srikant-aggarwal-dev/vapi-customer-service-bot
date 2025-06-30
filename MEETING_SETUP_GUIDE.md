# Meeting Invite Setup Guide

This guide will help you set up meeting invitations for your VAPI lead generation bot.

## Overview

The meeting invite feature allows Alex (your AI assistant) to schedule meetings with leads and automatically send calendar invitations via email.

## Configuration

### 1. Email Configuration

Update your environment variables with SMTP settings. For Gmail:

```bash
export SMTP_HOST=smtp.gmail.com
export SMTP_PORT=587
export SMTP_EMAIL=your-email@gmail.com
export SMTP_PASSWORD=your-app-password  # NOT your regular password!
export SMTP_FROM_NAME="Your Company Sales Team"
```

**Important**: For Gmail, you need to:

1. Enable 2-factor authentication
2. Generate an app-specific password at https://myaccount.google.com/apppasswords
3. Use the app password, NOT your regular Gmail password

### 2. Meeting Link Configuration

Set your default meeting link:

```bash
export DEFAULT_MEETING_LINK=https://meet.google.com/your-meeting-code
```

Options:

- **Google Meet**: `https://meet.google.com/abc-defg-hij`
- **Zoom**: `https://zoom.us/j/1234567890?pwd=yourpassword`
- **Calendly**: `https://calendly.com/yourname/30min`
- **Cal.com**: `https://cal.com/yourname/meeting`

### 3. Update the Code

In `server/meeting_invite.go`, update the email configuration:

```go
// Around line 113-117
smtpHost := os.Getenv("SMTP_HOST")
smtpPort := os.Getenv("SMTP_PORT")
senderEmail := os.Getenv("SMTP_EMAIL")
senderPassword := os.Getenv("SMTP_PASSWORD")
senderName := os.Getenv("SMTP_FROM_NAME")
```

And update the meeting link:

```go
// Around line 289
MeetingLink: os.Getenv("DEFAULT_MEETING_LINK"),
```

## How It Works

1. **During Call**: When a lead expresses interest, Alex can use the `schedule_meeting` function
2. **Function Parameters**:

   - `date`: Meeting date (YYYY-MM-DD format)
   - `time`: Meeting time (HH:MM format, 24-hour)
   - `duration`: Duration in minutes (default: 30)
   - `title`: Meeting title
   - `meeting_type`: Type of meeting (demo, consultation, follow-up)

3. **What Happens**:
   - Meeting details are captured
   - An ICS calendar file is generated
   - Email with calendar invite is sent to the lead
   - Lead status is updated to "scheduled"

## Example Conversation

**Lead**: "I'd like to see a demo of your product"

**Alex**: "I'd be happy to schedule a demo for you! How does tomorrow at 2 PM work for you?"

**Lead**: "That works great!"

**Alex**: _[Uses schedule_meeting function]_ "Perfect! I've scheduled a 30-minute product demo for tomorrow at 2 PM. You'll receive a calendar invitation at your email address shortly."

## Testing

1. Make a test call to your assistant
2. Express interest in scheduling a meeting
3. Provide your email when asked
4. Confirm a date and time
5. Check your email for the calendar invitation

## Alternative: Google Calendar Integration

If you prefer direct Google Calendar integration (with automatic meeting link generation):

1. Set up a Google Cloud project
2. Enable Calendar API
3. Download credentials.json
4. Uncomment the Google Calendar code in `meeting_invite.go`
5. Install the dependency: `go get google.golang.org/api/calendar/v3`

## Troubleshooting

### Email not sending?

- Check SMTP credentials
- Ensure app password is used (not regular password)
- Check firewall/network settings
- Look for error messages in server logs

### Calendar invite not showing?

- Some email clients hide .ics attachments
- Check spam folder
- Try a different email provider

### Wrong timezone?

- Update timezone in the ICS generation code
- Default is UTC, adjust as needed

## Customization

You can customize:

- Email templates
- Meeting durations
- Default meeting types
- Reminder times
- Calendar event details

## Security Notes

- Never commit credentials to git
- Use environment variables for sensitive data
- Consider using a dedicated email account for sending
- Implement rate limiting to prevent abuse
