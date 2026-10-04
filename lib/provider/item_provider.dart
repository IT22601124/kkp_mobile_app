import 'package:flutter/material.dart';
import 'package:kkp_rep_mobile_app/dio/dio_client.dart';
import 'package:kkp_rep_mobile_app/models/branch_stock_model.dart';
import 'package:kkp_rep_mobile_app/models/item_model.dart';
import 'package:kkp_rep_mobile_app/models/rep_stock_model.dart';
import 'package:kkp_rep_mobile_app/resources/api_routes.dart';

class ItemProvider extends ChangeNotifier {
  bool isLoading = false;
  final DioClient _dioClient = DioClient();
  List<ItemModel> listItems = [];
  List<RepStockModel> listRepStocks = [];
  List<dynamic> listStockRequests = [];
  List<BranchStockModel> listBranchStocks = [];

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
    listItems = [];
    notifyListeners();
  }

  Future<List<RepStockModel>> getRepStocks(int repId) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _dioClient.get('${ApiRoutes.repStocksUrl}/$repId');
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> listData = [];
        if (data is Map && data.containsKey('data') && data['data'] is List) {
          listData = data['data'];
        } else if (data is List) {
          listData = data;
        }

        List<RepStockModel> parsedStocks = [];
        for (var stockGroup in listData) {
          if (stockGroup is Map) {
            final groupMap = Map<String, dynamic>.from(stockGroup);
            final parentStatus = groupMap['status']?.toString() ?? 'ACTIVE';
            final repIdVal = groupMap['rep_id'];
            final branchIdVal = groupMap['branch_id'];

            if (groupMap.containsKey('items') && groupMap['items'] is List) {
              for (var itemEntry in (groupMap['items'] as List)) {
                if (itemEntry is Map) {
                  final itemMap = Map<String, dynamic>.from(itemEntry);
                  itemMap['rep_id'] = itemMap['rep_id'] ?? repIdVal;
                  itemMap['branch_id'] = itemMap['branch_id'] ?? branchIdVal;
                  itemMap['status'] = itemMap['status'] ?? parentStatus;
                  itemMap['id'] = itemMap['id'] ?? groupMap['id'];
                  parsedStocks.add(RepStockModel.fromJson(itemMap));
                }
              }
            } else {
              parsedStocks.add(RepStockModel.fromJson(groupMap));
            }
          }
        }

        listRepStocks = parsedStocks;
        debugPrint('Fetched ${listRepStocks.length} flattened rep stock items for rep #$repId');
        notifyListeners();
        return listRepStocks;
      }
    } catch (e) {
      debugPrint('Error fetching rep stocks: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return listRepStocks;
  }

  Future<List<dynamic>> getStockRequests() async {
    try {
      final response = await _dioClient.get('stock-requests');
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> listData = [];
        if (data is Map && data.containsKey('data') && data['data'] is List) {
          listData = data['data'];
        } else if (data is List) {
          listData = data;
        }
        listStockRequests = listData;
        notifyListeners();
        return listStockRequests;
      }
    } catch (e) {
      debugPrint('Error fetching stock requests: $e');
    }
    return listStockRequests;
  }

  Future<List<BranchStockModel>> getBranchStocks() async {
    try {
      final response = await _dioClient.get('stocks/branch');
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> listData = [];
        if (data is Map && data.containsKey('data') && data['data'] is List) {
          listData = data['data'];
        } else if (data is List) {
          listData = data;
        }

        listBranchStocks = listData
            .map((e) => BranchStockModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        notifyListeners();
        return listBranchStocks;
      }
    } catch (e) {
      debugPrint('Error fetching branch stocks: $e');
    }
    return listBranchStocks;
  }
}
