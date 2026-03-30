class QuoteModel {
  final String id;
  final String quoteId;
  final String product;
  final int quantity;
  final String status;
  final String? adminResponse;
  final double? estimatedPrice;
  final DateTime createdAt;

  const QuoteModel({
    required this.id, required this.quoteId, required this.product,
    required this.quantity, required this.status,
    this.adminResponse, this.estimatedPrice, required this.createdAt,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) => QuoteModel(
        id: json['id'] as String,
        quoteId: json['quoteId'] as String,
        product: json['product'] as String,
        quantity: (json['quantity'] as num).toInt(),
        status: json['status'] as String,
        adminResponse: json['adminResponse'] as String?,
        estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
