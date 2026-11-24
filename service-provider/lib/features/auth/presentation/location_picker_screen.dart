import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/colors.dart';

enum MapType { street, satellite, terrain }

class PickedLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String? landmark;
  final String? road;
  final String? city;
  final String? district;
  final String? state;
  final String? postcode;
  final double radiusKm;

  const PickedLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.landmark,
    this.road,
    this.city,
    this.district,
    this.state,
    this.postcode,
    this.radiusKm = 15.0,
  });
}

class LocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialQuery;
  final double initialRadiusKm;

  const LocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialQuery,
    this.initialRadiusKm = 15.0,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static final LatLngBounds _indiaBounds = LatLngBounds(
    const LatLng(6.5, 68.0),
    const LatLng(37.5, 97.5),
  );

  late final MapController _mapController;
  late LatLng _currentCenter;
  late double _radiusKm;
  MapType _selectedMapType = MapType.street;

  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  bool _isSearching = false;
  bool _isReverseGeocoding = false;
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _searchDebounce;
  Timer? _mapMoveDebounce;

  String _resolvedAddress = 'स्थान लोड हो रहा है...';
  String? _resolvedRoad;
  String? _resolvedCity;
  String? _resolvedDistrict;
  String? _resolvedState;
  String? _resolvedPostcode;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _radiusKm = widget.initialRadiusKm;

    final defaultLat = widget.initialLatitude ?? 26.8467;
    final defaultLng = widget.initialLongitude ?? 80.9462;
    LatLng start = LatLng(defaultLat, defaultLng);
    if (!_indiaBounds.contains(start)) {
      start = const LatLng(26.8467, 80.9462);
    }
    _currentCenter = start;

    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _searchController.text = widget.initialQuery!.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery!.trim());
      });
    } else {
      _reverseGeocode(_currentCenter);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _mapMoveDebounce?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    _dio.close();
    super.dispose();
  }

  String _getTileUrl(MapType type) {
    switch (type) {
      case MapType.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapType.terrain:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';
      case MapType.street:
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  void _onSearchChanged(String val) {
    _searchDebounce?.cancel();
    if (val.trim().length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch(val.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final response = await _dio.get(
        'https://photon.komoot.io/api/',
        queryParameters: {
          'q': query,
          'limit': 6,
          'bbox': '68.0,6.5,97.5,37.5',
        },
      );

      final data = response.data;
      if (data != null && data is Map && data['features'] is List) {
        final List features = data['features'];
        final List<Map<String, dynamic>> list = [];

        for (final item in features) {
          final props = item['properties'] ?? {};
          final geom = item['geometry']?['coordinates'];
          if (geom is List && geom.length >= 2) {
            final double lon = (geom[0] as num).toDouble();
            final double lat = (geom[1] as num).toDouble();

            final countryCode = props['countrycode']?.toString().toUpperCase();
            if (countryCode != null && countryCode != 'IN') {
              continue;
            }

            final target = LatLng(lat, lon);
            if (!_indiaBounds.contains(target)) {
              continue;
            }

            final name = props['name'] ?? props['street'] ?? props['city'] ?? '';
            final parts = <String>[];
            if (props['name'] != null) parts.add(props['name'].toString());
            if (props['street'] != null && props['street'] != props['name']) parts.add(props['street'].toString());
            if (props['district'] != null) parts.add(props['district'].toString());
            if (props['city'] != null && props['city'] != props['district']) parts.add(props['city'].toString());
            if (props['state'] != null) parts.add(props['state'].toString());

            list.add({
              'title': name.toString(),
              'subtitle': parts.join(', '),
              'lat': lat,
              'lon': lon,
            });
          }
        }

        setState(() {
          _searchResults = list;
          _isSearching = false;
        });

        if (list.isNotEmpty && query == widget.initialQuery) {
          _moveToLocation(LatLng(list.first['lat'], list.first['lon']));
        }
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (_) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _moveToLocation(LatLng target) {
    if (!_indiaBounds.contains(target)) return;
    setState(() {
      _currentCenter = target;
      _searchResults = [];
    });
    _mapController.move(target, 14.5);
    _reverseGeocode(target);
  }

  Future<void> _reverseGeocode(LatLng coords) async {
    setState(() => _isReverseGeocoding = true);

    try {
      final response = await _dio.get(
        'https://photon.komoot.io/reverse',
        queryParameters: {
          'lat': coords.latitude,
          'lon': coords.longitude,
        },
      );

      final data = response.data;
      if (data != null && data is Map && data['features'] is List && (data['features'] as List).isNotEmpty) {
        final first = (data['features'] as List).first;
        final props = first['properties'] ?? {};

        final name = props['name']?.toString();
        final street = props['street']?.toString();
        final district = props['district']?.toString() ?? props['county']?.toString();
        final city = props['city']?.toString() ?? props['town']?.toString();
        final state = props['state']?.toString();
        final postcode = props['postcode']?.toString();

        final parts = <String>[];
        if (name != null) parts.add(name);
        if (street != null && street != name) parts.add(street);
        if (district != null) parts.add(district);
        if (city != null && city != district) parts.add(city);
        if (state != null) parts.add(state);
        if (postcode != null) parts.add(postcode);

        setState(() {
          _resolvedAddress = parts.isNotEmpty ? parts.join(', ') : 'चुना गया स्थान';
          _resolvedRoad = street ?? name;
          _resolvedCity = city ?? district;
          _resolvedDistrict = district;
          _resolvedState = state;
          _resolvedPostcode = postcode;
          _isReverseGeocoding = false;
        });
        return;
      }
    } catch (_) {}

    setState(() {
      _resolvedAddress = 'अक्षांश: ${coords.latitude.toStringAsFixed(4)}, रेखांश: ${coords.longitude.toStringAsFixed(4)}';
      _isReverseGeocoding = false;
    });
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      _currentCenter = camera.center;
      _mapMoveDebounce?.cancel();
      _mapMoveDebounce = Timer(const Duration(milliseconds: 500), () {
        _reverseGeocode(_currentCenter);
      });
    }
  }

  void _confirmSelection() {
    Navigator.pop(
      context,
      PickedLocation(
        latitude: _currentCenter.latitude,
        longitude: _currentCenter.longitude,
        address: _resolvedAddress,
        road: _resolvedRoad,
        city: _resolvedCity,
        district: _resolvedDistrict,
        state: _resolvedState,
        postcode: _resolvedPostcode,
        radiusKm: _radiusKm,
      ),
    );
  }

  Widget _buildModeItem(String label, IconData icon, MapType type) {
    final isSelected = _selectedMapType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedMapType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Color(0x20000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF334155)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSatellite = _selectedMapType == MapType.satellite;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          FlutterMap(
            key: ValueKey(_selectedMapType),
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 14.0,
              minZoom: 4.5,
              maxZoom: 18.5,
              cameraConstraint: CameraConstraint.containCenter(bounds: _indiaBounds),
              onPositionChanged: _onPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: _getTileUrl(_selectedMapType),
                userAgentPackageName: 'com.cooperativeclap.provider',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _currentCenter,
                    radius: _radiusKm * 1000,
                    useRadiusInMeter: true,
                    color: AppColors.brandOrange.withOpacity(0.18),
                    borderColor: AppColors.brandOrange,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            ],
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 34),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSatellite ? Colors.black.withOpacity(0.85) : AppColors.textHeading,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Text(
                      'स्थान यहाँ पिन करें (${_radiusKm.round()} km)',
                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Icon(
                    Icons.location_on_rounded,
                    size: 42,
                    color: AppColors.brandOrange,
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),

          Positioned(
            top: 66,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0x24000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModeItem('स्ट्रीट', Icons.map_outlined, MapType.street),
                  _buildModeItem('सैटेलाइट', Icons.satellite_alt_rounded, MapType.satellite),
                  _buildModeItem('टेरेन', Icons.terrain_rounded, MapType.terrain),
                ],
              ),
            ),
          ),

          Positioned(
            right: 12,
            bottom: 104,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildZoomButton(Icons.add, () {
                  _mapController.move(_currentCenter, _mapController.camera.zoom + 1);
                }),
                const SizedBox(height: 6),
                _buildZoomButton(Icons.remove, () {
                  _mapController.move(_currentCenter, _mapController.camera.zoom - 1);
                }),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    _moveToLocation(const LatLng(26.8467, 80.9462));
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Color(0x26000000), blurRadius: 8, offset: Offset(0, 3)),
                      ],
                    ),
                    child: const Icon(Icons.my_location_rounded, size: 20, color: AppColors.brandOrange),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 3)),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textHeading),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 3)),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onChanged: _onSearchChanged,
                            onSubmitted: _performSearch,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'भारत में शहर, कस्बा, गांव या इलाका खोजें...',
                              hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.brandOrange, size: 20),
                              suffixIcon: _isSearching
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandOrange),
                                      ),
                                    )
                                  : (_searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded, size: 16),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _searchResults = []);
                                          },
                                        )
                                      : null),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 240),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final item = _searchResults[i];
                          return ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            leading: const Icon(Icons.location_on_outlined, color: AppColors.brandOrange, size: 20),
                            title: Text(
                              item['title'] ?? '',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textHeading),
                            ),
                            subtitle: Text(
                              item['subtitle'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            onTap: () {
                              _moveToLocation(LatLng(item['lat'], item['lon']));
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 4)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.brandOrange, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _resolvedAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textHeading,
                            ),
                          ),
                        ),
                        if (_isReverseGeocoding)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandOrange),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFED7AA)),
                          ),
                          child: Text(
                            '${_radiusKm.round()} km दायरा',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFEA580C)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.brandOrange,
                              inactiveTrackColor: const Color(0xFFFED7AA),
                              thumbColor: AppColors.brandOrangeDark,
                              overlayColor: AppColors.brandOrange.withOpacity(0.15),
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            ),
                            child: Slider(
                              value: _radiusKm,
                              min: 1,
                              max: 50,
                              divisions: 49,
                              onChanged: (val) {
                                setState(() => _radiusKm = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: _isReverseGeocoding ? null : _confirmSelection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 15),
                                SizedBox(width: 5),
                                Text(
                                  'स्थान चुनें',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
