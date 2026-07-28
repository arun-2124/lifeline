import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/tracking_model.dart';
import 'package:mobile_app/widgets/google_map_container_widget.dart';

class LiveTrackingMapWidget extends StatelessWidget {
  final TrackingModel tracking;

  const LiveTrackingMapWidget({super.key, required this.tracking});

  Set<Marker> _buildMarkers() {
    final driverPos = LatLng(tracking.currentLat, tracking.currentLng);
    final dropPos = LatLng(tracking.currentLat + 0.006, tracking.currentLng + 0.005);

    return {
      Marker(
        markerId: const MarkerId('live_driver'),
        position: driverPos,
        infoWindow: InfoWindow(
          title: tracking.volunteerName,
          snippet: 'Speed: ${tracking.speedKmh.toStringAsFixed(1)} km/h • Live GPS',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: const MarkerId('drop_destination'),
        position: dropPos,
        infoWindow: const InfoWindow(
          title: 'Delivery Destination',
          snippet: 'Community Relief Shelter',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  Set<Polyline> _buildPolylines() {
    final driverPos = LatLng(tracking.currentLat, tracking.currentLng);
    final dropPos = LatLng(tracking.currentLat + 0.006, tracking.currentLng + 0.005);

    return {
      Polyline(
        polylineId: const PolylineId('tracking_path'),
        color: AppColors.primary,
        width: 6,
        points: [driverPos, dropPos],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final driverPos = LatLng(tracking.currentLat, tracking.currentLng);

    return Stack(
      children: [
        // Interactive Google Map Widget
        GoogleMapContainerWidget(
          initialTarget: driverPos,
          initialZoom: 15.0,
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          height: 240,
        ),

        // Top Overlay Banner (ETA & Distance)
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'ETA: ~${tracking.estimatedArrivalMinutes} mins',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.navigation_outlined, color: AppColors.secondary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${tracking.distanceRemainingKm} km left',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Bottom Telemetry Bar
        Positioned(
          bottom: 12,
          left: 12,
          right: 120, // Avoid overlapping the Floating Action Button
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GPS: (${tracking.currentLat.toStringAsFixed(4)}, ${tracking.currentLng.toStringAsFixed(4)})',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                Text(
                  '${tracking.speedKmh.toStringAsFixed(1)} km/h',
                  style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
