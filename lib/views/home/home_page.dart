import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../controllers/auth_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = const [
    HomeScreen(),
    MyRidesScreen(),
    ProfileScreen(),
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vehicles = [
      'Bike - 2 min away',
      'Auto - 4 min away',
      'Cab - 6 min away'
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: vehicles.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppConstants.lightGrayColor,
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            child: const Text(
              'Nearby Vehicles',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        return Card(
          color: Colors.white,
          child: ListTile(
            leading: const Icon(
              Icons.directions_car,
              color: AppConstants.primaryColor,
            ),
            title: Text(vehicles[index - 1]),
            subtitle: const Text('Tap to select ride option'),
          ),
        );
      },
    );
  }
}

class MyRidesScreen extends StatelessWidget {
  const MyRidesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rides = [
      'Office Drop - Today, 9:30 AM',
      'Airport Ride - Yesterday, 7:10 PM'
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: rides.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
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

        return Card(
          color: Colors.white,
          child: ListTile(
            leading: const Icon(
              Icons.history,
              color: AppConstants.primaryColor,
            ),
            title: Text(rides[index - 1]),
            subtitle: const Text('Ride completed'),
          ),
        );
      },
    );
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
