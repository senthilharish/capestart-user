import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../controllers/auth_controller.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late FocusNode _usernameFocus;
  late FocusNode _phoneFocus;
  late FocusNode _passwordFocus;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _usernameFocus = FocusNode();
    _phoneFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleSignup(BuildContext context, AuthController authController) async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final success = await authController.signup(
      username: _usernameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup successful!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Consumer<AuthController>(
              builder: (context, authController, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppConstants.paddingLarge),
                    // Header
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Join us and start your journey',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge * 2),

                    // Username field
                    _buildTextField(
                      controller: _usernameController,
                      focusNode: _usernameFocus,
                      label: 'Username',
                      hint: 'Enter your username',
                      icon: Icons.person_outline,
                      onSubmit: (_) => _phoneFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Phone field
                    _buildTextField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      label: 'Phone Number',
                      hint: 'Enter 10-digit phone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      onSubmit: (_) => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Password field
                    _buildPasswordField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      label: 'Password',
                      hint: 'Enter password (min 6 chars)',
                      obscurePassword: authController.obscurePassword,
                      onToggleVisibility: () {
                        authController.togglePasswordVisibility();
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingLarge * 1.5),

                    // Signup button
                    SizedBox(
                      width: double.infinity,
                      height: AppConstants.buttonHeight,
                      child: ElevatedButton(
                        onPressed: authController.isLoading
                            ? null
                            : () => _handleSignup(context, authController),
                        child: authController.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppConstants.darkColor,
                                  ),
                                ),
                              )
                            : const Text('Sign Up'),
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingLarge),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextButton(
                          onPressed: () {
                            authController.clearErrorMessage();
                            Navigator.of(context).pushReplacementNamed('/login');
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onSubmit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w600,
            color: AppConstants.textColor,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          onSubmitted: onSubmit,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: Icon(
                icon,
                color: AppConstants.textColor,
                size: 20.0,
              ),
            ),
            hintText: hint,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required bool obscurePassword,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w600,
            color: AppConstants.textColor,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscurePassword,
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12.0, right: 12.0),
              child: Icon(
                Icons.lock_outline,
                color: AppConstants.textColor,
                size: 20.0,
              ),
            ),
            suffixIcon: GestureDetector(
              onTap: onToggleVisibility,
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppConstants.textColor,
                  size: 20.0,
                ),
              ),
            ),
            hintText: hint,
          ),
        ),
      ],
    );
  }
}
