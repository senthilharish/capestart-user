import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_constants.dart';
import '../../../controllers/ride_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/booking_controller.dart';

class RideDetailPage extends StatefulWidget {
  final String rideId;

  const RideDetailPage({
    Key? key,
    required this.rideId,
  }) : super(key: key);

  @override
  State<RideDetailPage> createState() => _RideDetailPageState();
}

class _RideDetailPageState extends State<RideDetailPage> {
  late RideController _rideController;

  @override
  void initState() {
    super.initState();
    _rideController = context.read<RideController>();
    _loadRideDetails();
    // Repair any missing passenger data on first load - call asynchronously
    Future.microtask(() => _rideController.repairPassengerData());
  }

  void _loadRideDetails() {
    _rideController.fetchRideDetails(widget.rideId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _rideController.clearSelectedRide();
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<RideController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConstants.primaryColor,
                ),
              ),
            );
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppConstants.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${controller.errorMessage}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadRideDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final ride = controller.selectedRide;
          final driver = controller.selectedDriver;

          if (ride == null) {
            return const Center(
              child: Text('Ride not found'),
            );
          }

          // DEBUG: Log ride data
          print('DEBUG: Ride loaded - numberOfPassengers: ${ride.numberOfPassengers}, numberOfPassengersAllocated: ${ride.numberOfPassengersAllocated}');
          print('DEBUG: Seats available: ${ride.numberOfPassengersAllocated - ride.numberOfPassengers}');
          print('DEBUG: Show button? ${ride.numberOfPassengers < ride.numberOfPassengersAllocated}');

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status card
                  _buildStatusCard(ride.status),
                  const SizedBox(height: AppConstants.paddingLarge * 2),

                  // Driver information (if available)
                  if (driver != null) ...[
                    _buildSectionTitle('Driver Information'),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _buildDriverCard(driver),
                    const SizedBox(height: AppConstants.paddingLarge * 2),
                  ],

                  // Ride locations
                  _buildSectionTitle('Route'),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildLocationCard(
                    title: 'Pickup Location',
                    address: ride.startAddress,
                    icon: Icons.location_on,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildLocationCard(
                    title: 'Destination',
                    address: ride.destinationAddress,
                    icon: Icons.flag,
                    color: AppConstants.errorColor,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge * 2),

                  // Ride information
                  _buildSectionTitle('Ride Information'),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildInfoGrid([
                    _InfoItem('Status', ride.status.toUpperCase()),
                    if (ride.distance != null)
                      _InfoItem('Distance', ride.distance ?? 'N/A'),
                    if (ride.rideDuration != null)
                      _InfoItem('Duration', ride.rideDuration ?? 'N/A'),
                  ]),
                  const SizedBox(height: AppConstants.paddingLarge * 2),

                  // Price breakdown
                  _buildSectionTitle('Price Breakdown'),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildPriceItem('Base Price', ride.totalPrice),
                  if (ride.additionalPrice != null && ride.additionalPrice! > 0)
                    _buildPriceItem(
                      'Additional Charges',
                      ride.additionalPrice!,
                    ),
                  const Divider(height: 24),
                  _buildPriceItem(
                    'Total',
                    ride.additionalPrice != null
                        ? ride.totalPrice + ride.additionalPrice!
                        : ride.totalPrice,
                    isTotal: true,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge * 2),

                  // Location coordinates (if available)
                  if (ride.latitude != null && ride.longitude != null) ...[
                    _buildSectionTitle('Current Location'),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _buildCoordinateCard(
                      ride.latitude!,
                      ride.longitude!,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge * 2),
                  ],

                  // Timestamps
                  _buildSectionTitle('Timeline'),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildTimelineItem(
                    'Ride Created',
                    _formatDateTime(ride.createdAt),
                    Icons.create,
                  ),
                  if (ride.completedAt != null)
                    _buildTimelineItem(
                      'Ride Completed',
                      _formatDateTime(ride.completedAt!),
                      Icons.check_circle,
                    ),
                  const SizedBox(height: AppConstants.paddingLarge * 2),

                  // Seat Availability
                  _buildSectionTitle('Seat Availability'),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildSeatAvailabilityCard(
                    ride.numberOfPassengers,
                    ride.numberOfPassengersAllocated,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge * 2),

                  // Action buttons
                  if (ride.isActive) ...[
                    // Calculate available seats
                    Builder(
                      builder: (context) {
                        final shouldShowBookButton = ride.numberOfPassengersAllocated < ride.numberOfPassengers;
                        
                        return Column(
                          children: [
                            if (shouldShowBookButton) ...[
                              // ENABLED Button - Green when should book
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: () => _showBookSeatDialog(
                                    context,
                                    ride.rideId,
                                    ride.totalPrice,
                                    ride.numberOfPassengers,
                                  ),
                                  child: const Text(
                                    'Book Now',
                                    style: TextStyle(fontSize: AppConstants.fontSizeMedium),
                                  ),
                                ),
                              ),
                            ] else ...[
                              // DISABLED Button - Grey when not available for booking
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade400,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: null,
                                  child: const Text(
                                    'Not Available',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeMedium,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: AppConstants.paddingMedium),
                          ],
                        );
                      },
                    ),
                  ],
                  if (ride.isActive && ride.status.toLowerCase() == 'accepted')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () =>
                            _showCancelDialog(context, ride.rideId),
                        child: const Text(
                          'Cancel Ride',
                          style: TextStyle(fontSize: AppConstants.fontSizeMedium),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    final Color color = _getStatusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(status),
            color: color,
            size: 32,
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Status',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppConstants.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeXLarge,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(dynamic driver) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Row(
        children: [
          // Driver avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
            child: driver.profileImageUrl != null
                ? Image.network(driver.profileImageUrl!)
                : Icon(
                    Icons.person,
                    size: 40,
                    color: AppConstants.primaryColor,
                  ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          // Driver details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeXLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${driver.rating?.toStringAsFixed(1) ?? 'N/A'} (${driver.totalRides ?? 0} rides)',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${driver.vehicleModel} • ${driver.licensePlate}',
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppConstants.textColor,
                  ),
                ),
              ],
            ),
          ),
          // Contact buttons
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.call, color: AppConstants.primaryColor),
                onPressed: () {
                  // TODO: Implement call functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.message, color: AppConstants.primaryColor),
                onPressed: () {
                  // TODO: Implement message functionality
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required String title,
    required String address,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: AppConstants.fontSizeXLarge,
        fontWeight: FontWeight.bold,
        color: AppConstants.textColor,
      ),
    );
  }

  Widget _buildInfoGrid(List<_InfoItem> items) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppConstants.paddingMedium,
      mainAxisSpacing: AppConstants.paddingMedium,
      children: items
          .map((item) => Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildPriceItem(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal
                  ? AppConstants.fontSizeLarge
                  : AppConstants.fontSizeMedium,
              fontWeight:
                  isTotal ? FontWeight.bold : FontWeight.normal,
              color: AppConstants.textColor,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal
                  ? AppConstants.fontSizeLarge
                  : AppConstants.fontSizeMedium,
              fontWeight:
                  isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? AppConstants.primaryColor : AppConstants.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateCard(double latitude, double longitude) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Current Location Coordinates',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latitude',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSmall,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    latitude.toStringAsFixed(6),
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Longitude',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSmall,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    longitude.toStringAsFixed(6),
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatAvailabilityCard(int totalSeats, int bookedSeats) {
    // DEBUG: Log values received
    print('DEBUG: Seat Availability - totalSeats: $totalSeats, bookedSeats: $bookedSeats');
    
    // Handle edge case: totalSeats should be at least 1 to avoid division by zero
    final safeTotal = totalSeats > 0 ? totalSeats : 1;
    final safeBooked = bookedSeats < safeTotal ? bookedSeats : safeTotal;
    final availableSeats = safeTotal - safeBooked;
    
    // Calculate occupancy percentage safely
    final occupancyPercentage = (safeBooked / safeTotal) * 100;
    
    // Safe progress value (clamped between 0 and 1)
    final progressValue = (safeBooked / safeTotal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: availableSeats > 0
            ? Colors.green.shade50
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: availableSeats > 0
              ? Colors.green.shade200
              : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_seat,
                color: availableSeats > 0 ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                'Seat Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textColor,
                  fontSize: AppConstants.fontSizeXLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Seat count display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Seats',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSmall,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    safeTotal.toString(),
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booked',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSmall,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    safeBooked.toString(),
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSmall,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    availableSeats.toString(),
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: availableSeats > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                occupancyPercentage > 75
                    ? Colors.red
                    : occupancyPercentage > 50
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${occupancyPercentage.toStringAsFixed(1)}% Occupied',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppConstants.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'accepted':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.directions_car;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showBookSeatDialog(
    BuildContext context,
    String rideId,
    double pricePerSeat,
    int availableSeats,
  ) {
    int seatsToBook = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Book Seat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How many seats do you want to book? (${availableSeats} available)'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (seatsToBook > 1) {
                        setState(() {
                          seatsToBook--;
                        });
                      }
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppConstants.primaryColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      seatsToBook.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (seatsToBook < availableSeats) {
                        setState(() {
                          seatsToBook++;
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.lightGrayColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Price:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${(seatsToBook * pricePerSeat).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _bookSeat(
                  context,
                  rideId,
                  seatsToBook,
                  pricePerSeat,
                );
              },
              child: const Text('Book Seat'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bookSeat(
    BuildContext context,
    String rideId,
    int seatsToBook,
    double pricePerSeat,
  ) async {
    final authController = context.read<AuthController>();
    final bookingController = context.read<BookingController>();
    final currentUser = authController.currentUser;

    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
      }
      return;
    }

    final result = await bookingController.createBooking(
      currentUser.uid,
      rideId,
      _rideController.selectedRide?.driverId ?? '',
      seatsToBook,
      pricePerSeat,
      _rideController.selectedRide?.startAddress,
      _rideController.selectedRide?.destinationAddress,
    );

    if (mounted) {
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seat booked successfully! Waiting for driver approval.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book seat: ${bookingController.errorMessage}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _showCancelDialog(BuildContext context, String rideId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: const Text('Are you sure you want to cancel this ride?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              _rideController.updateRideStatus(rideId, 'cancelled');
              Navigator.pop(context);
            },
            child: const Text('Cancel Ride'),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  _InfoItem(this.label, this.value);
}
