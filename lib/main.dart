import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'constants/app_constants.dart';
import 'controllers/auth_controller.dart';
import 'controllers/ride_controller.dart';
import 'controllers/booking_controller.dart';
import 'views/auth/login_page.dart';
import 'views/auth/signup_page.dart';
import 'views/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final controller = AuthController();
            // Call checkCurrentUser ONCE after first frame (not in FutureBuilder!)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.checkCurrentUser();
            });
            return controller;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => RideController(),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingController(),
        ),
      ],
      child: MaterialApp(
        title: 'CapeStart User',
        theme: AppTheme.lightTheme(),
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthController>(
          builder: (context, authController, _) {
            // Simple check: if loading, show splash screen
            if (authController.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppConstants.primaryColor,
                    ),
                  ),
                ),
              );
            }

            // Otherwise, route to home or login based on login state
            return authController.isLoggedIn
                ? const HomePage()
                : const LoginPage();
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}
