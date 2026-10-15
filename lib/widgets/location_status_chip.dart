import 'package:flutter/material.dart';
import 'package:kkp_rep_mobile_app/services/location_service.dart';
import 'package:kkp_rep_mobile_app/theme/app_theme.dart';

class LocationStatusChip extends StatefulWidget {
  final double shopLat;
  final double shopLng;
  final double thresholdMeters;
  final bool compact;

  const LocationStatusChip({
    super.key,
    required this.shopLat,
    required this.shopLng,
    this.thresholdMeters = LocationService.defaultReachedThresholdMeters,
    this.compact = false,
  });

  @override
  State<LocationStatusChip> createState() => _LocationStatusChipState();
}

class _LocationStatusChipState extends State<LocationStatusChip> {
  final LocationService _locationService = LocationService();
  double _distanceMeters = 999999.0;
  bool _isReached = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLocationProximity();
  }

  @override
  void didUpdateWidget(covariant LocationStatusChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shopLat != widget.shopLat || oldWidget.shopLng != widget.shopLng) {
      _checkLocationProximity();
    }
  }

  void _checkLocationProximity() {
    if (!mounted) return;

    final userLat = _locationService.userLatitude;
    final userLng = _locationService.userLongitude;

    if (userLat != null && userLng != null && widget.shopLat != 0.0 && widget.shopLng != 0.0) {
      final distance = LocationService.calculateDistanceMeters(
        userLat,
        userLng,
        widget.shopLat,
        widget.shopLng,
      );

      setState(() {
        _distanceMeters = distance;
        _isReached = distance <= widget.thresholdMeters;
        _isLoading = false;
      });
    } else {
      setState(() {
        _distanceMeters = 999999.0;
        _isReached = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_isReached) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.compact ? 6 : 10,
          vertical: widget.compact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.emeraldSuccess.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.emeraldSuccess, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 12, color: AppColors.emeraldSuccess),
            const SizedBox(width: 4),
            Text(
              widget.compact
                  ? 'Reached (${_distanceMeters.toStringAsFixed(0)}m)'
                  : 'Reached Location (${_distanceMeters.toStringAsFixed(0)}m away)',
              style: TextStyle(
                color: AppColors.emeraldSuccess,
                fontSize: widget.compact ? 10 : 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final distanceStr = LocationService.formatDistance(_distanceMeters);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 6 : 10,
        vertical: widget.compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.cyanAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cyanAccent.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 12, color: AppColors.cyanAccent),
          const SizedBox(width: 4),
          Text(
            distanceStr,
            style: TextStyle(
              color: AppColors.cyanAccent,
              fontSize: widget.compact ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
