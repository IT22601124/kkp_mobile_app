import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../theme/app_theme.dart';

class GoogleMapPickerScreen extends StatefulWidget {
  final latlong.LatLng? initialPosition;

  const GoogleMapPickerScreen({super.key, this.initialPosition});

  @override
  State<GoogleMapPickerScreen> createState() => _GoogleMapPickerScreenState();
}

class _GoogleMapPickerScreenState extends State<GoogleMapPickerScreen> {
  late LatLng _currentCenter;
  late Set<Marker> _markers;

  @override
  void initState() {
    super.initState();
    final initLat = widget.initialPosition?.latitude ?? 7.2906;
    final initLng = widget.initialPosition?.longitude ?? 80.6337;
    _currentCenter = LatLng(initLat, initLng);

    _markers = {
      Marker(
        markerId: const MarkerId('selected_location'),
        position: _currentCenter,
        draggable: true,
        onDragEnd: (newPos) {
          setState(() {
            _currentCenter = newPos;
          });
        },
      ),
    };
  }

  void _onTapMap(LatLng position) {
    setState(() {
      _currentCenter = position;
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragEnd: (newPos) {
            setState(() {
              _currentCenter = newPos;
            });
          },
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pin Shop Location on Map', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        elevation: 1,
        actions: [
          TextButton.icon(
            onPressed: () {
              final result = latlong.LatLng(_currentCenter.latitude, _currentCenter.longitude);
              Navigator.pop(context, result);
            },
            icon: const Icon(Icons.check, color: AppColors.emeraldSuccess),
            label: const Text('Confirm', style: TextStyle(color: AppColors.emeraldSuccess, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 15,
            ),
            markers: _markers,
            onTap: _onTapMap,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primaryOrange, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Selected: ${_currentCenter.latitude.toStringAsFixed(4)}° N, ${_currentCenter.longitude.toStringAsFixed(4)}° E\n(Tap map to pin location)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final result = latlong.LatLng(_currentCenter.latitude, _currentCenter.longitude);
                      Navigator.pop(context, result);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emeraldSuccess,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Save Pin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
