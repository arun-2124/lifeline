import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/utils/validators.dart';
import 'package:mobile_app/widgets/custom_button.dart';
import 'package:mobile_app/widgets/custom_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _photoUrlController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _photoUrlController = TextEditingController(text: user?.photoUrl ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).updateProfile(
            fullName: _fullNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            photoUrl: _photoUrlController.text.trim().isNotEmpty
                ? _photoUrlController.text.trim()
                : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next.infoMessage != null && previous?.status == AuthStatus.loading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.infoMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        backgroundImage: _photoUrlController.text.isNotEmpty
                            ? NetworkImage(_photoUrlController.text)
                            : null,
                        child: _photoUrlController.text.isEmpty
                            ? const Icon(Icons.person, size: 48, color: AppColors.primary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _fullNameController,
                  validator: Validators.validateFullName,
                  prefixIcon: Icons.person_outline,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  label: 'Phone Number',
                  hint: '+91 9876543210',
                  controller: _phoneController,
                  validator: Validators.validatePhoneNumber,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  label: 'Profile Photo URL (Placeholder for Firebase Storage)',
                  hint: 'https://example.com/avatar.jpg',
                  controller: _photoUrlController,
                  prefixIcon: Icons.image_outlined,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Save Changes',
                  isLoading: isLoading,
                  onPressed: _saveProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
