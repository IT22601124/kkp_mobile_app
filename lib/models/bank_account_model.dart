class BankAccountModel {
  final int id;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String branchName;
  final bool isDefault;
  final double currentBalance;

  BankAccountModel({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.branchName,
    this.isDefault = false,
    this.currentBalance = 0.0,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      bankName: json['bank_name'] ?? json['bankName'] ?? 'Bank',
      accountNumber: json['account_number'] ?? json['accountNumber'] ?? '',
      accountName: json['account_name'] ?? json['accountName'] ?? '',
      branchName: json['branch_name'] ?? json['branchName'] ?? '',
      isDefault: json['is_default'] == true || json['is_default'] == 1 || json['isDefault'] == true,
      currentBalance: json['current_balance'] != null
          ? (double.tryParse(json['current_balance'].toString()) ?? 0.0)
          : (double.tryParse(json['balance']?.toString() ?? '0.0') ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_name': accountName,
      'branch_name': branchName,
      'is_default': isDefault,
      'current_balance': currentBalance,
    };
  }

  /// Default 4 Real Agent Bank Accounts fallback
  static List<BankAccountModel> get defaultAccounts => [
    BankAccountModel(
      id: 34,
      bankName: 'Commercial Bank of Ceylon',
      accountNumber: '1000293847',
      accountName: 'KKP Hutchison Telecommunications Agency - Main',
      branchName: 'Colombo Fort',
      isDefault: true,
      currentBalance: 150000.0,
    ),
    BankAccountModel(
      id: 35,
      bankName: 'Sampath Bank',
      accountNumber: '002910004567',
      accountName: 'KKP Hutchison Agency - Collections',
      branchName: 'City Office Branch',
      isDefault: false,
      currentBalance: 100000.0,
    ),
    BankAccountModel(
      id: 36,
      bankName: 'Bank of Ceylon (BOC)',
      accountNumber: '000876543201',
      accountName: 'KKP Hutchison Agency - Revenue',
      branchName: 'Corporate Branch',
      isDefault: false,
      currentBalance: 75000.0,
    ),
    BankAccountModel(
      id: 38,
      bankName: 'Hatton National Bank (HNB)',
      accountNumber: '009823456789',
      accountName: 'KKP Hutchison Agency - Field Settlement',
      branchName: 'Head Office Branch',
      isDefault: false,
      currentBalance: 50000.0,
    ),
  ];
}
