import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/donation_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/custom_button.dart';
import 'package:mobile_app/widgets/custom_text_field.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class CreateDonationScreen extends ConsumerStatefulWidget {
  const CreateDonationScreen({super.key});

  @override
  ConsumerState<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends ConsumerState<CreateDonationScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // STEP 1: FOOD INFO
  final _foodNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _peopleServedController = TextEditingController(text: '50');
  String _foodCategory = 'Cooked Meal';
  String _foodType = 'Veg';
  final String _cuisine = 'South Indian';
  final String _unit = 'plates';

  // STEP 2: PREPARATION & STORAGE
  String _storageMethod = 'Insulated Container';
  final String _temperature = '65°C Hot';
  int _expiryHours = 4;

  // STEP 3: PICKUP DETAILS
  final _pickupAddressController = TextEditingController(text: 'MG Road, Indiranagar, Bengaluru');
  final _landmarkController = TextEditingController(text: 'Near Metro Station');
  final _contactController = TextEditingController(text: '9876543210');
  final _notesController = TextEditingController();

  // STEP 4: MANDATORY FOOD SAFETY CHECKLIST
  bool _isFreshlyCooked = false;
  bool _isProperlyPacked = false;
  bool _isHygienicallyPrepared = false;
  bool _isProperlyStored = false;
  bool _isSafeForConsumption = false;

  bool get _isChecklistComplete =>
      _isFreshlyCooked &&
      _isProperlyPacked &&
      _isHygienicallyPrepared &&
      _isProperlyStored &&
      _isSafeForConsumption;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _peopleServedController.dispose();
    _pickupAddressController.dispose();
    _landmarkController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitDonation() async {
    if (!_isChecklistComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all 5 food safety checklist items before submitting.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    final now = DateTime.now();
    final donation = DonationModel(
      donationId: '',
      donorId: user.uid,
      donorName: user.fullName,
      donorType: user.role == 'Community Home Cook' ? 'Home Cook' : 'Commercial Donor',
      donorTrustScore: user.trustScore,
      donorVerificationLevel: user.verificationLevel,
      foodName: _foodNameController.text.trim(),
      foodCategory: _foodCategory,
      foodType: _foodType,
      cuisine: _cuisine,
      quantity: double.tryParse(_quantityController.text.trim()) ?? 25.0,
      unit: _unit,
      numberOfMeals: int.tryParse(_peopleServedController.text.trim()) ?? 50,
      peopleServed: int.tryParse(_peopleServedController.text.trim()) ?? 50,
      preparationTime: now.subtract(const Duration(minutes: 30)),
      expiryTime: now.add(Duration(hours: _expiryHours)),
      storageMethod: _storageMethod,
      temperature: _temperature,
      pickupAddress: _pickupAddressController.text.trim(),
      landmark: _landmarkController.text.trim(),
      latitude: 12.9716,
      longitude: 77.5946,
      contactNumber: _contactController.text.trim(),
      specialInstructions: _notesController.text.trim(),
      status: 'Available',
      isFreshlyCooked: _isFreshlyCooked,
      isProperlyPacked: _isProperlyPacked,
      isHygienicallyPrepared: _isHygienicallyPrepared,
      isProperlyStored: _isProperlyStored,
      isSafeForConsumption: _isSafeForConsumption,
      createdAt: now,
      updatedAt: now,
    );

    final success = await ref.read(donationNotifierProvider.notifier).createDonation(donation);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Surplus Food Donation created & published to nearby NGOs & Volunteers!'),
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
          'Create Surplus Food Donation',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() => _currentStep += 1);
            } else {
              _submitDonation();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: _currentStep == 3 ? 'Publish Donation' : 'Continue Step ${_currentStep + 2}',
                      isLoading: _isSubmitting,
                      onPressed: (_currentStep == 3 && !_isChecklistComplete) ? null : details.onStepContinue,
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // STEP 1: FOOD DETAILS
            Step(
              title: const Text('Food'),
              isActive: _currentStep >= 0,
              content: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Food Item Name',
                      hint: 'Vegetable Biryani & Dal',
                      controller: _foodNameController,
                      validator: (v) => v == null || v.isEmpty ? 'Enter food name' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _foodCategory,
                            decoration: const InputDecoration(labelText: 'Category'),
                            items: ['Cooked Meal', 'Produce', 'Bakery', 'Dairy', 'Packaged', 'Beverages'].map((c) {
                              return DropdownMenuItem(value: c, child: Text(c));
                            }).toList(),
                            onChanged: (v) => setState(() => _foodCategory = v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _foodType,
                            decoration: const InputDecoration(labelText: 'Dietary Type'),
                            items: ['Veg', 'Non-Veg', 'Vegan'].map((t) {
                              return DropdownMenuItem(value: t, child: Text(t));
                            }).toList(),
                            onChanged: (v) => setState(() => _foodType = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Quantity',
                            hint: '25',
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            label: 'People Served',
                            hint: '50',
                            controller: _peopleServedController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // STEP 2: PREPARATION & STORAGE
            Step(
              title: const Text('Storage'),
              isActive: _currentStep >= 1,
              content: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Storage Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _storageMethod,
                      items: ['Insulated Container', 'Refrigerated', 'Thermal Box', 'Ambient Packaging'].map((m) {
                        return DropdownMenuItem(value: m, child: Text(m));
                      }).toList(),
                      onChanged: (v) => setState(() => _storageMethod = v!),
                    ),
                    const SizedBox(height: 14),
                    const Text('Estimated Shelf Life (Hours)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Slider(
                      value: _expiryHours.toDouble(),
                      min: 1,
                      max: 12,
                      divisions: 11,
                      label: '$_expiryHours Hours',
                      onChanged: (val) => setState(() => _expiryHours = val.toInt()),
                    ),
                  ],
                ),
              ),
            ),

            // STEP 3: PICKUP DETAILS
            Step(
              title: const Text('Pickup'),
              isActive: _currentStep >= 2,
              content: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Pickup Address',
                      controller: _pickupAddressController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Landmark',
                      controller: _landmarkController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Contact Phone Number',
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),

            // STEP 4: MANDATORY SAFETY CHECKLIST
            Step(
              title: const Text('Safety'),
              isActive: _currentStep >= 3,
              content: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mandatory Food Quality Safety Checklist', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      dense: true,
                      activeColor: AppColors.primary,
                      title: const Text('Freshly Cooked & Prepared under 2 hours'),
                      value: _isFreshlyCooked,
                      onChanged: (v) => setState(() => _isFreshlyCooked = v ?? false),
                    ),
                    CheckboxListTile(
                      dense: true,
                      activeColor: AppColors.primary,
                      title: const Text('Properly Sealed & Sealed Packaging'),
                      value: _isProperlyPacked,
                      onChanged: (v) => setState(() => _isProperlyPacked = v ?? false),
                    ),
                    CheckboxListTile(
                      dense: true,
                      activeColor: AppColors.primary,
                      title: const Text('Hygienically Handled & FSSAI principles met'),
                      value: _isHygienicallyPrepared,
                      onChanged: (v) => setState(() => _isHygienicallyPrepared = v ?? false),
                    ),
                    CheckboxListTile(
                      dense: true,
                      activeColor: AppColors.primary,
                      title: const Text('Properly Stored in insulated/clean container'),
                      value: _isProperlyStored,
                      onChanged: (v) => setState(() => _isProperlyStored = v ?? false),
                    ),
                    CheckboxListTile(
                      dense: true,
                      activeColor: AppColors.primary,
                      title: const Text('Safe & Suitable for Human Consumption'),
                      value: _isSafeForConsumption,
                      onChanged: (v) => setState(() => _isSafeForConsumption = v ?? false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
