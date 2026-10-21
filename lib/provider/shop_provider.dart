import 'session_notifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kkp_rep_mobile_app/dio/dio_client.dart';
import 'package:kkp_rep_mobile_app/models/route_model.dart';
import 'package:kkp_rep_mobile_app/models/shop_model.dart';
import 'package:kkp_rep_mobile_app/resources/api_routes.dart';

class ShopProvider extends SessionNotifier {
  bool isLoading = false;
  String? routeErrorMessage;
  final DioClient _dioClient = DioClient();
  List<ShopModel> listShops = [];
  List<ShopModel> todayVisitedShops = [];
  List<ShopModel> creditShops = [];
  List<RouteModel> listRoutes = [];
  bool _hasLoadedRouteShops = false;
  bool _hasLoadedTodayVisitedShops = false;
  String? _visitedShopsDate;

  bool get hasLoadedRouteShops => _hasLoadedRouteShops;
  bool get hasLoadedTodayVisitedShops =>
      _hasLoadedTodayVisitedShops && _visitedShopsDate == _todayKey;

  String get _todayKey {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).toIso8601String().split('T').first;
  }

  Future<List<ShopModel>> loadRouteShopsIfNeeded({int? routeId}) {
    if (_hasLoadedRouteShops && routeId == null) {
      return Future.value(listShops);
    }
    return getShopsByRoute(routeId: routeId);
  }

  Future<List<ShopModel>> loadTodayVisitedShopsIfNeeded() {
    if (hasLoadedTodayVisitedShops) {
      return Future.value(todayVisitedShops);
    }
    return getTodayVisitedShops();
  }

  Future<ShopModel?> createShop({
    required String shopName,
    required String ownerName,
    required String phone,
    required String address,
    required int routeId,
    required double latitude,
    required double longitude,
    required double creditLimit,
    double currentCreditBalance = 0.0,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _dioClient.post(
        ApiRoutes.createShopUrl,
        data: {
          "shop_name": shopName,
          "owner_name": ownerName,
          "phone": phone,
          "address": address,
          "route_id": routeId,
          "latitude": latitude,
          "longitude": longitude,
          "credit_limit": creditLimit,
          "current_credit_balance": currentCreditBalance,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        ShopModel? newShop;
        if (data is Map) {
          if (data.containsKey('data') && data['data'] is Map) {
            newShop = ShopModel.fromJson(data['data']);
          } else {
            newShop = ShopModel.fromJson(Map<String, dynamic>.from(data));
          }
        }

        if (newShop != null) {
          listShops.insert(0, newShop);
          notifyListeners();
          return newShop;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Create shop error: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<ShopModel?> updateShop({
    required int shopId,
    required String shopName,
    required String ownerName,
    required String phone,
    required String address,
    required int routeId,
    required double latitude,
    required double longitude,
    required double creditLimit,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _dioClient.put(
        '${ApiRoutes.createShopUrl}/$shopId',
        data: {
          "shop_name": shopName,
          "owner_name": ownerName,
          "phone": phone,
          "address": address,
          "route_id": routeId,
          "latitude": latitude,
          "longitude": longitude,
          "credit_limit": creditLimit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        ShopModel? updatedShop;
        if (data is Map) {
          if (data.containsKey('data') && data['data'] is Map) {
            updatedShop = ShopModel.fromJson(data['data']);
          } else {
            updatedShop = ShopModel.fromJson(Map<String, dynamic>.from(data));
          }
        }

        if (updatedShop != null) {
          final index = listShops.indexWhere((s) => s.id == shopId);
          if (index != -1) {
            listShops[index] = updatedShop;
          }
          notifyListeners();
          return updatedShop;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Update shop error: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ShopModel>> getTodayVisitedShops() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _dioClient.get(ApiRoutes.todayVisitedShopsUrl);

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> shopsJson = [];

        if (data is Map) {
          final target = data.containsKey('data') ? data['data'] : data;
          if (target is List) {
            shopsJson = target;
          }
        } else if (data is List) {
          shopsJson = data;
        }

        todayVisitedShops = shopsJson
            .map((json) => ShopModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        _hasLoadedTodayVisitedShops = true;
        _visitedShopsDate = _todayKey;

        debugPrint('Fetched ${todayVisitedShops.length} today visited shops');
        notifyListeners();
        return todayVisitedShops;
      }
      return todayVisitedShops;
    } catch (e) {
      debugPrint('Error fetching today visited shops: $e');
      return todayVisitedShops;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ShopModel>> getCreditShops() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _dioClient.get(ApiRoutes.creditShopsUrl);

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> shopsJson = [];

        if (data is Map) {
          final target = data.containsKey('data') ? data['data'] : data;
          if (target is List) {
            shopsJson = target;
          }
        } else if (data is List) {
          shopsJson = data;
        }

        creditShops = shopsJson
            .map((json) => ShopModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        debugPrint('Fetched ${creditShops.length} credit shops');
        notifyListeners();
        return creditShops;
      }
      return creditShops;
    } catch (e) {
      debugPrint('Error fetching credit shops: $e');
      return creditShops;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> settleCredit({
    required int shopId,
    required double amount,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _dioClient.post(
        '${ApiRoutes.settleCreditUrl}/$shopId/settle-credit',
        data: {'amount': amount},
      );

      if (response.statusCode == 200) {
        await getCreditShops();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Settle credit error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ShopModel>> getShopsByRoute({int? routeId}) async {
    isLoading = true;
    routeErrorMessage = null;
    notifyListeners();
    try {
      final response = await _dioClient.get(
        ApiRoutes.shopsByRouteUrl,
        queryParameters: routeId != null ? {'route_id': routeId} : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> shopsJson = [];

        if (data is Map) {
          final target = data.containsKey('data') ? data['data'] : data;
          if (target is List) {
            shopsJson = target;
          } else if (target is Map) {
            if (target.containsKey('shops') && target['shops'] is List) {
              shopsJson = target['shops'];
            } else if (target.isNotEmpty &&
                (target.containsKey('id') ||
                    target.containsKey('shop_name') ||
                    target.containsKey('shop_code') ||
                    target.containsKey('shopName'))) {
              shopsJson = [target];
            }
          }
        } else if (data is List) {
          shopsJson = data;
        }

        listShops = shopsJson
            .map((json) => ShopModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        _hasLoadedRouteShops = routeId == null;

        notifyListeners();
        return listShops;
      }
      return listShops;
    } on DioException catch (e) {
      final resData = e.response?.data;
      if (e.response?.statusCode == 422 ||
          (resData is Map &&
              (resData['message']?.toString().contains('assigned route') ??
                  false))) {
        routeErrorMessage =
            'You are not assigned to a route, please contact admin';
        debugPrint('Route error: $routeErrorMessage');
        throw Exception(
          'You are not assigned to a route, please contact admin',
        );
      }
      debugPrint('Error fetching shops by route: $e');
      return listShops;
    } catch (e) {
      debugPrint('Error fetching shops by route: $e');
      return listShops;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ShopModel>> getMyShops({int? routeId}) async {
    return await getShopsByRoute(routeId: routeId);
  }

  Future<List<RouteModel>> getRoutes() async {
    try {
      final response = await _dioClient.get(ApiRoutes.routesUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> routesJson = [];

        if (data is List) {
          routesJson = data;
        } else if (data is Map) {
          if (data.containsKey('data') && data['data'] is List) {
            routesJson = data['data'];
          } else if (data.containsKey('routes') && data['routes'] is List) {
            routesJson = data['routes'];
          }
        }

        listRoutes = routesJson
            .map((json) => RouteModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        debugPrint('Fetched ${listRoutes.length} routes from API');
        notifyListeners();
        return listRoutes;
      }
      return listRoutes;
    } catch (e) {
      debugPrint('Error fetching routes: $e');
      return listRoutes;
    }
  }

  Future<bool> deleteShop(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _dioClient.delete(
        '${ApiRoutes.deleteShopUrl}/$id',
      );

      if (response.statusCode == 200) {
        listShops.removeWhere((shop) => shop.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Delete shop error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
