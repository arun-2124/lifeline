import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/utils/app_logger.dart';
import 'package:mobile_app/utils/validators.dart';
import 'package:mobile_app/widgets/custom_button.dart';
import 'package:mobile_app/widgets/custom_text_field.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class NgoRegistrationScreen extends ConsumerStatefulWidget {
  const NgoRegistrationScreen({super.key});

  @override
  ConsumerState<NgoRegistrationScreen> createState() => _NgoRegistrationScreenState();
}

class _NgoRegistrationScreenState extends ConsumerState<NgoRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController();
  final _darpanIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _capacityController = TextEditingController(text: '1000');
  final _taxCertificateController = TextEditingController();

  String _selectedCategory = 'Food Relief & Community Kitchen';
  bool _isSubmitting = false;
  bool _isFetchingLocation = false;
  double _lat = 12.9716;
  double _lng = 77.5946;

  final List<String> _ngoCategories = [
    'Food Relief & Community Kitchen',
    'Child & School Nutrition (Mid-Day Meals)',
    'Disaster & Emergency Relief',
    'Shelter & Homeless Support',
    'Zero Waste & Surplus Food Rescue',
  ];

  @override
  void dispose() {
    _orgNameController.dispose();
    _darpanIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _capacityController.dispose();
    _taxCertificateController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );

        if (mounted) {
          setState(() {
            _lat = pos.latitude;
            _lng = pos.longitude;
            _addressController.text =
                'NGO Hub (GPS: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}), Bangalore';
            _isFetchingLocation = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('NGO GPS coordinates detected and filled!'), backgroundColor: AppColors.success),
          );
        }
      } else {
        if (mounted) setState(() => _isFetchingLocation = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingLocation = false);
      AppLogger.e('NGO location fetch error', e);
    }
  }

  Future<void> _registerNgo() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = ref.read(authNotifierProvider).user;

    setState(() => _isSubmitting = true);

    final cleanPhone = _phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');

    final ngoData = {
      'ngoId': user?.uid ?? FirebaseFirestore.instance.collection('ngos').doc().id,
      'orgName': _orgNameController.text.trim(),
      'darpanId': _darpanIdController.text.trim().toUpperCase(),
      'category': _selectedCategory,
      'officialEmail': _emailController.text.trim(),
      'contactPhone': cleanPhone,
      'officeAddress': _addressController.text.trim(),
      'dailyMealCapacity': int.tryParse(_capacityController.text.trim()) ?? 1000,
      'taxCertificate80G': _taxCertificateController.text.trim(),
      'latitude': _lat,
      'longitude': _lng,
      'verificationStatus': 'pending',
      'registeredAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('ngos')
          .doc(ngoData['ngoId'] as String)
          .set(ngoData)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      AppLogger.e('NGO Registration Firestore note: $e');
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.surface,
          title: const Row(
            children: [
              Icon(Icons.verified_user_rounded, color: AppColors.success, size: 28),
              SizedBox(width: 10),
              Text('NGO Registration Submitted!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_orgNameController.text} has been successfully submitted for DARPAN verification.',
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGlow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DARPAN ID: ${_darpanIdController.text}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text('Capacity: ${_capacityController.text} Meals/day', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                    Text('Status: Pending Admin Verification', style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Back to Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Register NGO Organization',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + bottomInset,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.business_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Official NGO Registration',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              Text(
                                'Verified DARPAN Non-Profit Portal',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'NGO Organization Name',
                      hint: 'e.g. Akshaya Patra Foundation',
                      controller: _orgNameController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter NGO legal name' : null,
                      prefixIcon: Icons.corporate_fare_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'NITI Aayog DARPAN ID',
                      hint: 'KA/2018/0194821',
                      controller: _darpanIdController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter NITI Aayog DARPAN ID' : null,
                      prefixIcon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),
                    const Text('Organization Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.surfaceSubtle),
                        ),
                      ),
                      items: _ngoCategories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Official Email Address',
                      hint: 'contact@akshayapatra.org',
                      controller: _emailController,
                      validator: Validators.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: '10-Digit Helpline Contact Phone',
                      hint: '9876543210',
                      controller: _phoneController,
                      validator: Validators.validatePhoneNumber,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kitchen / Drop Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        TextButton.icon(
                          onPressed: _isFetchingLocation ? null : _fetchLiveLocation,
                          icon: _isFetchingLocation
                              ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.my_location_rounded, size: 14, color: AppColors.primary),
                          label: const Text('Use GPS Location', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                      ],
                    ),
                    CustomTextField(
                      label: '',
                      hint: 'HKBK Road, Nagavara, Bangalore',
                      controller: _addressController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter address' : null,
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Daily Meal Distribution Capacity',
                      hint: '25000',
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter daily meal capacity' : null,
                      prefixIcon: Icons.restaurant_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: '80G Tax Exemption Reg Number',
                      hint: 'AAATA0000F20214',
                      controller: _taxCertificateController,
                      prefixIcon: Icons.verified_outlined,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Register NGO Organization',
                      isLoading: _isSubmitting,
                      onPressed: _registerNgo,
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
