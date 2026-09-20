# Implementation Plan - Add Delete Shop Functionality

The goal is to implement the ability to delete a shop from the mobile app, including API integration, state management, and UI updates.

## Proposed Changes

### [Resources](file:///F:/kkp_rep_mobile_app/lib/resources/api_routes.dart)

#### [MODIFY] [api_routes.dart](file:///F:/kkp_rep_mobile_app/lib/resources/api_routes.dart)
- Add `deleteShopUrl` constant.

### [Provider](file:///F:/kkp_rep_mobile_app/lib/provider/shop_provider.dart)

#### [MODIFY] [shop_provider.dart](file:///F:/kkp_rep_mobile_app/lib/provider/shop_provider.dart)
- Implement `deleteShop(int id)` method using `_dioClient.delete`.
- On success, remove the shop from the local `listShops` and call `notifyListeners()`.

### [UI Screens](file:///F:/kkp_rep_mobile_app/lib/screens/all_shops_screen.dart)

#### [MODIFY] [all_shops_screen.dart](file:///F:/kkp_rep_mobile_app/lib/screens/all_shops_screen.dart)
- Add a delete icon button to each shop item card.
- Implement a confirmation dialog (`showDialog`) to prevent accidental deletions.
- Handle the loading state and show appropriate feedback (Snackbar) after deletion.

## Verification Plan

### Automated Tests
- N/A (Manual verification prioritized)

### Manual Verification
- **Test Deletion**: Tap the delete icon on a shop, confirm the dialog, and verify the shop is removed from the list and the API call is successful.
- **Cancel Deletion**: Tap delete, then cancel in the dialog, and verify the shop remains in the list.
- **Error Handling**: Simulate a network error and verify the app shows an error message and keeps the shop in the list.
