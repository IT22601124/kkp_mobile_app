import 'session_notifier.dart';
import 'package:flutter/material.dart';
import 'package:kkp_rep_mobile_app/dio/dio_client.dart';
import 'package:kkp_rep_mobile_app/resources/api_routes.dart';

class SalesProvider extends SessionNotifier {
  bool isLoading = false;
  final DioClient _dioClient = DioClient();
  Map<String, dynamic>? lastCreatedSale;
  List<Map<String, dynamic>> listSales = [];
  String? _salesStartDate;
  String? _salesEndDate;
  bool _hasLoadedSales = false;

  bool hasLoadedSales({String? startDate, String? endDate}) {
    return _hasLoadedSales &&
        _salesStartDate == startDate &&
        _salesEndDate == endDate;
  }

  List<Map<String, dynamic>> salesForRange({
    String? startDate,
    String? endDate,
  }) {
    if (!hasLoadedSales(startDate: startDate, endDate: endDate)) {
      return const [];
    }
    return listSales;
  }

  Future<List<Map<String, dynamic>>> loadSalesIfNeeded({
    String? startDate,
    String? endDate,
  }) {
    if (hasLoadedSales(startDate: startDate, endDate: endDate)) {
      return Future.value(listSales);
    }
    return getSales(startDate: startDate, endDate: endDate);
  }

  Future<Map<String, dynamic>?> createSale({
    required int shopId,
    int? branchId,
    int? dsrTripId,
    String? saleDate,
    required String paymentType,
    int? bankAccountId,
    String? referenceNumber,
    String? bankSlip,
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
        'branch_id': ?branchId,
        'dsr_trip_id': ?dsrTripId,
        'sale_date': saleDate ?? DateTime.now().toString().split('.').first,
        'payment_type': paymentType,
        'bank_account_id': ?bankAccountId,
        if (referenceNumber != null && referenceNumber.isNotEmpty)
          'reference_number': referenceNumber,
        if (bankSlip != null && bankSlip.isNotEmpty) 'bank_slip': bankSlip,
        'status': status,
        'discount': discount,
        'tax': tax,
        'paid_amount': paidAmount,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'items': items,
        if (payments != null && payments.isNotEmpty) 'payments': payments,
      };

      final response = await _dioClient.post(ApiRoutes.salesUrl, data: payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        Map<String, dynamic>? createdSale;
        if (data is Map) {
          if (data.containsKey('data') && data['data'] is Map) {
            createdSale = Map<String, dynamic>.from(data['data']);
          } else {
            createdSale = Map<String, dynamic>.from(data);
          }
        }
        lastCreatedSale = {...payload, ...?createdSale};
        _addCreatedSaleToLoadedRange();
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

  Future<List<Map<String, dynamic>>> getSales({
    String? startDate,
    String? endDate,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dioClient.get(
        ApiRoutes.salesUrl,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> salesJson = [];
        if (data is Map) {
          final target = data.containsKey('data') ? data['data'] : data;
          if (target is List) {
            salesJson = target;
          } else if (target is Map && target.containsKey('data')) {
            // Handle paginated response
            salesJson = target['data'];
          }
        } else if (data is List) {
          salesJson = data;
        }

        listSales = salesJson.map((s) => Map<String, dynamic>.from(s)).toList();
        _salesStartDate = startDate;
        _salesEndDate = endDate;
        _hasLoadedSales = true;
        notifyListeners();
        return listSales;
      }
      return [];
    } catch (e) {
      debugPrint('Get sales error: $e');
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _addCreatedSaleToLoadedRange() {
    final sale = lastCreatedSale;
    if (!_hasLoadedSales || sale == null) return;

    final rawDate = (sale['sale_date'] ?? sale['created_at'])?.toString();
    final saleDate = rawDate?.split('T').first;
    if (saleDate == null || saleDate.isEmpty) return;
    if (_salesStartDate != null && saleDate.compareTo(_salesStartDate!) < 0) {
      return;
    }
    if (_salesEndDate != null && saleDate.compareTo(_salesEndDate!) > 0) {
      return;
    }

    final createdId = sale['id'];
    if (createdId != null) {
      listSales.removeWhere((entry) => entry['id'] == createdId);
    }
    listSales.insert(0, Map<String, dynamic>.from(sale));
  }

  Future<List<Map<String, dynamic>>> getShopCreditSales(int shopId) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _dioClient.get(
        '${ApiRoutes.shopCreditSalesUrl}/$shopId/credit-sales',
      );
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
      final response = await _dioClient.get(
        ApiRoutes.dailySettlementUrl,
        queryParameters: {
          'live': true,
          'date': DateTime.now().toIso8601String().split('T').first,
        },
      );
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

  Future<Map<String, dynamic>?> submitDailySettlement(
    Map<String, dynamic> payload,
  ) async {
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
      debugPrint('Submit daily settlement error: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getDailySettlementHistory() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _dioClient.get(
        ApiRoutes.dailySettlementHistoryUrl,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> listData = [];
        if (data is Map) {
          final target = data.containsKey('data') ? data['data'] : data;
          if (target is List) {
            listData = target;
          } else if (target is Map &&
              target.containsKey('data') &&
              target['data'] is List) {
            listData = target['data'];
          }
        } else if (data is List) {
          listData = data;
        }

        return listData.map((s) => Map<String, dynamic>.from(s)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get daily settlement history error: $e');
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
