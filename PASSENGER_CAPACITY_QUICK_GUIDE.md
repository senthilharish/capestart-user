# Passenger Capacity - Quick Reference

## What Was Added

### 1. RideModel Fields
```dart
final int numberOfPassengers;           // Passengers currently booked
final int numberOfPassengersAllocated;  // Total ride capacity
```

### 2. RideDetailPage Features
- **Seat Availability Card** - Shows total, booked, and available seats with progress bar
- **Smart Book Seat Button** - Only shows when seats available
- **No Seats Message** - Shows when ride is fully booked
- **Seat Validation** - Dialog respects available seat limit

---

## How It Works

### Checking Seat Availability
```dart
// In RideDetailPage
if (ride.numberOfPassengers < ride.numberOfPassengersAllocated) {
  // Show "Book Seat" button
} else {
  // Show "No Seats Available" message
}
```

### Calculating Available Seats
```dart
final availableSeats = ride.numberOfPassengersAllocated - ride.numberOfPassengers;
// Example: 4 - 2 = 2 seats available
```

### Seat Selection Validation
```dart
// In booking dialog
if (seatsToBook < availableSeats) {
  // Allow incrementing
}
```

---

## UI Components

### Seat Availability Card
```
┌─────────────────────────────────────┐
│ 🪑 Seat Status                      │
│                                     │
│ Total Seats   │ 4                   │
│ Booked        │ 2                   │
│ Available     │ 2                   │
│                                     │
│ ████████░░░░  50% Occupied          │
└─────────────────────────────────────┘
```

### Book Seat Button
```
✅ SEATS AVAILABLE:
┌─────────────────────────────────────┐
│ Book Seat (2 available)             │  ← Green button
└─────────────────────────────────────┘

❌ FULLY BOOKED:
┌─────────────────────────────────────┐
│ No Seats Available                  │  ← Red message
└─────────────────────────────────────┘
```

---

## Example Scenarios

### Scenario 1: 3 Seats Available
```
Total: 4 | Booked: 1 | Available: 3
Button: "Book Seat (3 available)" ✅
Dialog: Can select 1, 2, or 3 seats
```

### Scenario 2: 1 Seat Available
```
Total: 4 | Booked: 3 | Available: 1
Button: "Book Seat (1 available)" ✅
Dialog: Can select only 1 seat
```

### Scenario 3: No Seats Available
```
Total: 4 | Booked: 4 | Available: 0
Button: "No Seats Available" ❌
Dialog: Not shown
```

---

## Firestore Data

### Ride Record
```json
{
  "rideId": "ride_001",
  "numberOfPassengers": 2,
  "numberOfPassengersAllocated": 4
}
```

### Available Seats Calculation
```
availableSeats = numberOfPassengersAllocated - numberOfPassengers
              = 4 - 2
              = 2 seats available
```

---

## Color Coding

### Progress Bar
- 🟢 **Green**: 0-50% occupied (plenty available)
- 🟠 **Orange**: 51-75% occupied (limited spots)
- 🔴 **Red**: 76-100% occupied (almost full/full)

### Button
- 🟢 **Green**: "Book Seat (X available)" - seats available
- 🔴 **Red**: "No Seats Available" - fully booked

---

## Booking Constraints

### Maximum Seats to Book
```dart
maxSeatsToBook = numberOfPassengersAllocated - numberOfPassengers
```

### Example
If ride has:
- `numberOfPassengersAllocated = 4`
- `numberOfPassengers = 2`

Then:
- `maxSeatsToBook = 4 - 2 = 2`
- User can book 1 or 2 seats
- Cannot book 3 or more

---

## Files Modified

| File | Changes |
|------|---------|
| `ride_model.dart` | Added `numberOfPassengers` and `numberOfPassengersAllocated` |
| `ride_detail_page.dart` | Added seat availability card, smart button logic, dialog validation |

---

## Key Methods

### RideDetailPage
```dart
// Display seat information
Widget _buildSeatAvailabilityCard(int totalSeats, int bookedSeats)

// Show booking dialog with seat limit
void _showBookSeatDialog(
  BuildContext context,
  String rideId,
  double pricePerSeat,
  int availableSeats,
)
```

---

## Testing Quick Checks

✅ Create rides with different passenger counts  
✅ Open ride with available seats → "Book Seat" button shown  
✅ Open ride without seats → "No Seats Available" shown  
✅ Try to book more seats than available → Dialog limits selection  
✅ Seat availability card shows correct numbers  
✅ Progress bar updates based on occupancy  

---

## Next Steps

1. **Test with real data** - Verify with rides in Firestore
2. **Update bookings** - When booking created, increment `numberOfPassengers`
3. **Real-time sync** - Update ride record when booking made
4. **Cancellation** - Decrement `numberOfPassengers` when booking cancelled
5. **Analytics** - Track occupancy metrics

---

## Summary

The ride capacity system now:
- ✅ Tracks current vs. allocated passengers
- ✅ Shows seat availability visually
- ✅ Prevents overbooking in UI
- ✅ Provides clear feedback to users
- ✅ Validates seat selections
