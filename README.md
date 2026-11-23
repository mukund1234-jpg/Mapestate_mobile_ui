# Project Name: Mapestate Mobile CRM

## Project Overview

Develop a complete Real Estate CRM mobile application named Mapestate using Flutter, RiverPod for State Mangement

The application will be used by two types of users:

1. Manager
2. Sales Executive
3. Admin

The main purpose is to help sales teams receive new leads, call customers, manage follow-ups, schedule property visits and convert leads into bookings.

The application must connect with the existing Mapestate FastAPI backend.

## 1. Authentication

- Login with mobile number and password.
- Role-based navigation Lead Show.
- Manager login.
- Sales Executive login.
- Secure token management.
- Logout functionality.

After login, redirect users based on their role.

## 2. Manager Module

Create a professional Manager Dashboard.

Dashboard statistics:
- Total Sales Executives.
- Total Leads.
- Unassigned Leads.
- Assigned Leads.
- Today's Calls.
- Pending Follow-ups.
- Overdue Follow-ups.
- Today's Site Visits.
- Total Bookings.
- Converted Leads.

Manager functionalities:

- View all sales executives.
- Add and manage team members.
- Assign new leads to sales executives.
- Reassign leads.
- View executive-wise lead performance.
- Monitor call activities.
- Track pending follow-ups.
- Monitor site visits.
- View bookings and deal status.
- View team performance reports.

## 3. Sales Executive Module

Create a separate Sales Executive Dashboard.

Dashboard statistics:
- Today's New Leads.
- My Total Leads.
- Today's Calls.
- Pending Follow-ups.
- Overdue Follow-ups.
- Upcoming Site Visits.
- Converted Leads.

## 4. Lead Management

Create a My Leads screen.

Each lead should contain:

- Lead ID.
- Customer Name.
- Phone Number.
- Email.
- Interested Property.
- Property Type.
- Budget.
- Preferred Location.
- Lead Source.
- Lead Priority.
- Assigned Date.
- Lead Status.

Lead statuses:

- New
- Assigned
- Contacted
- Interested
- Follow-up
- Site Visit
- Negotiation
- Booked
- Converted
- Lost

Features:
- Search leads.
- Filter by status.
- Filter by priority.
- View lead details.
- Update lead status.
- Call customer.
- Send WhatsApp message.
- Schedule follow-up.

## 5. Customer Calling Module

Implement a Call Customer button.

Use React Native Linking to open the device phone dialer.

After a call, allow the sales executive to save:

- Customer Name.
- Phone Number.
- Call Date.
- Call Time.
- Call Duration (if available).
- Call Outcome.
- Call Notes.
- Next Follow-up Date.

Call outcomes:

- Connected.
- Not Answered.
- Busy.
- Interested.
- Not Interested.
- Call Back Later.

Save all call activities through the FastAPI backend.

Do not assume that opening the phone dialer automatically provides call logs or call duration.

## 6. Follow-up Management

Create a dedicated Follow-up screen.

Sections:

- Today's Follow-ups.
- Upcoming Follow-ups.
- Pending Follow-ups.
- Overdue Follow-ups.
- Completed Follow-ups.

Each follow-up contains:

- Customer Name.
- Lead ID.
- Assigned Executive.
- Follow-up Date.
- Follow-up Time.
- Follow-up Type.
- Notes.
- Status.

Allow executives to complete or reschedule follow-ups.

Implement push notifications and reminders where supported.

## 7. Site Visit Management

- Schedule a property visit.
- Select customer.
- Select property.
- Choose date and time.
- Add