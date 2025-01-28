class CartItem {
  String id;
  String itemID;
  String userID;
  String type;
  String name;
  double price;
  int quantity;
  double total;
  String imageUrl;

  CartItem(
      {required this.id,
      required this.itemID,
      required this.userID,
      required this.type,
      required this.name,
      required this.price,
      required this.quantity,
      required this.total,
      required this.imageUrl});

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'name': name,
  //     'quantity': quantity,
  //     'total': total,
  //     'imageUrl': imageUrl,
  //   };
  // }

  // static fromMap(item) {}

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      itemID: map['itemID'] ?? '',
      userID: map['userID'] ?? '',
      type: map['type'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      total: (map['total'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemID': itemID,
      'userID': userID,
      'type': type,
      'name': name,
      'price': price,
      'quantity': quantity,
      'total': total,
      'imageUrl': imageUrl,
    };
  }
}
