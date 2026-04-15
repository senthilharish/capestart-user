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
  @override
  void initState() {
    super.initState();
    // Ensure user data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = context.read<AuthController>();
      if (authController.currentUser == null) {
        authController.checkCurrentUser();
      }
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
        title: const Text('Home'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              final authController = context.read<AuthController>();
              _handleLogout(context, authController);
            },
          ),
        ],
      ),
      body: Consumer<AuthController>(
        builder: (context, authController, _) {
          final user = authController.currentUser;

          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  _buildWelcomeSection(user.username),
                  const SizedBox(height: AppConstants.paddingLarge * 2),

                  // User info card
                  _buildUserInfoCard(user),
                  const SizedBox(height: AppConstants.paddingLarge * 2),

                  // User details section
                  _buildSectionTitle('Account Information'),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildInfoTile(
                    icon: Icons.person,
                    label: 'Username',
                    value: user.username,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildInfoTile(
                    icon: Icons.phone,
                    label: 'Phone Number',
                    value: user.phone,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildInfoTile(
                    icon: Icons.email,
                    label: 'Email',
                    value: user.email,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge * 2),

                  // Location section
                  _buildSectionTitle('Location'),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildLocationTile(user.location),
                  const SizedBox(height: AppConstants.paddingLarge * 2),

                  // Account created section
                  _buildSectionTitle('Account Details'),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildInfoTile(
                    icon: Icons.calendar_today,
                    label: 'Created On',
                    value: _formatDate(user.createdAt),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(String username) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back! 👋',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8.0),
        Text(
          '$username, great to see you again',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(dynamic user) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryColor, Color(0xFFFFED4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Row(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: AppConstants.darkColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            child: const Icon(
              Icons.account_circle,
              size: 40,
              color: AppConstants.darkColor,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeXLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.darkColor,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  user.phone,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppConstants.darkColor.withOpacity(0.7),
                  ),
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

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.lightGrayColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: Icon(
              icon,
              color: AppConstants.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: Color(0xFF999999),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile(Map<String, dynamic>? location) {
    final address = location?['address'] ?? 'Location not available';
    final latitude = location?['latitude'] ?? 0.0;
    final longitude = location?['longitude'] ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppConstants.lightGrayColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppConstants.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Location',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      address,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          if (latitude != 0.0 && longitude != 0.0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingSmall,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              ),
              child: Text(
                'Lat: ${latitude.toStringAsFixed(4)}, Lon: ${longitude.toStringAsFixed(4)}',
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: AppConstants.textColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
