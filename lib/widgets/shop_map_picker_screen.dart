import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopMapPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  const ShopMapPickerScreen({super.key, this.initialPosition});

  @override
  State<ShopMapPickerScreen> createState() => _ShopMapPickerScreenState();
}

class _ShopMapPickerScreenState extends State<ShopMapPickerScreen> {
  final _controller = MapController();
  late LatLng _selected;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialPosition ?? const LatLng(7.2906, 80.6337);
  }

  Future<void> _locate() async {
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Turn on location services and try again.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is needed to find your position. You can also tap the map.',
        );
      }
      final position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 15),
      );
      if (!mounted) return;
      setState(() => _selected = LatLng(position.latitude, position.longitude));
      _controller.move(_selected, 16);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pin shop location'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _selected),
            child: const Text('Confirm'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: _selected,
                initialZoom: 15,
                onTap: (_, position) => setState(() => _selected = position),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.kkp_mobile_app.kkp_rep_mobile_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.deepOrange,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
            child: const Text('© OpenStreetMap contributors'),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_selected.latitude.toStringAsFixed(6)}, ${_selected.longitude.toStringAsFixed(6)}\nTap the map to select a location.',
                    ),
                  ),
                  IconButton(
                    onPressed: _locating ? null : _locate,
                    tooltip: 'Use my location',
                    icon: _locating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, _selected),
                    child: const Text('Save pin'),
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
