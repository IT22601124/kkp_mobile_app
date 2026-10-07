import 'package:flutter/material.dart';
import 'package:kkp_rep_mobile_app/dio/dio_client.dart';
import 'package:kkp_rep_mobile_app/resources/api_routes.dart';

class SalesProvider extends ChangeNotifier {
  bool isLoading = false;
  final DioClient _dioClient = DioClient();
  Map<String, dynamic>? lastCreatedSale;

  Future<Map<String, dynamic>?> createSale({
    required int shopId,
    int? branchId,
    int? dsrTripId,
    String? saleDate,
    required String paymentType,
    String status = 'COMPLETED',
    double discount = 0.0,
    double tax = 0.0,
    required double paidAmount,
    String? notes,
    required List<Map<String, dynamic>> items,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final payload = <String, dynamic>{
        'shop_id': shopId,
        if (branchId != null) 'branch_id': branchId,
        if (dsrTripId != null) 'dsr_trip_id': dsrTripId,
        'sale_date': saleDate ?? DateTime.now().toString().split('.').first,
        'payment_type': paymentType,
        'status': status,
        'discount': discount,
        'tax': tax,
        'paid_amount': paidAmount,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'items': items,
      };

      debugPrint('Creating sale with payload: $payload');

      final response = await _dioClient.post(
        ApiRoutes.salesUrl,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map) {
          if (data.containsKey('data') && data['data'] is Map) {
            lastCreatedSale = Map<String, dynamic>.from(data['data']);
          } else {
            lastCreatedSale = Map<String, dynamic>.from(data);
          }
        }
        notifyListeners();
        return lastCreatedSale;
      }
      return null;
    } catch (e) {
      debugPrint('Create sale error: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
