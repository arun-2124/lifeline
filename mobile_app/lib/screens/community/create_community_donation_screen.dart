import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/community_donation_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/custom_button.dart';
import 'package:mobile_app/widgets/custom_text_field.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class CreateCommunityDonationScreen extends ConsumerStatefulWidget {
  const CreateCommunityDonationScreen({super.key});

  @override
  ConsumerState<CreateCommunityDonationScreen> createState() => _CreateCommunityDonationScreenState();
}

class _CreateCommunityDonationScreenState extends ConsumerState<CreateCommunityDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _quantityController = TextEditingController(text: '10');
  final _ingredientsController = TextEditingController();
  final _allergenController = TextEditingController(text: 'None');
  final _storageController = TextEditingController(text: 'Insulated Hot Casserole');
  final _pickupAddressController = TextEditingController();
  final _pickupWindowController = TextEditingController(text: 'Today 5:00 PM - 8:00 PM');
  final _notesController = TextEditingController();

  bool _isVeg = true;
  bool _foodSafetyAccepted = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pickupAddressController.text = 'Sector 3, Bangalore Relief Zone';
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _ingredientsController.dispose();
    _allergenController.dispose();
    _storageController.dispose();
    _pickupAddressController.dispose();
    _pickupWindowController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitDonation() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_foodSafetyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept the Food Safety Declaration to share home food.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    final now = DateTime.now();
    final donation = CommunityDonationModel(
      donationId: '',
      donorUid: user.uid,
      donorName: user.fullName,
      donorType: 'Family / Home Cook',
      donorTrustScore: 4.9,
      foodName: _foodNameController.text.trim(),
      category: 'Home Cooked Meal',
      isVeg: _isVeg,
      quantityPeopleServed: int.tryParse(_quantityController.text.trim()) ?? 10,
      preparedTime: now.subtract(const Duration(minutes: 30)),
      bestBeforeTime: now.add(const Duration(hours: 4)),
      ingredients: _ingredientsController.text.trim(),
      allergenInfo: _allergenController.text.trim(),
      storageMethod: _storageController.text.trim(),
      pickupAddress: _pickupAddressController.text.trim(),
      pickupWindow: _pickupWindowController.text.trim(),
      notes: _notesController.text.trim(),
      foodSafetyAcceptedAt: now,
      createdAt: now,
    );

    final success = await ref.read(communitySharingNotifierProvider.notifier).createDonation(donation);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Home-cooked surplus meal published to Community Feed!'),
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
          'Share Home-Cooked Food',
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
                    CustomTextField(
                      label: 'Food Name / Meal Title',
                      hint: 'e.g., Vegetable Biryani & Dal',
                      controller: _foodNameController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter food name' : null,
                      prefixIcon: Icons.soup_kitchen_rounded,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Portions (People Served)',
                            hint: '10',
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.groups_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Dietary Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text('Veg'),
                                    selected: _isVeg,
                                    onSelected: (s) => setState(() => _isVeg = true),
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    label: const Text('Non-Veg'),
                                    selected: !_isVeg,
                                    onSelected: (s) => setState(() => _isVeg = false),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Key Ingredients Used',
                      hint: 'e.g., Rice, Paneer, Spices, Ghee',
                      controller: _ingredientsController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter ingredients' : null,
                      prefixIcon: Icons.rice_bowl_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Allergen Information',
                      hint: 'e.g., Contains Dairy / Nuts / Gluten',
                      controller: _allergenController,
                      prefixIcon: Icons.warning_amber_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Storage Method',
                      hint: 'e.g., Insulated Hot Casserole Container',
                      controller: _storageController,
                      prefixIcon: Icons.kitchen_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Pickup Address',
                      hint: 'Flat 402, Block B, Apartments...',
                      controller: _pickupAddressController,
                      prefixIcon: Icons.location_on_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Pickup Time Window',
                      hint: 'Today 5:00 PM - 8:00 PM',
                      controller: _pickupWindowController,
                      prefixIcon: Icons.access_time_rounded,
                    ),
                    const SizedBox(height: 20),

                    // MANDATORY FOOD SAFETY DECLARATION MODULE
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Food Safety Declaration',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Food was freshly prepared in a clean, hygienic environment.\n'
                            '• Food has been safely stored at proper temperature.\n'
                            '• I understand that unsafe food must never be shared.',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'I confirm & accept the Food Safety Guarantee',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            value: _foodSafetyAccepted,
                            onChanged: (v) => setState(() => _foodSafetyAccepted = v ?? false),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Publish Community Donation',
                      isLoading: _isSubmitting,
                      onPressed: _submitDonation,
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
