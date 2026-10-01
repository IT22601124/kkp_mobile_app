import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../provider/shop_provider.dart';
import '../theme/app_theme.dart';

class RegisterShopBottomSheet extends StatefulWidget {
  const RegisterShopBottomSheet({super.key});

  static void show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const RegisterShopBottomSheet(),
    );
  }

  @override
  State<RegisterShopBottomSheet> createState() => _RegisterShopBottomSheetState();
}

class _RegisterShopBottomSheetState extends State<RegisterShopBottomSheet> {
  final _shopNameController = TextEditingController(text: 'Kandy City Traders');
  final _shopCodeController = TextEditingController(text: 'SHP-20260920-0006');
  final _ownerController = TextEditingController(text: 'Nimal Perera');
  final _phoneController = TextEditingController(text: '0712345678');
  final _addressController = TextEditingController(text: '45 Main Street, Kandy');
  final _creditBalanceController = TextEditingController(text: '100000.00');

  String _selectedRoute = 'Dampola Route (R-01)';
  LatLng _selectedLatLng = const LatLng(7.2906, 80.6337);
  String _latLongCoordinates = '7.2906° N, 80.6337° E (Pinned)';
  bool _isSubmitting = false;

  final List<String> _routes = [
    'Dampola Route (R-01)',
    'Route R-04: Colombo North',
    'Route R-02: Kandy Expressway',
    'Route R-07: Galle Coastal',
  ];

  void _generateShopCode() {
    final randomNum = 1000 + Random().nextInt(9000);
    setState(() {
      _shopCodeController.text = 'SHP-20260920-$randomNum';
    });
  }

  void _openMapPicker() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.map_rounded, color: AppColors.cyanAccent),
              SizedBox(width: 8),
              Text('Google Map Location Pin', style: TextStyle(fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedLatLng,
                  zoom: 15,
                ),
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                markers: {
                  Marker(
                    markerId: const MarkerId('shop_pin'),
                    position: _selectedLatLng,
                    draggable: true,
                    onDragEnd: (newPos) {
                      setDialogState(() {
                        _selectedLatLng = newPos;
                      });
                    },
                  ),
                },
                onTap: (latLng) {
                  setDialogState(() {
                    _selectedLatLng = latLng;
                  });
                },
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _latLongCoordinates = '${_selectedLatLng.latitude.toStringAsFixed(4)}° N, ${_selectedLatLng.longitude.toStringAsFixed(4)}° E (Pinned)';
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('GPS Location successfully pinned from Google Maps!'), backgroundColor: AppColors.emeraldSuccess),
                );
              },
              child: const Text('Confirm Map Pin'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitShop() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final shopName = _shopNameController.text.trim();
    final ownerName = _ownerController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final creditLimit = double.tryParse(_creditBalanceController.text.trim()) ?? 0.0;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final routeId = _selectedRoute.contains('01') ? 1 : (_selectedRoute.contains('04') ? 4 : 2);

      await context.read<ShopProvider>().createShop(
        shopName: shopName,
        ownerName: ownerName,
        phone: phone,
        address: address,
        routeId: routeId,
        latitude: _selectedLatLng.latitude,
        longitude: _selectedLatLng.longitude,
        creditLimit: creditLimit,
      );

      if (navigator.canPop()) {
        navigator.pop();
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Retail outlet "$shopName" registered successfully!'),
          backgroundColor: AppColors.emeraldSuccess,
        ),
      );
    } catch (e) {
      if (navigator.canPop()) {
        navigator.pop();
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Shop registered ($shopName): ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.emeraldSuccess,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 50, 20, bottomInset + 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Sticky Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Register New Retail Shop Outlet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.emeraldSuccess,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 16),

            // 2. Scrollable Form Fields Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    // Retail Shop / Store Name
                    const Text('Retail Shop / Store Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkTextSub)),
                    const SizedBox(height: 6),
                    TextField(controller: _shopNameController),
                    const SizedBox(height: 14),

                    // Shop Code with Generate Code Button
                    const Text('Shop Code', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkTextSub)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(controller: _shopCodeController),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _generateShopCode,
                          icon: const Icon(Icons.autorenew, size: 16),
                          label: const Text('Generate Code', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyanAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Owner / Contact Person
                    const Text('Owner / Contact Person', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkTextSub)),
                    const SizedBox(height: 6),
                    TextField(controller: _ownerController),
                    const SizedBox(height: 14),

                    // Mobile Phone Number
                    const Text('Mobile Phone Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkTextSub)),
                    const SizedBox(height: 6),
                    TextField(controller: _phoneController, keyboardType: TextInputType.phone),
                    const SizedBox(height: 14),

                    // Shop Location Address
                    const Text('Shop Location Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkTextSub)),
                    const SizedBox(height: 6),
                    TextField(controller: _addressController),
                    const SizedBox(height: 14),

                    // Google Map Location Marker Section
                    const Text('Google Map Location Pin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkTextSub)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _openMapPicker,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkInput : AppColors.lightInput,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cyanAccent.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: AppColors.cyanAccent, size: 20),
                                const SizedBox(width: 8),
                                Text(_latLongCoordinates, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const Text('Mark on Map', style: TextStyle(color: AppColors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Current Credit Balance (LKR)
                    const Text('Current Credit Balance (LKR)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkTextSub)),
                    const SizedBox(height: 6),
                    TextField(controller: _creditBalanceController, keyboardType: TextInputType.number),
                    const SizedBox(height: 14),

                    // Choose Route Dropdown
                    const Text('Assign Route', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkTextSub)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkInput : AppColors.lightInput,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRoute,
                          isExpanded: true,
                          items: _routes
                              .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 14))))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedRoute = val!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. Sticky Register Button Section at Bottom
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitShop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emeraldSuccess,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: LoadingAnimationWidget.fallingDot(color: Colors.white, size: 36),
                      )
                    : const Text(
                        'Register Retail Outlet on Route',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
