import 'dart:convert';

GetCheckoutSummaryModel getCheckoutSummaryModelFromJson(String str) =>
    GetCheckoutSummaryModel.fromJson(json.decode(str));

String getCheckoutSummaryModelToJson(GetCheckoutSummaryModel data) =>
    json.encode(data.toJson());

class GetCheckoutSummaryModel {
  bool? success;
  Summary? summary;

  GetCheckoutSummaryModel({this.success, this.summary});

  factory GetCheckoutSummaryModel.fromJson(Map<String, dynamic> json) =>
      GetCheckoutSummaryModel(
        success: json["success"],
        summary:
            json["summary"] == null ? null : Summary.fromJson(json["summary"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "summary": summary?.toJson(),
  };
}

class Summary {
  List<Item>? items;
  double? subtotal; // ✅ was int?
  double?
  shippingFee; // ✅ was int? (keep double even if currently whole number)
  double? freeShippingThreshold; // ✅ was int?
  double? total; // ✅ was int?
  String? currency;

  Summary({
    this.items,
    this.subtotal,
    this.shippingFee,
    this.freeShippingThreshold,
    this.total,
    this.currency,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    items:
        json["items"] == null
            ? []
            : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    subtotal: (json["subtotal"] as num?)?.toDouble(), // ✅ safe cast
    shippingFee: (json["shippingFee"] as num?)?.toDouble(), // ✅ safe cast
    freeShippingThreshold:
        (json["freeShippingThreshold"] as num?)?.toDouble(), // ✅ safe cast
    total: (json["total"] as num?)?.toDouble(), // ✅ safe cast
    currency: json["currency"],
  );

  Map<String, dynamic> toJson() => {
    "items":
        items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "subtotal": subtotal,
    "shippingFee": shippingFee,
    "freeShippingThreshold": freeShippingThreshold,
    "total": total,
    "currency": currency,
  };
}

class Item {
  String? cartItemId;
  Product? product;
  int? quantity;
  double? price; // ✅ was int?
  double? lineTotal; // ✅ was int?

  Item({
    this.cartItemId,
    this.product,
    this.quantity,
    this.price,
    this.lineTotal,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    cartItemId: json["cartItemId"],
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
    quantity: json["quantity"],
    price: (json["price"] as num?)?.toDouble(), // ✅ safe cast
    lineTotal: (json["lineTotal"] as num?)?.toDouble(), // ✅ safe cast
  );

  Map<String, dynamic> toJson() => {
    "cartItemId": cartItemId,
    "product": product?.toJson(),
    "quantity": quantity,
    "price": price,
    "lineTotal": lineTotal,
  };
}

class Product {
  String? id;
  String? name;
  double? price; // ✅ was int?
  String? image;

  Product({this.id, this.name, this.price, this.image});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["_id"],
    name: json["name"],
    price: (json["price"] as num?)?.toDouble(), // ✅ safe cast
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "price": price,
    "image": image,
  };
}
