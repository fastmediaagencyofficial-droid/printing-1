class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final Map<String, dynamic>? customSpecs;
  final String? note;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.customSpecs,
    this.note,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        id: json['id'] as String,
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        quantity: (json['quantity'] as num).toInt(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        customSpecs: json['customSpecs'] as Map<String, dynamic>?,
        note: json['note'] as String?,
      );

  CartItemModel copyWith({int? quantity, double? totalPrice}) => CartItemModel(
        id: id,
        productId: productId,
        productName: productName,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice,
        totalPrice: totalPrice ?? this.totalPrice,
        customSpecs: customSpecs,
        note: note,
      );
}

class CartModel {
  final List<CartItemModel> items;
  final double total;
  final int itemCount;

  const CartModel({required this.items, required this.total, required this.itemCount});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return CartModel(
      items: items,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? items.length,
    );
  }

  static CartModel empty() => const CartModel(items: [], total: 0, itemCount: 0);
}
