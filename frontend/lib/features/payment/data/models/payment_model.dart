class PaymentMethodModel {
  final String method;
  final String accountNumber;
  final String accountName;

  const PaymentMethodModel({
    required this.method, required this.accountNumber, required this.accountName,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) => PaymentMethodModel(
        method: json['method'] as String,
        accountNumber: json['accountNumber'] as String,
        accountName: json['accountName'] as String,
      );

  String get displayName => method == 'JAZZCASH' ? 'JazzCash' : 'EasyPaisa';
}
