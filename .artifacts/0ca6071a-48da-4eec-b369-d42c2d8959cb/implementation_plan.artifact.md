# Implementation Plan - Create `ItemProvider` to Fetch Items

This plan details the creation of `ItemModel` and `ItemProvider` to handle fetching and managing inventory/product item data from the backend API, and integrating `ItemProvider` into the application state.

## Proposed Changes

### 1. Data Model
#### [NEW] [item_model.dart](file:///F:/kkp_rep_mobile_app/lib/models/item_model.dart)
- Create `ItemModel` class with fields:
  - `id` (`int`)
  - `itemCode` (`String`)
  - `itemName` (`String`)
  - `category` (`String`)
  - `unitPrice` (`double`)
  - `stock` (`int`)
  - `unit` (`String`)
- Implement `fromJson` factory with flexible key mapping (`item_code`/`code`, `item_name`/`name`/`title`, `unit_price`/`price`, `stock`/`van_stock`/`quantity`).
- Implement `toJson` method.

---

### 2. API Routes
#### [MODIFY] [api_routes.dart](file:///F:/kkp_rep_mobile_app/lib/resources/api_routes.dart)
- Add `getItemsUrl` endpoint constant (e.g. `'mobile/items'`).

---

### 3. State Management
#### [NEW/MODIFY] [item_provider.dart](file:///F:/kkp_rep_mobile_app/lib/provider/item_provider.dart)
- Inherit from `ChangeNotifier`.
- Properties:
  - `bool isLoading`
  - `List<ItemModel> listItems`
- Methods:
  - `Future<List<ItemModel>> getItems()`: Fetches item list from `ApiRoutes.getItemsUrl` using `DioClient`. Flexible JSON response handling (Direct List, `data` Map, `data['items']`, or `data['products']`). Updates `listItems` and calls `notifyListeners()`.
  - `loadMockItems()`: Fallback method to populate sample inventory items if offline or backend is unavailable.

---

### 4. Application Root
#### [MODIFY] [main.dart](file:///F:/kkp_rep_mobile_app/lib/main.dart)
- Register `ChangeNotifierProvider(create: (_) => ItemProvider())` inside `MultiProvider`.

---

### 5. UI Integration
#### [MODIFY] [invoice_creation_screen.dart](file:///F:/kkp_rep_mobile_app/lib/screens/invoice_creation_screen.dart)
- Use `Consumer<ItemProvider>` or `ItemProvider` instance to load and display product items dynamically in the POS catalog.

## Verification Plan

### Automated Verification
- Run static analyzer (`analyze_file`) on all created and updated files to ensure no compilation or lint errors.

### Manual Verification
- Launch the app, navigate to `InvoiceCreationScreen` or trigger `getItems()`.
- Verify item list fetches successfully and updates `listItems`.
- Verify fallback/mock data loads properly when offline.
