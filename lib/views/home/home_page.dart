import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/ride_controller.dart';
import '../../controllers/booking_controller.dart';
import 'pages/ride_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    const HomeScreen(),
    const MyRidesScreen(),
    const ProfileScreen(),
  ];

  static const List<String> _titles = [
    'Home',
    'My Rides',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = context.read<AuthController>();
      if (authController.currentUser == null) {
        authController.checkCurrentUser();
      }
    });
  }

  void _onTabTapped(int index) {
    if (_selectedIndex == index) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _refreshCurrentScreen() {
    if (_selectedIndex == 0) {
      // Refresh home screen rides
      context.read<RideController>().fetchAllRides();
    } else if (_selectedIndex == 1) {
      // Refresh my rides bookings
      final authController = context.read<AuthController>();
      final currentUser = authController.currentUser;
      if (currentUser != null) {
        context.read<BookingController>().fetchUserBookings(currentUser.uid);
      }
    }
  }

  void _handleLogout(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authController.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppConstants.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        elevation: 0,
        actions: [
          if (_selectedIndex == 0 || _selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshCurrentScreen,
            ),
          if (_selectedIndex == 2)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                final authController = context.read<AuthController>();
                _handleLogout(context, authController);
              },
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'My Rides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    // Fetch all rides when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideController>().fetchAllRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RideController>(
      builder: (context, rideController, _) {
        if (rideController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppConstants.primaryColor,
              ),
            ),
          );
        }

        if (rideController.errorMessage.isNotEmpty) {
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
                  'Error: ${rideController.errorMessage}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    rideController.fetchAllRides();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final rides = rideController.rides;
        final filteredRides = rides.where((ride) {
          if (selectedStatus == 'All') {
            return true;
          }

          final rideStatus = _normalizeRideStatus(ride.status);
          return rideStatus == selectedStatus.toLowerCase();
        }).toList();

        if (rides.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_car,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No rides available',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await rideController.fetchAllRides();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: filteredRides.length + 1,
            itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                margin:
                    const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: AppConstants.lightGrayColor,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Rides',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'All', child: Text('All')),
                        PopupMenuItem(
                          value: 'Cancelled',
                          child: Text('Cancelled'),
                        ),
                        PopupMenuItem(value: 'Started', child: Text('Started')),
                        PopupMenuItem(
                          value: 'Completed',
                          child: Text('Completed'),
                        ),
                      ],
                      icon: const Icon(Icons.filter_list),
                    ),
                  ],
                ),
              );
            }

            final ride = filteredRides[index - 1];
            final normalizedStatus = _normalizeRideStatus(ride.status);
            final statusColor = _getStatusColor(normalizedStatus);
            final statusIcon = _getStatusIcon(normalizedStatus);

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingSmall,
              ),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RideDetailPage(
                        rideId: ride.rideId,
                      ),
                    ),
                  );
                },
                leading: Icon(
                  Icons.directions_car,
                  color: AppConstants.primaryColor,
                ),
                title: Text(
                  '${ride.startAddress} → ${ride.destinationAddress}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          normalizedStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeSmall,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (ride.distance != null)
                          Text(
                            ride.distance!,
                            style: const TextStyle(
                              fontSize: AppConstants.fontSizeSmall,
                              color: AppConstants.textColor,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '₹${ride.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeSmall,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
          ),
        );
      },
    );
  }

  String _normalizeRideStatus(String? status) {
    final safeStatus = (status ?? '').toLowerCase();
    if (safeStatus == 'in_progress') {
      return 'started';
    }
    return safeStatus;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.blue;
      case 'started':
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
      case 'started':
        return Icons.directions_car;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({Key? key}) : super(key: key);

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  String? _loadedUserId;

  @override
  void initState() {
    super.initState();
    // Fetch user's bookings when screen loads.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookingsIfNeeded();
    });
  }

  void _loadBookingsIfNeeded() {
    final authController = context.read<AuthController>();
    final currentUser = authController.currentUser;

    if (currentUser == null || _loadedUserId == currentUser.uid) {
      return;
    }

    _loadedUserId = currentUser.uid;
    context.read<BookingController>().fetchUserBookings(currentUser.uid);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _loadBookingsIfNeeded();
    });

    return Consumer2<AuthController, BookingController>(
      builder: (context, authController, bookingController, _) {
        final currentUser = authController.currentUser;

        if (currentUser == null) {
          return const Center(
            child: Text('Please log in to view your bookings'),
          );
        }

        if (bookingController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppConstants.primaryColor,
              ),
            ),
          );
        }

        if (bookingController.errorMessage.isNotEmpty) {
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
                  'Error: ${bookingController.errorMessage}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    bookingController.fetchUserBookings(currentUser.uid);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final bookings = bookingController.bookings;

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No booked rides yet',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await bookingController.fetchUserBookings(currentUser.uid);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: bookings.length + 1,
            itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                margin:
                    const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: AppConstants.lightGrayColor,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
                child: const Text(
                  'My Booked Rides',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            final booking = bookings[index - 1];
            final statusColor = _getBookingStatusColor(booking.status);
            final statusIcon = _getBookingStatusIcon(booking.status);

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingSmall,
              ),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RideDetailPage(
                        rideId: booking.rideId,
                      ),
                    ),
                  );
                },
                leading: Icon(
                  Icons.bookmark,
                  color: AppConstants.primaryColor,
                ),
                title: Text(
                  booking.pickupLocation ?? 'Pickup',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          booking.status.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeSmall,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (booking.isApproved)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: AppConstants.paddingSmall),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Approved',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.event_seat,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${booking.seatsBooked} seat(s)',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeSmall,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.currency_rupee,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '₹${booking.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
          ),
        );
      },
    );
  }

  Color _getBookingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getBookingStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final user = authController.currentUser;

        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                size: 40,
                color: AppConstants.darkColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Center(
              child: Text(
                user.username,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeXLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            _ProfileInfoTile(
              icon: Icons.phone,
              label: 'Phone',
              value: user.phone,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            _ProfileInfoTile(
              icon: Icons.email,
              label: 'Email',
              value: user.email,
            ),
          ],
        );
      },
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.lightGrayColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
