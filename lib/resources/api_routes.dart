class ApiRoutes {
  static const String baseUrl = 'http://192.168.80.238:8000/api/v1/';

  static const String loginUrl = 'mobile/rep/login';
  static const String checkTokenUrl = 'mobile/rep/check-token';
  static const String logoutUrl = 'mobile/rep/logout';
  static const String CHECKHEALTH = 'mobile/rep/health';
  static const String createShopUrl = 'mobile/shops';
  static const String getMyShopsUrl = 'mobile/my-shops';
  static const String shopsCreatedByUrl = 'shops/created-by';
  static const String deleteShopUrl = 'mobile/shops'; // Usage: deleteShopUrl/$id
  static const String getItemsUrl = 'mobile/items';
  static const String repStocksUrl = 'rep-stocks/rep'; // Usage: repStocksUrl/$repId
}
