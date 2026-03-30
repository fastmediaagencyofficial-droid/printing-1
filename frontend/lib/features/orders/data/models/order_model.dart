class OrderItemModel {
  final String id;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItemModel({
    required this.id, required this.productName,
    required this.quantity, required this.unitPrice, required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id: json['id'] as String,
        productName: json['productName'] as String,
        quantity: (json['quantity'] as num).toInt(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
      );
}

class OrderModel {
  final String id;
  final String orderId;
  final String status;
  final double totalAmount;
  final String paymentMethod;
  final String? paymentProofUrl;
  final String? adminNotes;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final String? shippingCity;
  final String? notes;

  const OrderModel({
    required this.id, required this.orderId, required this.status,
    required this.totalAmount, required this.paymentMethod,
    this.paymentProofUrl, this.adminNotes, required this.items,
    required this.createdAt, this.shippingCity, this.notes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        orderId: json['orderId'] as String,
        status: json['status'] as String,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        paymentMethod: json['paymentMethod'] as String,
        paymentProofUrl: json['paymentProofUrl'] as String?,
        adminNotes: json['adminNotes'] as String?,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        shippingCity: json['shippingCity'] as String?,
        notes: json['notes'] as String?,
      );

  bool get canCancel => status == 'PENDING_PAYMENT';
  bool get canUploadProof => status == 'PENDING_PAYMENT' || status == 'PAYMENT_UPLOADED';

  String get statusLabel {
    switch (status) {
      case 'PENDING_PAYMENT': return 'Pending Payment';
      case 'PAYMENT_UPLOADED': return 'Payment Submitted';
      case 'CONFIRMED': return 'Confirmed';
      case 'IN_PRODUCTION': return 'In Production';
      case 'SHIPPED': return 'Shipped';
      case 'DELIVERED': return 'Delivered';
      case 'CANCELLED': return 'Cancelled';
      default: return status;
    }
  }
}
