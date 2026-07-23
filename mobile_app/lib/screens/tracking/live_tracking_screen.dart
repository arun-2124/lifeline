import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/donation_model.dart';
import 'package:mobile_app/models/tracking_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/custom_button.dart';
import 'package:mobile_app/widgets/delivery_timeline_widget.dart';
import 'package:mobile_app/widgets/live_tracking_map_widget.dart';
import 'package:mobile_app/widgets/qr_generator_widget.dart';

class LiveTrackingScreen extends ConsumerStatefulWidget {
  final DonationModel donation;

  const LiveTrackingScreen({super.key, required this.donation});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trackingNotifierProvider.notifier).loadQrCode(widget.donation.donationId);
      ref.read(trackingNotifierProvider.notifier).loadDeliveryLogs(widget.donation.donationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingNotifierProvider);

    final fallbackTracking = TrackingModel(
      trackingId: widget.donation.donationId,
      donationId: widget.donation.donationId,
      deliveryId: 'del_${widget.donation.donationId}',
      volunteerId: 'vol_demo',
      volunteerName: 'Rahul Kumar (Volunteer Driver)',
      currentLat: widget.donation.latitude,
      currentLng: widget.donation.longitude,
      lastUpdated: DateTime.now(),
      estimatedArrivalMinutes: 14,
      distanceRemainingKm: 3.2,
    );

    final liveTracking = trackingState.liveTracking ?? fallbackTracking;
    final qrCode = trackingState.qrCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Delivery Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Handover QR',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.qrScannerRoute);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LiveTrackingMapWidget(tracking: liveTracking),
            const SizedBox(height: 20),
            if (qrCode != null) QrGeneratorWidget(qrCode: qrCode),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE9ECEF)),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DeliveryTimelineWidget(logs: trackingState.deliveryLogs),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Scan QR Code at Handover',
              icon: Icons.qr_code_scanner,
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.qrScannerRoute);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
