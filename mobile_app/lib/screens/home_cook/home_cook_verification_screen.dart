import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/home_cook_profile_model.dart';
import 'package:mobile_app/models/verification_request_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/custom_button.dart';
import 'package:mobile_app/widgets/custom_text_field.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class HomeCookVerificationScreen extends ConsumerStatefulWidget {
  const HomeCookVerificationScreen({super.key});

  @override
  ConsumerState<HomeCookVerificationScreen> createState() => _HomeCookVerificationScreenState();
}

class _HomeCookVerificationScreenState extends ConsumerState<HomeCookVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idProofController = TextEditingController(text: 'Aadhaar / Govt ID Verified');
  final _kitchenPhotoController = TextEditingController(text: 'Clean Kitchen Photo Attached');
  final _hygieneDeclarationController = TextEditingController(text: 'FSSAI food safety principles accepted.');

  VerificationLevel _selectedLevel = VerificationLevel.level3TrustedHomeCook;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _idProofController.dispose();
    _kitchenPhotoController.dispose();
    _hygieneDeclarationController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    final req = VerificationRequestModel(
      requestId: '',
      uid: user.uid,
      cookName: user.fullName,
      targetLevel: _selectedLevel,
      idProofUrl: _idProofController.text.trim(),
      kitchenPhotoUrl: _kitchenPhotoController.text.trim(),
      hygieneSelfDeclaration: _hygieneDeclarationController.text.trim(),
      requestedAt: DateTime.now(),
    );

    final success = await ref.read(homeCookNotifierProvider.notifier).submitVerificationRequest(req);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification application submitted! Admin review in progress.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Home Cook Verification Upgrade',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Target Verification Level', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<VerificationLevel>(
                      initialValue: _selectedLevel,
                      items: VerificationLevel.values.map((lvl) {
                        return DropdownMenuItem(
                          value: lvl,
                          child: Text(HomeCookProfileModel.formatLevelName(lvl)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedLevel = v);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Identity Proof Reference',
                      hint: 'Aadhaar / Passport Number',
                      controller: _idProofController,
                      prefixIcon: Icons.badge_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Kitchen Hygiene Photo Reference',
                      hint: 'Clean stainless steel kitchen photo',
                      controller: _kitchenPhotoController,
                      prefixIcon: Icons.kitchen_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Hygiene & Safety Self-Declaration',
                      hint: 'I follow FSSAI clean cooking guidelines...',
                      controller: _hygieneDeclarationController,
                      prefixIcon: Icons.verified_user_rounded,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Submit Verification Application',
                      isLoading: _isSubmitting,
                      onPressed: _submitRequest,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
