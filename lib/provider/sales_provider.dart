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
    List<Map<String, dynamic>>? payments,
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
        if (payments != null && payments.isNotEmpty) 'payments': payments,
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

  Future<List<Map<String, dynamic>>> getShopCreditSales(int shopId) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _dioClient.get('${ApiRoutes.shopCreditSalesUrl}/$shopId/credit-sales');
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> salesJson = [];
        if (data is Map) {
          final target = data.containsKey('data') ? data['data'] : data;
          if (target is List) {
            salesJson = target;
          }
        } else if (data is List) {
          salesJson = data;
        }

        return salesJson.map((s) => Map<String, dynamic>.from(s)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get shop credit sales error: $e');
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getDailySettlement() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _dioClient.get(ApiRoutes.dailySettlementUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          final target = data.containsKey('data') ? data['data'] : data;
          if (target is Map) {
            return Map<String, dynamic>.from(target);
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get daily settlement error: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> submitDailySettlement(Map<String, dynamic> payload) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _dioClient.post(
        ApiRoutes.dailySettlementUrl,
        data: payload,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map) {
          final target = data.containsKey('data') ? data['data'] : data;
          if (target is Map) {
            return Map<String, dynamic>.from(target);
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Submit daily settlement error: ');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}