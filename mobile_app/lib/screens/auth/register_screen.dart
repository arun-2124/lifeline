import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/user_consent_model.dart';
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

  // AGREEMENT CHECKBOXES
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  bool _agreeCommunity = false;
  bool _agreeFoodSafety = false;

  bool get _requiresFoodSafety {
    final r = _selectedRole.trim().toLowerCase();
    return r == 'donor' || r == 'community home cook' || r == 'home cook';
  }

  bool get _requiresCommunity {
    final r = _selectedRole.trim().toLowerCase();
    return r != 'beneficiary' && r != 'admin';
  }

  bool get _areRoleAgreementsAccepted {
    if (!_agreeTerms || !_agreePrivacy) return false;
    if (_requiresCommunity && !_agreeCommunity) return false;
    if (_requiresFoodSafety && !_agreeFoodSafety) return false;
    return true;
  }

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
    if (!_areRoleAgreementsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept all mandatory legal & safety agreements for your role.'),
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
        title: const Text('Create Account'),
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
                  'Fill in your details and accept role-based legal agreements.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // USER PROFILE INPUTS
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

                // ROLE-BASED LEGAL AGREEMENTS (PHASE 2)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _areRoleAgreementsAccepted
                          ? AppColors.success.withValues(alpha: 0.5)
                          : AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.gavel_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Legal Compliance for $_selectedRole',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Terms & Conditions v1.0
                      _LegalCheckboxTile(
                        value: _agreeTerms,
                        title: 'I agree to the Lifeline Terms & Conditions v${UserConsentModel.currentTermsVersion}.',
                        linkText: 'View Terms',
                        onLinkTap: () {
                          Navigator.of(context).pushNamed(AppRouter.termsConditionsRoute);
                        },
                        onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                      ),

                      // Privacy Policy v1.0
                      _LegalCheckboxTile(
                        value: _agreePrivacy,
                        title: 'I agree to the Lifeline Privacy Policy v${UserConsentModel.currentPrivacyVersion}.',
                        linkText: 'View Privacy Policy',
                        onLinkTap: () {
                          Navigator.of(context).pushNamed(AppRouter.privacyPolicyRoute);
                        },
                        onChanged: (v) => setState(() => _agreePrivacy = v ?? false),
                      ),

                      // Community Guidelines (NGO, Volunteer, Delivery, Donor, Home Cook)
                      if (_requiresCommunity)
                        _LegalCheckboxTile(
                          value: _agreeCommunity,
                          title: 'I agree to uphold Lifeline Community Standards.',
                          onChanged: (v) => setState(() => _agreeCommunity = v ?? false),
                        ),

                      // Mandatory Food Safety Agreement (Donor & Home Cook)
                      if (_requiresFoodSafety) ...[
                        const Divider(height: 20),
                        const Row(
                          children: [
                            Icon(Icons.restaurant_rounded, color: Colors.deepOrange, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Mandatory Food Safety Declaration',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _LegalCheckboxTile(
                          value: _agreeFoodSafety,
                          title: 'I certify that all food I share is freshly prepared, hygienically handled, and completely safe for human consumption. I accept full responsibility for food safety.',
                          onChanged: (v) => setState(() => _agreeFoodSafety = v ?? false),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                CustomButton(
                  text: 'Register Account',
                  isLoading: isLoading,
                  onPressed: _areRoleAgreementsAccepted ? _submitRegister : null,
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

class _LegalCheckboxTile extends StatelessWidget {
  final bool value;
  final String title;
  final String? linkText;
  final VoidCallback? onLinkTap;
  final ValueChanged<bool?> onChanged;

  const _LegalCheckboxTile({
    required this.value,
    required this.title,
    this.linkText,
    this.onLinkTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          activeColor: AppColors.primary,
          title: Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
          ),
          value: value,
          onChanged: onChanged,
        ),
        if (linkText != null && onLinkTap != null)
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: GestureDetector(
              onTap: onLinkTap,
              child: Text(
                linkText!,
                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
              ),
            ),
          ),
      ],
    );
  }
}
