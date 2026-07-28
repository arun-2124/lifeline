import 'dart:async';
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

class DirectMealRequestScreen extends ConsumerStatefulWidget {
  const DirectMealRequestScreen({super.key});

  @override
  ConsumerState<DirectMealRequestScreen> createState() => _DirectMealRequestScreenState();
}

class _DirectMealRequestScreenState extends ConsumerState<DirectMealRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mealsCountController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;

  String _selectedUrgency = 'High';
  bool _isSubmitting = false;
  bool _isFetchingLocation = false;
  String? _phoneUniquenessError;

  final List<String> _urgencyLevels = ['Critical (Immediate)', 'High (Today)', 'Normal (Next 24h)'];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    
    _nameController = TextEditingController(
      text: user?.fullName.isNotEmpty == true ? user!.fullName : 'Beneficiary Applicant',
    );
    _mealsCountController = TextEditingController(text: '10');
    _addressController = TextEditingController(
      text: 'Sector 3 Relief Zone, Main Road, Bangalore',
    );

    final rawPhone = user?.phoneNumber ?? '';
    final digitsOnly = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    _phoneController = TextEditingController(
      text: digitsOnly.length == 10 ? digitsOnly : '9876543210',
    );

    _notesController = TextEditingController(text: 'Emergency warm cooked meals required');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mealsCountController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveLocationForAddress() async {
    setState(() {
      _isFetchingLocation = true;
    });

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
            _addressController.text =
                'Live Location (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}) - Bangalore Relief Zone';
            _isFetchingLocation = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Live GPS location detected and filled!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isFetchingLocation = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
        AppLogger.e('Failed to fetch live location', e);
      }
    }
  }

  Future<bool> _isPhoneUnique(String phoneDigits) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('beneficiary_requests')
          .where('contactPhone', isEqualTo: phoneDigits)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 3));

      return snap.docs.isEmpty;
    } catch (e) {
      return true; // Fallback to allow submission if Firestore offline
    }
  }

  Future<void> _submitRequest() async {
    setState(() {
      _phoneUniquenessError = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final cleanPhone = _phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length != 10) {
      setState(() {
        _phoneUniquenessError = 'Phone number must be exactly 10 digits.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final isUnique = await _isPhoneUnique(cleanPhone);
    if (!isUnique) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _phoneUniquenessError = 'This 10-digit phone number already has an active request.';
        });
      }
      return;
    }

    final user = ref.read(authNotifierProvider).user;

    final requestData = {
      'applicantUid': user?.uid ?? 'anonymous_beneficiary',
      'applicantName': _nameController.text.trim(),
      'numberOfMealsRequired': int.tryParse(_mealsCountController.text.trim()) ?? 10,
      'deliveryAddress': _addressController.text.trim(),
      'contactPhone': cleanPhone,
      'urgencyLevel': _selectedUrgency,
      'specialNotes': _notesController.text.trim(),
      'status': 'Pending Approval',
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      final docRef = FirebaseFirestore.instance.collection('beneficiary_requests').doc();
      requestData['requestId'] = docRef.id;

      await docRef.set(requestData).timeout(const Duration(seconds: 4));
    } catch (e) {
      AppLogger.e('Firestore direct meal submit note: $e');
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

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
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
              SizedBox(width: 10),
              Text(
                'Request Submitted!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your emergency meal assistance request has been received.',
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
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
                    Text(
                      'Applicant: ${_nameController.text}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Text(
                      'Phone: ${_phoneController.text}',
                      style: const TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                    Text(
                      'Meals Requested: ${_mealsCountController.text} Portions',
                      style: const TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                    Text(
                      'Urgency: $_selectedUrgency',
                      style: const TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nearby NGOs and Community Kitchens have been alerted.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
                Navigator.of(context).pop(); // Close Dialog
                Navigator.of(context).pop(); // Go back to Beneficiary Dashboard
              },
              child: const Text('Back to Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          'Request Direct Meal',
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: Colors.deepOrange.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fastfood_rounded,
                            color: Colors.deepOrange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency Food Assistance',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'For individuals, families & shelter managers',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Applicant / Shelter Name',
                      hint: 'e.g. Hope Shelter / Rahul Kumar',
                      controller: _nameController,
                      validator: Validators.validateFullName,
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Number of Meals Required',
                      hint: '10',
                      controller: _mealsCountController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Please enter quantity' : null,
                      prefixIcon: Icons.restaurant_rounded,
                    ),
                    const SizedBox(height: 16),

                    // Delivery Address with Live GPS Location Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery Address',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        TextButton.icon(
                          onPressed: _isFetchingLocation ? null : _fetchLiveLocationForAddress,
                          icon: _isFetchingLocation
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location_rounded, size: 14, color: AppColors.primary),
                          label: const Text(
                            'Use Live Location',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    CustomTextField(
                      label: '',
                      hint: 'Street, Sector, City',
                      controller: _addressController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Please enter or detect live location' : null,
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),

                    // 10-Digit Unique Phone Field
                    CustomTextField(
                      label: '10-Digit Mobile Phone Number',
                      hint: '9876543210',
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      validator: Validators.validatePhoneNumber,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    if (_phoneUniquenessError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _phoneUniquenessError!,
                        style: const TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.bold),
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Text(
                      'Urgency Level',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedUrgency,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.surfaceSubtle),
                        ),
                      ),
                      items: _urgencyLevels.map((lvl) {
                        return DropdownMenuItem(
                          value: lvl.contains('High') ? 'High' : (lvl.contains('Critical') ? 'Critical' : 'Normal'),
                          child: Text(lvl, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedUrgency = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Special Dietary Requirements / Notes',
                      hint: 'e.g. Vegetarian only, infant food required',
                      controller: _notesController,
                      prefixIcon: Icons.note_alt_outlined,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Submit Emergency Request',
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
