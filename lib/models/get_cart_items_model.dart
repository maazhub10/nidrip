// To parse this JSON data, do
//
//     final getCartItemModel = getCartItemModelFromJson(jsonString);

import 'dart:convert';

GetCartItemModel getCartItemModelFromJson(String str) =>
    GetCartItemModel.fromJson(json.decode(str));

String getCartItemModelToJson(GetCartItemModel data) =>
    json.encode(data.toJson());

class GetCartItemModel {
  int? status;
  String? message;
  Data? data;

  GetCartItemModel({this.status, this.message, this.data});

  factory GetCartItemModel.fromJson(Map<String, dynamic> json) =>
      GetCartItemModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  String? id;
  List<Item>? items;
  int? totalItems;
  double? totalPrice;

  Data({this.id, this.items, this.totalItems, this.totalPrice});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    items:
        json["items"] == null
            ? []
            : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    totalItems: json["totalItems"],
    totalPrice: json["totalPrice"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "items":
        items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "totalItems": totalItems,
    "totalPrice": totalPrice,
  };
}

class Item {
  String? id;
  Product? product;
  int? quantity;
  double? price;
  double? subtotal;

  Item({this.id, this.product, this.quantity, this.price, this.subtotal});

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"],
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
    quantity: json["quantity"],
    price: json["price"]?.toDouble(),
    subtotal: json["subtotal"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product": product?.toJson(),
    "quantity": quantity,
    "price": price,
    "subtotal": subtotal,
  };
}

class Product {
  String? id;
  String? name;
  String? category;
  String? subCategory;
  double? price;
  String? image;
  String? description;
  double? rating;
  String? categoryId;
  String? subCategoryId;

  Product({
    this.id,
    this.name,
    this.category,
    this.subCategory,
    this.price,
    this.image,
    this.description,
    this.rating,
    this.categoryId,
    this.subCategoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    name: json["name"],
    category: json["category"],
    subCategory: json["subCategory"],
    price: json["price"]?.toDouble(),
    image: json["image"],
    description: json["description"],
    rating: json["rating"]?.toDouble(),
    categoryId: json["categoryId"],
    subCategoryId: json["subCategoryId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "category": category,
    "subCategory": subCategory,
    "price": price,
    "image": image,
    "description": description,
    "rating": rating,
    "categoryId": categoryId,
    "subCategoryId": subCategoryId,
  };
}
