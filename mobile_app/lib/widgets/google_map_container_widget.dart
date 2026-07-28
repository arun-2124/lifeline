import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app/core/constants/app_colors.dart';

class GoogleMapContainerWidget extends StatefulWidget {
  final LatLng initialTarget;
  final double initialZoom;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool hasLocationPermission;
  final double height;
  final ValueChanged<GoogleMapController>? onMapCreated;
  final VoidCallback? onRecenterTap;

  const GoogleMapContainerWidget({
    super.key,
    required this.initialTarget,
    this.initialZoom = 14.0,
    this.markers = const {},
    this.polylines = const {},
    this.hasLocationPermission = false,
    this.height = 280,
    this.onMapCreated,
    this.onRecenterTap,
  });

  @override
  State<GoogleMapContainerWidget> createState() => _GoogleMapContainerWidgetState();
}

class _GoogleMapContainerWidgetState extends State<GoogleMapContainerWidget> {
  GoogleMapController? _controller;
  bool _isLoading = true;
  bool _hasError = false;

  Future<void> _launchNativeMapsApp() async {
    final lat = widget.initialTarget.latitude;
    final lng = widget.initialTarget.longitude;
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            if (!_hasError)
              GoogleMap(
                onMapCreated: (c) {
                  _controller = c;
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                  if (widget.onMapCreated != null) {
                    widget.onMapCreated!(c);
                  }
                },
                initialCameraPosition: CameraPosition(
                  target: widget.initialTarget,
                  zoom: widget.initialZoom,
                ),
                markers: widget.markers,
                polylines: widget.polylines,
                myLocationEnabled: widget.hasLocationPermission,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: true,
              ),

            // Loading Indicator Overlay
            if (_isLoading && !_hasError)
              Container(
                color: AppColors.background.withValues(alpha: 0.85),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 12),
                      Text(
                        'Initializing Live Google Map...',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),

            // Error & Retry Screen
            if (_hasError)
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map_outlined, color: AppColors.error, size: 40),
                      const SizedBox(height: 10),
                      const Text(
                        'Map Could Not Be Displayed',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                      ),
                      const Text(
                        'Please verify internet connection or location permissions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              setState(() {
                                _hasError = false;
                                _isLoading = true;
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                            label: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _launchNativeMapsApp,
                            icon: const Icon(Icons.open_in_new_rounded, size: 16),
                            label: const Text('Open App'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Map Control Buttons Overlay (Re-center & Open External App)
            if (!_isLoading && !_hasError)
              Positioned(
                bottom: 12,
                right: 12,
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        elevation: 4,
                      ),
                      onPressed: _launchNativeMapsApp,
                      icon: const Icon(Icons.map_rounded, color: Colors.white, size: 14),
                      label: const Text('Open App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                    const SizedBox(width: 6),
                    FloatingActionButton.small(
                      heroTag: 'map_container_recenter_btn',
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 4,
                      onPressed: widget.onRecenterTap ??
                          () {
                            _controller?.animateCamera(
                              CameraUpdate.newLatLngZoom(widget.initialTarget, widget.initialZoom),
                            );
                          },
                      child: const Icon(Icons.my_location_rounded, size: 18),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
