import 'package:flutter/material.dart';
import 'package:kkp_rep_mobile_app/dio/dio_client.dart';
import 'package:kkp_rep_mobile_app/models/bank_account_model.dart';
import 'package:kkp_rep_mobile_app/resources/api_routes.dart';

class BankAccountProvider extends ChangeNotifier {
  bool isLoading = false;
  final DioClient _dioClient = DioClient();
  List<BankAccountModel> listBankAccounts = [];
  BankAccountModel? selectedBankAccount;

  BankAccountProvider() {
    // Initialized empty - will load real accounts from backend API
  }

  void selectAccount(BankAccountModel account) {
    selectedBankAccount = account;
    notifyListeners();
  }

  void selectAccountById(int id) {
    try {
      selectedBankAccount = listBankAccounts.firstWhere((b) => b.id == id);
      notifyListeners();
    } catch (_) {}
  }

  Future<List<BankAccountModel>> getBankAccounts() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _dioClient.get(ApiRoutes.activeBankAccountsUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> accountsJson = [];

        if (data is List) {
          accountsJson = data;
        } else if (data is Map) {
          if (data.containsKey('data') && data['data'] is List) {
            accountsJson = data['data'];
          } else if (data.containsKey('accounts') && data['accounts'] is List) {
            accountsJson = data['accounts'];
          }
        }

        if (accountsJson.isNotEmpty) {
          listBankAccounts = accountsJson
              .map((j) => BankAccountModel.fromJson(Map<String, dynamic>.from(j)))
              .toList();

          // Retain selection or select default
          if (selectedBankAccount != null) {
            final match = listBankAccounts.where((b) => b.id == selectedBankAccount!.id);
            if (match.isNotEmpty) {
              selectedBankAccount = match.first;
            } else {
              selectedBankAccount = listBankAccounts.firstWhere(
                (b) => b.isDefault,
                orElse: () => listBankAccounts.first,
              );
            }
          } else {
            selectedBankAccount = listBankAccounts.firstWhere(
              (b) => b.isDefault,
              orElse: () => listBankAccounts.first,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load bank accounts from API, using default 4 accounts: $e');
      // Keep empty if API failed to prevent invalid IDs
      selectedBankAccount = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return listBankAccounts;
  }
}
