import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late FocusNode _phoneFocus;
  late FocusNode _passwordFocus;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context, AuthController authController) async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final success = await authController.login(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
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
                    const SizedBox(height: AppConstants.paddingLarge * 2),
                    
                    // Header
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Login to your account',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge * 3),

                    // Logo/Icon placeholder
                    Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          size: 40,
                          color: AppConstants.darkColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge * 2),

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
                      hint: 'Enter your password',
                      obscurePassword: authController.obscurePassword,
                      onToggleVisibility: () {
                        authController.togglePasswordVisibility();
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Forgot password feature coming soon'),
                            ),
                          );
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: AppConstants.buttonHeight,
                      child: ElevatedButton(
                        onPressed: authController.isLoading
                            ? null
                            : () => _handleLogin(context, authController),
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
                            : const Text('Login'),
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingLarge),

                    // Signup link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextButton(
                          onPressed: () {
                            authController.clearErrorMessage();
                            Navigator.of(context).pushReplacementNamed('/signup');
                          },
                          child: const Text('Sign Up'),
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
