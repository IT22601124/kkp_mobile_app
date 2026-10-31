class ApiRoutes {
  static const String notificationsUrl = 'mobile/notifications';
  // static const String baseUrl = 'https://api.sundarambrothers.com/api/v1/';
  static const String baseUrl =
      'http://172.27.208.1:8000/api/v1/'; // Use http://10.0.2.2:8000 for Android Emulator, or your local IP for physical device
  static const String loginUrl = 'mobile/rep/login';
  static const String checkTokenUrl = 'mobile/rep/check-token';
  static const String logoutUrl = 'mobile/rep/logout';
  static const String updateFcmTokenUrl = 'mobile/rep/fcm-token';
  static const String uploadAvatarUrl = 'mobile/rep/avatar';
  static const String repMeUrl = 'mobile/rep/me';
  static const String CHECKHEALTH = 'mobile/rep/health';
  static const String createShopUrl = 'mobile/shops';
  static const String getMyShopsUrl = 'mobile/my-shops';
  static const String shopsCreatedByUrl = 'shops/created-by';
  static const String deleteShopUrl = 'mobile/shops';
  static const String getItemsUrl = 'mobile/items';
  static const String repStocksUrl = 'rep-stocks/rep';
  static const String routesUrl = 'routes';
  static const String shopsByRouteUrl = 'shops/route';
  static const String todayVisitedShopsUrl = 'mobile/shops/today-visited';
  static const String creditShopsUrl = 'mobile/shops/credit';
  static const String settleCreditUrl = 'mobile/shops';
  static const String shopCreditSalesUrl = 'mobile/shops';
  static const String dailySettlementUrl = 'mobile/daily-settlement';
  static const String dailySettlementHistoryUrl =
      'mobile/daily-settlement/history';
  static const String mobileTargetUrl = 'mobile/target';
  static const String salesUrl = 'sales';
  static const String stockRequestsUrl = 'mobile/stock-requests';
  static const String activeBankAccountsUrl = 'mobile/bank-accounts/active';
}
