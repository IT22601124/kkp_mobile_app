import 'package:flutter/material.dart';
import 'package:kkp_rep_mobile_app/dio/dio_client.dart';
import 'package:kkp_rep_mobile_app/models/shop_model.dart';
import 'package:kkp_rep_mobile_app/resources/api_routes.dart';

class ShopProvider extends ChangeNotifier {
  bool isLoading = false;
  final DioClient _dioClient = DioClient();
  List<ShopModel> listShops = [];

  Future<ShopModel?> createShop({
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
          listShops.insert(0, newShop); // Add the new shop to the top of the list
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

  Future<List<ShopModel>> getMyShops() async {
    isLoading = true;
    notifyListeners();
    try {
      dynamic response;
      try {
        response = await _dioClient.get(ApiRoutes.shopsCreatedByUrl);
      } catch (_) {
        throw Exception('No internet connection');
      }

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        List<dynamic> shopsJson = [];

        if (data is List) {
          shopsJson = data;
        } else if (data is Map) {
          if (data.containsKey('data')) {
            final nestedData = data['data'];
            if (nestedData is List) {
              shopsJson = nestedData;
            } else if (nestedData is Map && nestedData.containsKey('shops') && nestedData['shops'] is List) {
              shopsJson = nestedData['shops'];
            }
          } else if (data.containsKey('shops') && data['shops'] is List) {
            shopsJson = data['shops'];
          }
        }
        
        debugPrint('Fetched ${shopsJson.length} shops from API');
        
        listShops = shopsJson
            .map((json) => ShopModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        
        notifyListeners();
        return listShops;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching shops: $e');
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteShop(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _dioClient.delete('${ApiRoutes.deleteShopUrl}/$id');
      
      if (response.statusCode == 200) {
        // Remove from local list
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
