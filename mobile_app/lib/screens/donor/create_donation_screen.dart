import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/donation_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/utils/validators.dart';
import 'package:mobile_app/widgets/custom_button.dart';
import 'package:mobile_app/widgets/custom_text_field.dart';

class CreateDonationScreen extends ConsumerStatefulWidget {
  const CreateDonationScreen({super.key});

  @override
  ConsumerState<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends ConsumerState<CreateDonationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _foodNameController = TextEditingController();
  final _quantityController = TextEditingController(text: '5');
  final _mealsController = TextEditingController(text: '10');
  final _addressController = TextEditingController();
  final _latController = TextEditingController(text: '12.9716');
  final _lngController = TextEditingController(text: '77.5946');
  final _phoneController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'cooked_meal';
  String _selectedFoodType = 'Veg';
  String _selectedUnit = 'kg';
  final DateTime _preparationTime = DateTime.now();
  final DateTime _expiryTime = DateTime.now().add(const Duration(hours: 4));

  final List<Map<String, String>> _categories = [
    {'value': 'cooked_meal', 'label': 'Cooked Meal'},
    {'value': 'produce', 'label': 'Fresh Produce'},
    {'value': 'bakery', 'label': 'Bakery Items'},
    {'value': 'dairy', 'label': 'Dairy Products'},
    {'value': 'packaged', 'label': 'Packaged Food'},
    {'value': 'beverages', 'label': 'Beverages'},
  ];

  final List<String> _units = ['kg', 'packets', 'plates', 'liters', 'boxes'];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      _phoneController.text = user.phoneNumber;
    }
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _mealsController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _phoneController.dispose();
    _instructionsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submitDonation() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = ref.read(authNotifierProvider).user;
      if (user == null) return;

      final donation = DonationModel(
        donationId: '',
        donorId: user.uid,
        donorName: user.fullName,
        foodName: _foodNameController.text.trim(),
        foodCategory: _selectedCategory,
        foodType: _selectedFoodType,
        quantity: double.tryParse(_quantityController.text.trim()) ?? 1.0,
        unit: _selectedUnit,
        numberOfMeals: int.tryParse(_mealsController.text.trim()) ?? 5,
        preparationTime: _preparationTime,
        expiryTime: _expiryTime,
        pickupAddress: _addressController.text.trim(),
        latitude: double.tryParse(_latController.text.trim()) ?? 12.9716,
        longitude: double.tryParse(_lngController.text.trim()) ?? 77.5946,
        contactNumber: _phoneController.text.trim(),
        specialInstructions: _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text.trim()
            : null,
        imageUrls: _imageUrlController.text.trim().isNotEmpty
            ? [_imageUrlController.text.trim()]
            : [],
        status: 'Pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await ref
          .read(donationNotifierProvider.notifier)
          .createDonation(donation);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation published successfully!'),
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
        title: const Text('Create Food Donation'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Food Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Food Item Name',
                  hint: 'e.g. Rice & Vegetable Curry (20 Meals)',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: _categories
                                .map((c) => DropdownMenuItem(
                                      value: c['value'],
                                      child: Text(c['label']!,
                                          style: const TextStyle(fontSize: 14)),
                                    ))
                                .toList(),
                            onChanged: isLoading
                                ? null
                                : (val) {
                                    if (val != null) setState(() => _selectedCategory = val);
                                  },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Food Type',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedFoodType,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: ['Veg', 'Non-Veg']
                                .map((t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t, style: const TextStyle(fontSize: 14)),
                                    ))
                                .toList(),
                            onChanged: isLoading
                                ? null
                                : (val) {
                                    if (val != null) setState(() => _selectedFoodType = val);
                                  },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Quantity',
                        hint: '5',
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.scale_outlined,
                        enabled: !isLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Unit',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: _units
                                .map((u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(u, style: const TextStyle(fontSize: 14)),
                                    ))
                                .toList(),
                            onChanged: isLoading
                                ? null
                                : (val) {
                                    if (val != null) setState(() => _selectedUnit = val);
                                  },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Estimated Meals / Servings',
                  hint: '10',
                  controller: _mealsController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.restaurant_outlined,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pickup & Location Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Pickup Address',
                  hint: '123 Rescue Street, Sector 5, Bangalore',
                  controller: _addressController,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Pickup address is required' : null,
                  prefixIcon: Icons.location_on_outlined,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Latitude (GPS)',
                        hint: '12.9716',
                        controller: _latController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.my_location,
                        enabled: !isLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Longitude (GPS)',
                        hint: '77.5946',
                        controller: _lngController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.explore_outlined,
                        enabled: !isLoading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Contact Phone Number',
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
                  hint: 'e.g. Ring bell at rear gate. Keep refrigerated.',
                  controller: _instructionsController,
                  prefixIcon: Icons.note_alt_outlined,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Food Image URL (Firebase Storage placeholder)',
                  hint: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
                  controller: _imageUrlController,
                  prefixIcon: Icons.camera_alt_outlined,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'Publish Donation',
                  isLoading: isLoading,
                  onPressed: _submitDonation,
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
