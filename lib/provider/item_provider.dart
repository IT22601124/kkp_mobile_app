import 'package:flutter/material.dart';
import 'package:kkp_rep_mobile_app/dio/dio_client.dart';
import 'package:kkp_rep_mobile_app/models/item_model.dart';
import 'package:kkp_rep_mobile_app/resources/api_routes.dart';

class ItemProvider extends ChangeNotifier {
  bool isLoading = false;
  final DioClient _dioClient = DioClient();
  List<ItemModel> listItems = [];

  Future<List<ItemModel>> getItems() async {
    isLoading = true;
    notifyListeners();
    try {
      dynamic response;
      try {
        response = await _dioClient.get(ApiRoutes.getItemsUrl);
      } catch (_) {
        debugPrint('Failed to connect to API, fallback to mock data if empty');
      }

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        List<dynamic> itemsJson = [];

        if (data is List) {
          itemsJson = data;
        } else if (data is Map) {
          if (data.containsKey('data')) {
            final nestedData = data['data'];
            if (nestedData is List) {
              itemsJson = nestedData;
            } else if (nestedData is Map && nestedData.containsKey('items') && nestedData['items'] is List) {
              itemsJson = nestedData['items'];
            } else if (nestedData is Map && nestedData.containsKey('products') && nestedData['products'] is List) {
              itemsJson = nestedData['products'];
            }
          } else if (data.containsKey('items') && data['items'] is List) {
            itemsJson = data['items'];
          } else if (data.containsKey('products') && data['products'] is List) {
            itemsJson = data['products'];
          }
        }

        debugPrint('Fetched ${itemsJson.length} items from API');

        listItems = itemsJson
            .map((json) => ItemModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        notifyListeners();
        return listItems;
      }

      if (listItems.isEmpty) {
        loadMockItems();
      }
      return listItems;
    } catch (e) {
      debugPrint('Error fetching items: $e');
      if (listItems.isEmpty) {
        loadMockItems();
      }
      return listItems;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void loadMockItems() {
    listItems = [
      ItemModel(
        id: 1,
        itemCode: 'CARD-100',
        itemName: 'Hutch Rs. 100 Recharge Card',
        category: 'Recharge Cards',
        unitPrice: 96.00,
        stock: 500,
        unit: 'unit',
      ),
      ItemModel(
        id: 2,
        itemCode: 'CARD-500',
        itemName: 'Hutch Rs. 500 Super Card',
        category: 'Recharge Cards',
        unitPrice: 480.00,
        stock: 430,
        unit: 'unit',
      ),
      ItemModel(
        id: 3,
        itemCode: 'SIM-4G',
        itemName: 'Hutch 4G SIM Starter Pack',
        category: 'SIM Packs',
        unitPrice: 250.00,
        stock: 30,
        unit: 'pack',
      ),
    ];
    notifyListeners();
  }
}
