import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/utils/validators.dart';
import 'package:mobile_app/widgets/custom_button.dart';
import 'package:mobile_app/widgets/custom_text_field.dart';

class EditDonationScreen extends ConsumerStatefulWidget {
  const EditDonationScreen({super.key});

  @override
  ConsumerState<EditDonationScreen> createState() => _EditDonationScreenState();
}

class _EditDonationScreenState extends ConsumerState<EditDonationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _foodNameController;
  late TextEditingController _quantityController;
  late TextEditingController _mealsController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();
    final donation = ref.read(donationNotifierProvider).selectedDonation;

    _foodNameController = TextEditingController(text: donation?.foodName ?? '');
    _quantityController =
        TextEditingController(text: donation?.quantity.toString() ?? '1');
    _mealsController =
        TextEditingController(text: donation?.numberOfMeals.toString() ?? '2');
    _addressController =
        TextEditingController(text: donation?.pickupAddress ?? '');
    _phoneController =
        TextEditingController(text: donation?.contactNumber ?? '');
    _instructionsController =
        TextEditingController(text: donation?.specialInstructions ?? '');
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _mealsController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _saveUpdates() async {
    if (_formKey.currentState?.validate() ?? false) {
      final current = ref.read(donationNotifierProvider).selectedDonation;
      if (current == null) return;

      final updatedDonation = current.copyWith(
        foodName: _foodNameController.text.trim(),
        quantity: double.tryParse(_quantityController.text.trim()) ?? current.quantity,
        numberOfMeals: int.tryParse(_mealsController.text.trim()) ?? current.numberOfMeals,
        pickupAddress: _addressController.text.trim(),
        contactNumber: _phoneController.text.trim(),
        specialInstructions: _instructionsController.text.trim(),
        updatedAt: DateTime.now(),
      );

      final success = await ref
          .read(donationNotifierProvider.notifier)
          .updateDonation(updatedDonation);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final donationState = ref.watch(donationNotifierProvider);
    final isLoading = donationState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Food Donation'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: 'Food Item Name',
                  hint: 'Food name',
                  controller: _foodNameController,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Food name is required' : null,
                  prefixIcon: Icons.fastfood_outlined,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Quantity',
                        hint: '1',
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.scale_outlined,
                        enabled: !isLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Meals Count',
                        hint: '2',
                        controller: _mealsController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.restaurant_outlined,
                        enabled: !isLoading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Pickup Address',
                  hint: 'Address',
                  controller: _addressController,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Pickup address is required' : null,
                  prefixIcon: Icons.location_on_outlined,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Contact Number',
                  hint: '+91 9876543210',
                  controller: _phoneController,
                  validator: Validators.validatePhoneNumber,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Special Instructions',
                  hint: 'Instructions',
                  controller: _instructionsController,
                  prefixIcon: Icons.note_alt_outlined,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'Save Changes',
                  isLoading: isLoading,
                  onPressed: _saveUpdates,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
