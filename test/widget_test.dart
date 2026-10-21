import 'package:flutter_test/flutter_test.dart';
import 'package:kkp_rep_mobile_app/resources/api_routes.dart';

void main() {
  test('mobile sales use the authenticated rep endpoint', () {
    expect(ApiRoutes.salesUrl, 'mobile/sales');
    expect(Uri.parse(ApiRoutes.baseUrl).path, endsWith('/api/v1/'));
  });
}
