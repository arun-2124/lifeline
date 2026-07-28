import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app/core/constants/app_colors.dart';

class TurnByTurnNavigationScreen extends StatefulWidget {
  const TurnByTurnNavigationScreen({super.key});

  @override
  State<TurnByTurnNavigationScreen> createState() => _TurnByTurnNavigationScreenState();
}

class _TurnByTurnNavigationScreenState extends State<TurnByTurnNavigationScreen> {
  GoogleMapController? _mapController;
  bool _hasLocationPermission = false;
  LatLng _driverPos = const LatLng(12.9716, 77.5946); // Default Driver Pos (Bangalore)
  static const LatLng _nextStopPos = LatLng(12.9780, 77.6010); // Destination: Fresh Bakery & Cafe

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
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
            _hasLocationPermission = true;
            _driverPos = LatLng(pos.latitude, pos.longitude);
          });
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _driverPos,
                zoom: 16.5,
                bearing: 45.0,
                tilt: 60.0,
              ),
            ),
          );
        }
      }
    } catch (_) {}
  }

  Set<Marker> _buildMarkers() {
    return {
      Marker(
        markerId: const MarkerId('driver'),
        position: _driverPos,
        infoWindow: const InfoWindow(title: 'Driver (Your Live Vehicle)', snippet: 'En Route to Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: const MarkerId('next_stop'),
        position: _nextStopPos,
        infoWindow: const InfoWindow(title: 'Fresh Bakery & Cafe', snippet: 'Pickup 15 kg Surplus Bread'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  Set<Polyline> _buildPolylines() {
    final midLat = (_driverPos.latitude + _nextStopPos.latitude) / 2;
    final midLng = (_driverPos.longitude + _nextStopPos.longitude) / 2;

    return {
      Polyline(
        polylineId: const PolylineId('nav_path_main'),
        color: AppColors.primary,
        width: 7,
        points: [
          _driverPos,
          LatLng(midLat + 0.001, midLng - 0.001),
          LatLng(midLat, midLng),
          _nextStopPos,
        ],
      ),
      Polyline(
        polylineId: const PolylineId('nav_path_glow'),
        color: AppColors.primary.withValues(alpha: 0.4),
        width: 14,
        points: [
          _driverPos,
          LatLng(midLat + 0.001, midLng - 0.001),
          LatLng(midLat, midLng),
          _nextStopPos,
        ],
      ),
    };
  }

  Future<void> _launchExternalGoogleMaps() async {
    final googleMapsNavUrl = Uri.parse(
      'google.navigation:q=${_nextStopPos.latitude},${_nextStopPos.longitude}&mode=d',
    );
    final webMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=${_driverPos.latitude},${_driverPos.longitude}&destination=${_nextStopPos.latitude},${_nextStopPos.longitude}&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(googleMapsNavUrl)) {
        await launchUrl(googleMapsNavUrl);
      } else {
        await launchUrl(webMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      await launchUrl(webMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text('Live Turn-by-Turn Navigation'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 3D Perspective Google Map
          GoogleMap(
            onMapCreated: (c) => _mapController = c,
            initialCameraPosition: CameraPosition(
              target: _driverPos,
              zoom: 16.0,
              bearing: 45.0,
              tilt: 60.0, // 3D perspective
            ),
            markers: _buildMarkers(),
            polylines: _buildPolylines(),
            myLocationEnabled: _hasLocationPermission,
            compassEnabled: true,
          ),

          // Top Banner: Turn-by-turn guidance instruction
          Positioned(
            top: 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.turn_right_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'In 150 meters',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Turn right onto 100ft Road',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar: ETA + Launch External Google Maps App Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ETA: 8 mins • 2.1 km',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Destination: Fresh Bakery & Cafe',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceSubtle,
                        ),
                        icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _launchExternalGoogleMaps,
                      icon: const Icon(Icons.navigation_rounded, color: Colors.white),
                      label: const Text(
                        'Launch Native Google Maps App',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
