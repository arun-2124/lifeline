import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/utils/validators.dart';
import 'package:mobile_app/widgets/custom_button.dart';
import 'package:mobile_app/widgets/custom_text_field.dart';
import 'package:mobile_app/widgets/role_selector_widget.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'Donor';

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).registerUser(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phoneNumber: _phoneController.text.trim(),
            role: _selectedRole,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next.status == AuthStatus.emailVerificationPending) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.infoMessage ?? 'Verification email sent!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pushReplacementNamed(
          AppRouter.emailVerificationRoute,
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join Lifeline Today',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Fill in your details to create a verified profile.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Full Name',
                  hint: 'John Doe',
                  controller: _fullNameController,
                  validator: Validators.validateFullName,
                  prefixIcon: Icons.person_outline,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email Address',
                  hint: 'john@example.com',
                  controller: _emailController,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Phone Number',
                  hint: '+91 9876543210',
                  controller: _phoneController,
                  validator: Validators.validatePhoneNumber,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  validator: Validators.validatePassword,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Confirm Password',
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  validator: (val) => Validators.validateConfirmPassword(
                    val,
                    _passwordController.text,
                  ),
                  isPassword: true,
                  prefixIcon: Icons.lock_reset_outlined,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 24),
                RoleSelectorWidget(
                  selectedRole: _selectedRole,
                  onRoleSelected: (role) {
                    if (!isLoading) {
                      setState(() {
                        _selectedRole = role;
                      });
                    }
                  },
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'Register Account',
                  isLoading: isLoading,
                  onPressed: _submitRegister,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: isLoading
                          ? null
                          : () {
                              Navigator.of(context).pushReplacementNamed(AppRouter.loginRoute);
                            },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
