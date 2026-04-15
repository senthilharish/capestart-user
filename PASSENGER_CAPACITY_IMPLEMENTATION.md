# Passenger Capacity Management Implementation

## Overview
Implemented passenger capacity tracking for rides with dynamic seat availability management. Users can now only book seats if the ride has available capacity.

## Changes Made

### 1. RideModel Updates (`lib/models/ride_model.dart`)

**New Fields Added:**
```dart
final int numberOfPassengers;           // Current number of passengers booked
final int numberOfPassengersAllocated;  // Total capacity of the ride
```

**Updated Methods:**
- Constructor: Added required parameters for both fields
- `toJson()`: Includes both passenger fields in Firestore serialization
- `fromJson()`: Deserializes passenger data with defaults (0 and 4)
- `copyWith()`: Allows updating passenger counts

**Default Values:**
- `numberOfPassengers`: 0 (starts at zero)
- `numberOfPassengersAllocated`: 4 (default capacity)

**Helper Property:**
```dart
int get availableSeats => numberOfPassengersAllocated - numberOfPassengers;
```

---

### 2. RideDetailPage Updates (`lib/views/home/pages/ride_detail_page.dart`)

#### A. Book Seat Button Logic
**Condition:** Button shows only if `numberOfPassengers < numberOfPassengersAllocated`

**Button States:**

**1. Seats Available:**
```
┌────────────────────────────────────┐
│ Book Seat (3 available)            │
└────────────────────────────────────┘
```
- Green button
- Shows available seat count
- Enabled for clicking

**2. No Seats Available:**
```
┌────────────────────────────────────┐
│ No Seats Available                 │
└────────────────────────────────────┘
```
- Red background
- Disabled state
- Message shown instead of button

#### B. Seat Selection Dialog
**Updates:**
- Shows available seat count in dialog title
- "How many seats do you want to book? (3 available)"
- Increment button respects seat limit (can't exceed `availableSeats`)
- Decrement button works as before (minimum 1 seat)

**Logic:**
```dart
if (seatsToBook < availableSeats) {
  setState(() {
    seatsToBook++;
  });
}
```

#### C. New Seat Availability Section
**Location:** Added before action buttons in ride details

**Displays:**
1. **Seat Status Card** showing:
   - Total seats available on ride
   - Number of seats currently booked
   - Number of seats available
   - Occupancy percentage
   - Visual progress bar

**Card Features:**
- Green when seats available
- Red when fully booked
- Color-coded progress bar:
  - 🟢 Green: 0-50% occupied
  - 🟠 Orange: 51-75% occupied
  - 🔴 Red: >75% occupied

**Example Display:**
```
┌─────────────────────────────┐
│ 🪑 Seat Status              │
│                             │
│ Total Seats    │ 4          │
│ Booked         │ 2 (orange) │
│ Available      │ 2 (green)  │
│                             │
│ ████████░░░░ 50% Occupied   │
└─────────────────────────────┘
```

---

## Data Flow

### Ride Creation (Backend)
```
Driver creates ride:
  - numberOfPassengersAllocated = 4 (ride capacity)
  - numberOfPassengers = 0 (starts at 0)
  - Saved to Firestore
```

### Passenger Books Seat
```
1. User opens RideDetailPage
2. Sees seat availability card
3. Checks: numberOfPassengers (2) < numberOfPassengersAllocated (4) ?
4. YES → Shows "Book Seat (2 available)" button
5. User clicks button → Seat selection dialog
6. User selects seats (max: 2 to not exceed capacity)
7. Confirms booking
8. Booking created with selected seat count
9. numberOfPassengers incremented on ride record
```

### Ride Fully Booked
```
1. numberOfPassengers (4) = numberOfPassengersAllocated (4)
2. Button disabled → Shows "No Seats Available"
3. No booking dialog shown
4. Passengers cannot book
```

---

## Firestore Data Structure

### Before (Old RideModel)
```json
{
  "rideId": "ride_001",
  "driverId": "driver_123",
  "startAddress": "Point A",
  "destinationAddress": "Point B",
  "totalPrice": 500,
  "status": "pending"
}
```

### After (Updated RideModel)
```json
{
  "rideId": "ride_001",
  "driverId": "driver_123",
  "startAddress": "Point A",
  "destinationAddress": "Point B",
  "totalPrice": 500,
  "status": "pending",
  "numberOfPassengers": 2,
  "numberOfPassengersAllocated": 4
}
```

---

## Architecture

```
RideModel
├── numberOfPassengers (current bookings)
└── numberOfPassengersAllocated (capacity)

RideDetailPage
├── Displays seat availability card
│   ├── Shows total/booked/available breakdown
│   ├── Shows occupancy percentage
│   └── Visual progress bar
│
├── Conditionally shows "Book Seat" button
│   ├── If seats available: Green button
│   └── If fully booked: Red "No Seats" message
│
└── Seat selection dialog
    └── Limits selection to available seats
```

---

## UI Components

### 1. Seat Availability Card
```dart
_buildSeatAvailabilityCard(
  int totalSeats,      // numberOfPassengersAllocated
  int bookedSeats      // numberOfPassengers
)
```

**Returns:**
- Container with seat status information
- Color-coded based on availability
- Progress bar showing occupancy
- Three-column layout: Total | Booked | Available

### 2. Book Seat Button
```dart
if (ride.numberOfPassengers < ride.numberOfPassengersAllocated) {
  // Show green "Book Seat" button
  // With available count badge
} else {
  // Show red "No Seats Available" message
}
```

### 3. Seat Selection Dialog
```dart
_showBookSeatDialog(
  BuildContext context,
  String rideId,
  double pricePerSeat,
  int availableSeats  // NEW parameter
)
```

**Dialog Features:**
- Increment/Decrement buttons for seat count
- Respects `availableSeats` limit
- Shows total price (seats × pricePerSeat)
- Confirm/Cancel buttons

---

## Booking Logic

### Validation
When user tries to book:
1. Check `numberOfPassengers < numberOfPassengersAllocated`
2. If true: Show booking dialog
3. If false: Show "No Seats Available"

### Seat Count Validation
In dialog:
1. User selects `seatsToBook`
2. Validate: `seatsToBook <= availableSeats`
3. If valid: Allow increment
4. If invalid: Disable increment button

### After Booking Confirmation
```
1. Create booking record with seatsBooked
2. Update ride: numberOfPassengers += seatsToBook
3. Show success message
4. Refresh ride details (optional)
```

---

## Example Scenarios

### Scenario 1: Ride with Available Seats
```
numberOfPassengersAllocated = 4
numberOfPassengers = 1
availableSeats = 3

Button: "Book Seat (3 available)" ✅ Green
Dialog: Can select 1, 2, or 3 seats
Max seats in dialog: 3
```

### Scenario 2: Ride Nearly Full
```
numberOfPassengersAllocated = 4
numberOfPassengers = 3
availableSeats = 1

Button: "Book Seat (1 available)" ✅ Green
Dialog: Can select only 1 seat
Max seats in dialog: 1
Increment button: Disabled after selecting 1
```

### Scenario 3: Ride Fully Booked
```
numberOfPassengersAllocated = 4
numberOfPassengers = 4
availableSeats = 0

Button: "No Seats Available" ❌ Red
Dialog: Not shown
Increment button: Disabled from start
```

---

## Occupancy Indicator

### Progress Bar Colors
| Occupancy | Color | Meaning |
|-----------|-------|---------|
| 0-50% | 🟢 Green | Plenty available |
| 51-75% | 🟠 Orange | Limited spots |
| 76-100% | 🔴 Red | Almost full |

### Example Display
```
Total: 4, Booked: 2, Available: 2
████████░░░░ 50% Occupied

Total: 4, Booked: 3, Available: 1
██████████░░ 75% Occupied

Total: 4, Booked: 4, Available: 0
████████████ 100% Occupied
```

---

## Compilation Status

✅ **RideModel** - No errors
- Fields added: `numberOfPassengers`, `numberOfPassengersAllocated`
- Constructor updated with required parameters
- Serialization methods updated
- copyWith method updated

✅ **RideDetailPage** - No errors
- Seat availability card implemented
- Book Seat button logic updated
- Seat selection dialog respects available seats
- UI components properly integrated

---

## Testing Checklist

### Unit Tests
- [ ] Verify RideModel serialization with passenger fields
- [ ] Verify RideModel deserialization with defaults
- [ ] Calculate available seats: `numberOfPassengersAllocated - numberOfPassengers`

### Integration Tests
- [ ] Open ride with available seats → "Book Seat" button shown
- [ ] Open ride without available seats → "No Seats Available" shown
- [ ] Click "Book Seat" → Seat selection dialog appears
- [ ] Dialog shows correct available seat count
- [ ] Increment button respects seat limit
- [ ] Select seats and confirm → Booking created

### UI Tests
- [ ] Seat availability card displays correctly
- [ ] Progress bar shows correct occupancy percentage
- [ ] Color coding matches occupancy level
- [ ] Available seats count updates on dialog
- [ ] Price calculation updates correctly
- [ ] Dialog validation works properly

### Edge Cases
- [ ] Ride with 0 available seats
- [ ] Ride with 1 available seat
- [ ] Ride with all seats available
- [ ] User tries to book more seats than available
- [ ] Multiple users booking simultaneously (if needed)

---

## Future Enhancements

1. **Dynamic Capacity Adjustment**
   - Allow drivers to change capacity mid-ride
   - Update `numberOfPassengersAllocated` dynamically

2. **Seat Reservations**
   - Add reserved seat concept
   - Track which specific seats are booked

3. **Waitlist**
   - Add users to waitlist if fully booked
   - Notify when seat becomes available

4. **Group Bookings**
   - Allow booking specific seat groups
   - Reserve adjacent seats

5. **Refund on Cancellation**
   - When booking cancelled: `numberOfPassengers -= seatsBooked`
   - Update available seats in real-time

6. **Analytics**
   - Track occupancy rates
   - Predict demand
   - Optimize pricing based on demand

7. **Real-time Updates**
   - Stream real-time seat availability
   - Show live occupancy changes
   - Prevent overbooking with live validation

---

## API Reference

### RideModel Updates
```dart
class RideModel {
  final int numberOfPassengers;           // Current bookings
  final int numberOfPassengersAllocated;  // Total capacity
  
  int get availableSeats => 
    numberOfPassengersAllocated - numberOfPassengers;
    
  bool get hasAvailableSeats => availableSeats > 0;
  bool get isFullyBooked => availableSeats == 0;
  
  double get occupancyPercentage => 
    (numberOfPassengers / numberOfPassengersAllocated) * 100;
}
```

### RideDetailPage Methods
```dart
Widget _buildSeatAvailabilityCard(int totalSeats, int bookedSeats)

void _showBookSeatDialog(
  BuildContext context,
  String rideId,
  double pricePerSeat,
  int availableSeats,  // NEW
)
```

---

## Related Files

- `lib/models/ride_model.dart` - Updated with passenger fields
- `lib/views/home/pages/ride_detail_page.dart` - Updated UI logic
- `lib/services/ride_service.dart` - Firestore operations (uses updated model)
- `lib/controllers/ride_controller.dart` - State management (uses updated model)
- `lib/views/home/home_page.dart` - Shows rides (uses updated model)

---

## Summary

The app now has:
- ✅ Passenger capacity tracking in rides
- ✅ Dynamic seat availability management
- ✅ Visual seat availability indicator
- ✅ Smart booking button logic
- ✅ Seat count validation in booking dialog
- ✅ Color-coded occupancy display
- ✅ User-friendly seat information

Users can only book seats when the ride has available capacity, with clear visual feedback on seat availability and occupancy status.
