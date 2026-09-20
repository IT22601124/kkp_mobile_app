enum OutletStatus { pending, visited, invoiced, skipped }
enum PaymentStatus { pending, paid, partial }
enum RequisitionStatus { pending, approved, issued, rejected }

class Outlet {
  final int id;
  final String shopName;
  final String ownerName;
  final String phone;
  final String address;
  final String routeName;
  final String category;
  OutletStatus status;
  final double outstandingBalance;

  Outlet({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.address,
    required this.routeName,
    required this.category,
    this.status = OutletStatus.pending,
    this.outstandingBalance = 0.0,
  });
}

class InventoryItem {
  final int id;
  final String itemCode;
  final String name;
  final String category;
  final double unitPrice;
  int vanStock;
  final int warehouseStock;

  InventoryItem({
    required this.id,
    required this.itemCode,
    required this.name,
    required this.category,
    required this.unitPrice,
    required this.vanStock,
    required this.warehouseStock,
  });
}

class InvoiceItemLine {
  final InventoryItem item;
  int quantity;
  double discountPercent;

  InvoiceItemLine({
    required this.item,
    required this.quantity,
    this.discountPercent = 0.0,
  });

  double get lineSubtotal => item.unitPrice * quantity;
  double get discountAmount => lineSubtotal * (discountPercent / 100);
  double get lineTotal => lineSubtotal - discountAmount;
}

class Invoice {
  final String invoiceNo;
  final String shopName;
  final DateTime dateTime;
  final List<InvoiceItemLine> items;
  final double subtotal;
  final double discountAmount;
  final double grandTotal;
  PaymentStatus paymentStatus;

  Invoice({
    required this.invoiceNo,
    required this.shopName,
    required this.dateTime,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.grandTotal,
    this.paymentStatus = PaymentStatus.pending,
  });
}

class RequisitionLine {
  final InventoryItem item;
  int requestedQty;

  RequisitionLine({
    required this.item,
    required this.requestedQty,
  });
}

class StockRequisition {
  final String reqNo;
  final DateTime date;
  final List<RequisitionLine> items;
  RequisitionStatus status;

  StockRequisition({
    required this.reqNo,
    required this.date,
    required this.items,
    this.status = RequisitionStatus.pending,
  });
}

class CashSheetSummary {
  final DateTime date;
  final double totalSales;
  final double cashCollected;
  final double chequeCollected;
  final double creditIssued;
  double physicalCashCount;
  bool isFinalized;

  CashSheetSummary({
    required this.date,
    required this.totalSales,
    required this.cashCollected,
    required this.chequeCollected,
    required this.creditIssued,
    this.physicalCashCount = 0.0,
    this.isFinalized = false,
  });

  double get cashVariance => physicalCashCount - cashCollected;
}

class DsrRepProfile {
  final String repCode;
  final String name;
  final String phone;
  final String branchName;
  final String activeRoute;

  DsrRepProfile({
    required this.repCode,
    required this.name,
    required this.phone,
    required this.branchName,
    required this.activeRoute,
  });
}
