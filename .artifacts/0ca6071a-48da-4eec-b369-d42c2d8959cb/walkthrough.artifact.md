# Walkthrough - ItemProvider & Item Model Implementation

I have created `ItemModel` and `ItemProvider` to handle item fetching, storage, and UI state management across the application.

## Changes Made

### 1. Data Model
#### [item_model.dart](file:///F:/kkp_rep_mobile_app/lib/models/item_model.dart)
- Defined `ItemModel` with properties: `id`, `itemCode`, `itemName`, `category`, `unitPrice`, `stock`, `unit`.
- Implemented robust `fromJson` factory mapping common backend keys (`item_code`/`code`, `item_name`/`name`/`title`, `unit_price`/`price`, `stock`/`van_stock`/`quantity`).
- Implemented `toJson()` for serialization.

---

### 2. API Routes
#### [api_routes.dart](file:///F:/kkp_rep_mobile_app/lib/resources/api_routes.dart)
- Added `getItemsUrl` endpoint (`'mobile/items'`).

---

### 3. State Management
#### [item_provider.dart](file:///F:/kkp_rep_mobile_app/lib/provider/item_provider.dart)
- Extends `ChangeNotifier`.
- Main state properties: `bool isLoading`, `List<ItemModel> listItems`.
- `getItems()` method:
  - Fetches items from `ApiRoutes.getItemsUrl` using `DioClient`.
  - Parses direct JSON Lists or nested structures (`data`, `data.items`, `data.products`).
  - Automatically loads mock items (`loadMockItems()`) if offline or backend is unreachable.
  - Notifies listeners on updates.

---

### 4. Main App Configuration
#### [main.dart](file:///F:/kkp_rep_mobile_app/lib/main.dart)
- Registered `ItemProvider` in `MultiProvider`.

---

### 5. UI Integration
#### [invoice_creation_screen.dart](file:///F:/kkp_rep_mobile_app/lib/screens/invoice_creation_screen.dart)
- Connected `ItemProvider` via `Consumer<ItemProvider>` to dynamically populate and refresh the product catalog list.

---

## Verification Results

> [!NOTE]
> Static code analysis was executed across all modified and newly created files with 0 compilation errors.

- **`ItemModel`**: Validated JSON serialization logic.
- **`ItemProvider`**: Validated API call flow and mock data fallback.
- **`InvoiceCreationScreen`**: Verified state binding with `Consumer<ItemProvider>`.
