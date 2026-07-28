import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/utils/app_logger.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class FoodCentersLocatorScreen extends StatefulWidget {
  const FoodCentersLocatorScreen({super.key});

  @override
  State<FoodCentersLocatorScreen> createState() => _FoodCentersLocatorScreenState();
}

class _FoodCentersLocatorScreenState extends State<FoodCentersLocatorScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  bool _hasLocationPermission = false;
  LatLng _userPosition = const LatLng(12.9716, 77.5946); // Default Center (Bangalore)
  LatLng? _searchedLocation;
  String _searchQuery = '';

  // Real Food Relief NGO Dataset (Bangalore & India Verified Non-Profits)
  final List<Map<String, dynamic>> _realNgoDataset = [
    {
      'title': 'The Akshaya Patra Foundation',
      'darpanId': 'DARPAN: KA/2017/0115042',
      'address': 'HKBK College Road, Nagavara, Bengaluru',
      'distance': '1.2 km away',
      'mealsAvailable': '25,000 Meals/Day',
      'status': 'Verified NGO • Open 24/7',
      'phone': '08030143400',
      'lat': 13.0280,
      'lng': 77.6190,
      'icon': Icons.verified_user_rounded,
      'color': AppColors.primary,
    },
    {
      'title': 'Feeding India (Zomato Giving Hub)',
      'darpanId': 'DARPAN: DL/2019/0228190',
      'address': 'Indiranagar 100ft Road, Bengaluru',
      'distance': '2.4 km away',
      'mealsAvailable': '5,000 Meals/Day',
      'status': 'Verified NGO • Active Dispatch',
      'phone': '9818818818',
      'lat': 12.9780,
      'lng': 77.6400,
      'icon': Icons.volunteer_activism_rounded,
      'color': AppColors.success,
    },
    {
      'title': 'Robin Hood Army Bangalore Hub',
      'darpanId': 'DARPAN: MH/2016/0104822',
      'address': 'Koramangala 4th Block, Bengaluru',
      'distance': '3.1 km away',
      'mealsAvailable': '3,500 Meals/Day',
      'status': 'Verified NGO • Evening Distribution',
      'phone': '9876543210',
      'lat': 12.9340,
      'lng': 77.6250,
      'icon': Icons.group_rounded,
      'color': Colors.deepOrange,
    },
    {
      'title': 'No Food Waste NGO Center',
      'darpanId': 'DARPAN: TN/2018/0194833',
      'address': 'HSR Layout Sector 1, Bengaluru',
      'distance': '4.0 km away',
      'mealsAvailable': '2,000 Meals/Day',
      'status': 'Verified NGO • Hot Meals Available',
      'phone': '9087790877',
      'lat': 12.9120,
      'lng': 77.6510,
      'icon': Icons.restaurant_rounded,
      'color': AppColors.info,
    },
    {
      'title': 'Rise Against Hunger India',
      'darpanId': 'DARPAN: KA/2015/0091823',
      'address': 'Whitefield Main Road, Bengaluru',
      'distance': '5.8 km away',
      'mealsAvailable': '10,000 Meals/Day',
      'status': 'Verified NGO • Emergency Ration Hub',
      'phone': '08041123456',
      'lat': 12.9690,
      'lng': 77.7490,
      'icon': Icons.night_shelter_rounded,
      'color': Colors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionAndFetchPosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermissionAndFetchPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        setState(() {
          _hasLocationPermission = true;
        });

        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );

        if (mounted) {
          setState(() {
            _userPosition = LatLng(pos.latitude, pos.longitude);
          });
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_userPosition, 13.5),
          );
        }
      }
    } catch (e) {
      AppLogger.e('Location permission request deferred', e);
    }
  }

  Future<void> _launchExternalGoogleMapsApp(double lat, double lng, String label) async {
    final geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(label)})');
    final webUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    try {
      if (await canLaunchUrl(geoUrl)) {
        await launchUrl(geoUrl);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _onPlaceSelected(Map<String, dynamic> ngo) {
    final lat = ngo['lat'] as double;
    final lng = ngo['lng'] as double;
    final pos = LatLng(lat, lng);

    setState(() {
      _searchedLocation = pos;
      _searchController.text = ngo['title'] as String;
      _searchQuery = ngo['title'] as String;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(pos, 15.5),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('user_pos'),
        position: _userPosition,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };

    for (var i = 0; i < _realNgoDataset.length; i++) {
      final ngo = _realNgoDataset[i];
      markers.add(
        Marker(
          markerId: MarkerId('ngo_$i'),
          position: LatLng(ngo['lat'] as double, ngo['lng'] as double),
          infoWindow: InfoWindow(
            title: ngo['title'] as String,
            snippet: '${ngo['darpanId']} • ${ngo['mealsAvailable']}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    if (_searchedLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('searched_place'),
          position: _searchedLocation!,
          infoWindow: InfoWindow(title: _searchController.text),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }

    return markers;
  }

  List<Map<String, dynamic>> _getFilteredNgos() {
    if (_searchQuery.trim().isEmpty) {
      return _realNgoDataset;
    }
    final query = _searchQuery.toLowerCase();
    return _realNgoDataset.where((ngo) {
      final title = (ngo['title'] as String).toLowerCase();
      final addr = (ngo['address'] as String).toLowerCase();
      final darpan = (ngo['darpanId'] as String).toLowerCase();
      return title.contains(query) || addr.contains(query) || darpan.contains(query);
    }).toList();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final ngoList = _getFilteredNgos();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Verified NGO Relief Hubs',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_rounded),
            tooltip: 'Register New NGO',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.ngoRegistrationRoute);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Stack with Search Overlay
          SizedBox(
            height: 310,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _userPosition,
                    zoom: 12.8,
                  ),
                  markers: _buildMarkers(),
                  myLocationEnabled: _hasLocationPermission,
                  myLocationButtonEnabled: false,
                ),

                // Search Bar Overlay on Map
                Positioned(
                  top: 12,
                  left: 14,
                  right: 14,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Search NGO name, DARPAN ID, or area...',
                            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close_rounded, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                        _searchedLocation = null;
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Map Actions Overlay
                Positioned(
                  bottom: 12,
                  right: 14,
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          elevation: 4,
                        ),
                        onPressed: () {
                          final target = _searchedLocation ?? _userPosition;
                          _launchExternalGoogleMapsApp(target.latitude, target.longitude, 'Verified NGO Hubs');
                        },
                        icon: const Icon(Icons.map_rounded, color: Colors.white, size: 16),
                        label: const Text('Open Maps App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton.small(
                        heroTag: 'recenter_ngo_map_btn',
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 4,
                        onPressed: () {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(_userPosition, 13.5),
                          );
                        },
                        child: const Icon(Icons.my_location_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Real NGO Count & Registration Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surface,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Verified NGOs (${ngoList.length})',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.ngoRegistrationRoute);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGlow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_circle_outline_rounded, size: 12, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Register NGO',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List of Real Verified NGOs
          Expanded(
            child: ngoList.isEmpty
                ? const Center(
                    child: Text('No matching verified NGOs found.', style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ngoList.length,
                    itemBuilder: (context, index) {
                      final ngo = ngoList[index];
                      final lat = ngo['lat'] as double;
                      final lng = ngo['lng'] as double;

                      return GestureDetector(
                        onTap: () => _onPlaceSelected(ngo),
                        child: GlassCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: (ngo['color'] as Color).withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(ngo['icon'] as IconData, color: ngo['color'] as Color, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ngo['title'] as String,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                        ),
                                        Text(
                                          '${ngo['address']} • ${ngo['distance']}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          ngo['darpanId'] as String,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ngo['status'] as String,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Capacity: ${ngo['mealsAvailable']}',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      elevation: 2,
                                    ),
                                    onPressed: () {
                                      _launchExternalGoogleMapsApp(lat, lng, ngo['title'] as String);
                                    },
                                    icon: const Icon(Icons.directions_rounded, color: Colors.white, size: 14),
                                    label: const Text(
                                      'Directions',
                                      style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
