import 'package:flutter/material.dart';

class AppConstants {
  // Colors - Rapido style with yellow and black
  static const Color primaryColor = Color(0xFFFFD700); // Bold Yellow
  static const Color darkColor = Color(0xFF1A1A1A); // Dark Black
  static const Color accentColor = Color(0xFFFF6B6B); // Accent Red
  static const Color lightGrayColor = Color(0xFFF5F5F5); // Light Gray
  static const Color textColor = Color(0xFF333333); // Dark Text
  static const Color errorColor = Color(0xFFE74C3C); // Error Red
  static const Color successColor = Color(0xFF27AE60); // Success Green

  // Padding and margins
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;

  // Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeHeading = 28.0;

  // Button sizes
  static const double buttonHeight = 56.0;
  static const double buttonBorderRadius = 16.0;
}

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppConstants.textColor),
        titleTextStyle: TextStyle(
          color: AppConstants.textColor,
          fontSize: AppConstants.fontSizeXLarge,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: AppConstants.textColor,
          fontSize: AppConstants.fontSizeLarge,
        ),
        bodyMedium: TextStyle(
          color: AppConstants.textColor,
          fontSize: AppConstants.fontSizeMedium,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF666666),
          fontSize: AppConstants.fontSizeSmall,
        ),
        headlineLarge: TextStyle(
          color: AppConstants.textColor,
          fontSize: AppConstants.fontSizeHeading,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppConstants.textColor,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.lightGrayColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          borderSide: const BorderSide(
            color: AppConstants.primaryColor,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          borderSide: const BorderSide(
            color: AppConstants.errorColor,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          borderSide: const BorderSide(
            color: AppConstants.errorColor,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingMedium,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF999999),
          fontSize: AppConstants.fontSizeMedium,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: AppConstants.darkColor,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: AppConstants.fontSizeXLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          textStyle: const TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
