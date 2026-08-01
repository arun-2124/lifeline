import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/home_cook_profile_model.dart';
import 'package:mobile_app/models/verification_request_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class AdminHomeCookVerificationScreen extends ConsumerStatefulWidget {
  const AdminHomeCookVerificationScreen({super.key});

  @override
  ConsumerState<AdminHomeCookVerificationScreen> createState() => _AdminHomeCookVerificationScreenState();
}

class _AdminHomeCookVerificationScreenState extends ConsumerState<AdminHomeCookVerificationScreen> {
  List<VerificationRequestModel> _pendingRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final repo = ref.read(homeCookRepositoryProvider);
    final list = await repo.adminGetPendingVerificationRequests();
    if (mounted) {
      setState(() {
        _pendingRequests = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _processRequest(VerificationRequestModel req, bool approve) async {
    final repo = ref.read(homeCookRepositoryProvider);
    final success = await repo.adminApproveVerification(
      requestId: req.requestId,
      uid: req.uid,
      newLevel: req.targetLevel,
      approve: approve,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve ? '${req.cookName} upgraded to ${HomeCookProfileModel.formatLevelName(req.targetLevel)}!' : 'Verification Application Rejected.'),
          backgroundColor: approve ? AppColors.success : AppColors.error,
        ),
      );
      _loadRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Home Cook Verification Review',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingRequests.isEmpty
              ? const Center(child: Text('No pending verification applications.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingRequests.length,
                  itemBuilder: (context, index) {
                    final req = _pendingRequests[index];
                    return GlassCard(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.cookName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Target: ${HomeCookProfileModel.formatLevelName(req.targetLevel)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          const Divider(height: 20),
                          Text('ID Proof: ${req.idProofUrl}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text('Kitchen Photo: ${req.kitchenPhotoUrl}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text('Self-Declaration: ${req.hygieneSelfDeclaration}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => _processRequest(req, true),
                                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                  label: const Text('Approve Upgrade', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.error),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => _processRequest(req, false),
                                  icon: const Icon(Icons.cancel_rounded, color: AppColors.error, size: 16),
                                  label: const Text('Reject', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
