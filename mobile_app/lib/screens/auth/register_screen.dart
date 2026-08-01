import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/utils/validators.dart';
import 'package:mobile_app/widgets/custom_button.dart';
import 'package:mobile_app/widgets/custom_text_field.dart';
import 'package:mobile_app/widgets/glass_card.dart';
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

  // 7 MANDATORY CHECKBOXES
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  bool _agreeFacilitation = false;
  bool _agreeFoodSafety = false;
  bool _agreeNoUnsafeFood = false;
  bool _agreeViolationSuspension = false;
  bool _certifyAccurateInfo = false;

  bool get _areAllAgreementsAccepted =>
      _agreeTerms &&
      _agreePrivacy &&
      _agreeFacilitation &&
      _agreeFoodSafety &&
      _agreeNoUnsafeFood &&
      _agreeViolationSuspension &&
      _certifyAccurateInfo;

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
    if (!_areAllAgreementsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept all mandatory Terms & Food Safety agreements before registering.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

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
            content: Text(next.infoMessage ?? 'Verification email sent! Please verify to log in.'),
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
        title: const Text('Create Verified Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join Lifeline Ecosystem',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter details and review mandatory food safety guarantees.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // USER PROFILE FORM
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Full Name',
                        hint: 'Rahul Kumar',
                        controller: _fullNameController,
                        validator: Validators.validateFullName,
                        prefixIcon: Icons.person_outline,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Email Address',
                        hint: 'rahul@example.com',
                        controller: _emailController,
                        validator: Validators.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Phone Number (10 Digits)',
                        hint: '9876543210',
                        controller: _phoneController,
                        validator: Validators.validatePhoneNumber,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Password',
                        hint: '••••••••',
                        controller: _passwordController,
                        validator: Validators.validatePassword,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 14),
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
                        enabled: !isLoading,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ROLE SELECTOR
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

                const SizedBox(height: 24),

                // 7 MANDATORY TERMS & FOOD SAFETY CHECKBOXES
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _areAllAgreementsAccepted
                          ? AppColors.success.withValues(alpha: 0.5)
                          : AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.gavel_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Mandatory Terms & Food Safety Declaration',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _CheckboxTile(
                        value: _agreeTerms,
                        title: 'I agree to the Lifeline Terms & Conditions.',
                        onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                      ),
                      _CheckboxTile(
                        value: _agreePrivacy,
                        title: 'I agree to the Privacy Policy.',
                        onChanged: (v) => setState(() => _agreePrivacy = v ?? false),
                      ),
                      _CheckboxTile(
                        value: _agreeFacilitation,
                        title: 'I understand that Lifeline only facilitates food redistribution.',
                        onChanged: (v) => setState(() => _agreeFacilitation = v ?? false),
                      ),
                      _CheckboxTile(
                        value: _agreeFoodSafety,
                        title: 'I understand that I am responsible for ensuring the food I donate is safe and suitable for human consumption.',
                        onChanged: (v) => setState(() => _agreeFoodSafety = v ?? false),
                      ),
                      _CheckboxTile(
                        value: _agreeNoUnsafeFood,
                        title: 'I agree that expired, spoiled, contaminated, or unsafe food must never be donated.',
                        onChanged: (v) => setState(() => _agreeNoUnsafeFood = v ?? false),
                      ),
                      _CheckboxTile(
                        value: _agreeViolationSuspension,
                        title: 'I understand that repeated violations may lead to account suspension.',
                        onChanged: (v) => setState(() => _agreeViolationSuspension = v ?? false),
                      ),
                      _CheckboxTile(
                        value: _certifyAccurateInfo,
                        title: 'I certify that all information provided is accurate.',
                        onChanged: (v) => setState(() => _certifyAccurateInfo = v ?? false),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                CustomButton(
                  text: 'Register Account',
                  isLoading: isLoading,
                  onPressed: _areAllAgreementsAccepted ? _submitRegister : null,
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckboxTile extends StatelessWidget {
  final bool value;
  final String title;
  final ValueChanged<bool?> onChanged;

  const _CheckboxTile({
    required this.value,
    required this.title,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: AppColors.primary,
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
