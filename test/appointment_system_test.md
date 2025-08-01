# Appointment System Test Plan

## Overview
This document outlines comprehensive testing scenarios for the appointment booking system, covering different user roles and edge cases.

## Test Environment Setup

### Prerequisites
1. Backend server running with appointment and time slot endpoints
2. Test users with different roles:
   - Patient/Client user
   - Health Worker user
   - Admin user (if applicable)
3. Test health facilities and health workers in database

### Test Data Requirements
- At least 2 health facilities
- At least 3 health workers assigned to facilities
- Sample time slots for health workers
- Sample appointments in different statuses

## Test Scenarios

### 1. Patient/Client Role Tests

#### 1.1 Appointment Booking Flow
**Test Case**: Complete appointment booking process
- [ ] Navigate to appointments screen
- [ ] Tap "Book Appointment" floating action button
- [ ] Verify booking flow opens with 5 steps
- [ ] Step 1: Select health facility (if not pre-selected)
- [ ] Step 2: Choose health worker from available list
- [ ] Step 3: Select available time slot
- [ ] Step 4: Fill appointment details (type, reason, notes)
- [ ] Step 5: Review and confirm booking
- [ ] Verify appointment appears in "Upcoming" tab
- [ ] Verify appointment has correct status (SCHEDULED)

#### 1.2 Appointment Viewing
**Test Case**: View appointments in different tabs
- [ ] Verify "Upcoming" tab shows future appointments
- [ ] Verify "Past" tab shows completed/past appointments
- [ ] Verify "All" tab shows all appointments sorted by date
- [ ] Test pull-to-refresh functionality
- [ ] Verify appointment cards show correct information

#### 1.3 Appointment Management
**Test Case**: Cancel and reschedule appointments
- [ ] Cancel an upcoming appointment
- [ ] Provide cancellation reason
- [ ] Verify appointment status changes to CANCELLED
- [ ] Attempt to reschedule an appointment
- [ ] Verify new date/time is updated
- [ ] Verify status changes to RESCHEDULED

#### 1.4 Appointment Details
**Test Case**: View detailed appointment information
- [ ] Tap on appointment card
- [ ] Verify all appointment details are displayed
- [ ] Verify health worker information is shown
- [ ] Verify facility information is shown
- [ ] Test action buttons (Cancel, Reschedule)

### 2. Health Worker Role Tests

#### 2.1 Appointment Management
**Test Case**: Health worker appointment view
- [ ] Login as health worker
- [ ] Navigate to appointments screen
- [ ] Verify 4 tabs: Today, Upcoming, Past, Manage Slots
- [ ] Verify "Today" tab shows only today's appointments
- [ ] Verify appointments show patient information
- [ ] Test appointment status updates (Confirmed, In Progress, Completed)

#### 2.2 Time Slot Management
**Test Case**: Create and manage time slots
- [ ] Navigate to "Manage Slots" tab
- [ ] Verify navigation to Time Slot Management screen
- [ ] Test "Create Time Slot" functionality
- [ ] Verify time slots appear in appropriate tabs (Today, Week, All)
- [ ] Test edit time slot functionality
- [ ] Test delete time slot with confirmation
- [ ] Verify deleted slots are removed from list

#### 2.3 Time Slot Filtering
**Test Case**: Filter time slots by date and period
- [ ] Test date selector functionality
- [ ] Verify "Today" tab shows only today's slots
- [ ] Verify "This Week" tab shows current week's slots
- [ ] Verify "All Slots" tab shows all time slots
- [ ] Test refresh functionality

#### 2.4 Appointment Status Management
**Test Case**: Update appointment statuses
- [ ] View today's appointments
- [ ] Update appointment status to "Confirmed"
- [ ] Update appointment status to "In Progress"
- [ ] Complete an appointment (status: "Completed")
- [ ] Mark patient as "No Show"
- [ ] Verify status changes are reflected immediately

### 3. Cross-Role Integration Tests

#### 3.1 Booking to Management Flow
**Test Case**: End-to-end appointment lifecycle
- [ ] Patient books appointment with health worker
- [ ] Health worker sees appointment in their schedule
- [ ] Health worker confirms appointment
- [ ] Patient sees status change to "Confirmed"
- [ ] Health worker marks as "In Progress" on appointment day
- [ ] Health worker completes appointment
- [ ] Patient sees completed appointment in "Past" tab

#### 3.2 Time Slot Availability
**Test Case**: Time slot booking and availability
- [ ] Health worker creates time slots for specific dates
- [ ] Patient sees available time slots during booking
- [ ] Patient books a time slot
- [ ] Verify time slot shows as booked/unavailable
- [ ] Health worker sees appointment in their schedule
- [ ] Test maximum appointments per time slot

### 4. Error Handling Tests

#### 4.1 Network Error Scenarios
**Test Case**: Handle network connectivity issues
- [ ] Disconnect network during appointment loading
- [ ] Verify graceful error handling with user-friendly message
- [ ] Test retry functionality when network is restored
- [ ] Verify offline state handling

#### 4.2 Validation Tests
**Test Case**: Form validation and data integrity
- [ ] Try to book appointment without selecting health worker
- [ ] Try to book appointment without selecting time slot
- [ ] Submit appointment form with missing required fields
- [ ] Verify appropriate validation messages
- [ ] Test date/time validation (no past dates)

#### 4.3 Permission Tests
**Test Case**: Role-based access control
- [ ] Patient tries to access health worker features
- [ ] Verify appropriate restrictions are in place
- [ ] Test unauthorized actions return proper errors
- [ ] Verify UI elements are hidden based on role

### 5. Performance Tests

#### 5.1 Data Loading Performance
**Test Case**: Large dataset handling
- [ ] Load appointments screen with 100+ appointments
- [ ] Verify smooth scrolling and performance
- [ ] Test pagination if implemented
- [ ] Verify memory usage remains reasonable

#### 5.2 Real-time Updates
**Test Case**: State synchronization
- [ ] Book appointment and verify immediate UI update
- [ ] Cancel appointment and verify status change
- [ ] Test multiple rapid operations
- [ ] Verify data consistency across screens

### 6. UI/UX Tests

#### 6.1 Responsive Design
**Test Case**: Different screen sizes and orientations
- [ ] Test on different device sizes (phone, tablet)
- [ ] Test portrait and landscape orientations
- [ ] Verify UI elements are properly sized and positioned
- [ ] Test accessibility features

#### 6.2 Navigation Flow
**Test Case**: User journey and navigation
- [ ] Test back button behavior in booking flow
- [ ] Verify proper navigation between screens
- [ ] Test deep linking to specific appointments
- [ ] Verify proper state preservation during navigation

### 7. Edge Cases

#### 7.1 Boundary Conditions
**Test Case**: Edge case scenarios
- [ ] Book appointment for maximum future date allowed
- [ ] Test with health worker having no available slots
- [ ] Test with facility having no health workers
- [ ] Handle appointment conflicts and double-booking

#### 7.2 Data Consistency
**Test Case**: Data integrity scenarios
- [ ] Health worker deletes time slot with existing appointment
- [ ] Patient cancels appointment after health worker confirms
- [ ] Test concurrent booking of same time slot
- [ ] Verify proper error handling and user notification

## Test Execution Checklist

### Pre-Test Setup
- [ ] Backend server is running and accessible
- [ ] Test database is populated with required data
- [ ] Test users are created with appropriate roles
- [ ] App is built and deployed to test environment

### Test Execution
- [ ] Execute all patient role tests
- [ ] Execute all health worker role tests
- [ ] Execute integration tests
- [ ] Execute error handling tests
- [ ] Execute performance tests
- [ ] Execute UI/UX tests
- [ ] Execute edge case tests

### Post-Test Validation
- [ ] Verify all test cases pass
- [ ] Document any failures or issues
- [ ] Verify data consistency in database
- [ ] Clean up test data if necessary

## Success Criteria

The appointment system test is considered successful when:
1. All core functionality works as expected for both user roles
2. Error handling is graceful and user-friendly
3. Performance is acceptable under normal load
4. UI/UX provides smooth user experience
5. Data integrity is maintained across all operations
6. Role-based permissions are properly enforced

## Known Issues and Limitations

Document any known issues or limitations discovered during testing:
- [ ] Issue 1: Description and workaround
- [ ] Issue 2: Description and workaround
- [ ] Limitation 1: Description and impact
- [ ] Limitation 2: Description and impact

## Test Results Summary

| Test Category | Total Tests | Passed | Failed | Notes |
|---------------|-------------|--------|--------|-------|
| Patient Role | TBD | TBD | TBD | TBD |
| Health Worker Role | TBD | TBD | TBD | TBD |
| Integration | TBD | TBD | TBD | TBD |
| Error Handling | TBD | TBD | TBD | TBD |
| Performance | TBD | TBD | TBD | TBD |
| UI/UX | TBD | TBD | TBD | TBD |
| Edge Cases | TBD | TBD | TBD | TBD |
| **TOTAL** | **TBD** | **TBD** | **TBD** | **TBD** |
