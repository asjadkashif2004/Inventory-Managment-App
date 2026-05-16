class Item {
  const Item({
    required this.id,
    required this.userId,
    required this.itemCode,
    required this.name,
    required this.quantity,
    required this.price,
    required this.createdAt,
  });

  /// Database UUID (read-only after create).
  final String id;
  final String userId;
  /// User-defined item / SKU id.
  final String itemCode;
  final String name;
  final int quantity;
  final double price;
  final DateTime createdAt;

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      itemCode: json['item_code'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
