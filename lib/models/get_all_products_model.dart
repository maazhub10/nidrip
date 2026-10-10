// To parse this JSON data, do
//
//     final getAllProductsModel = getAllProductsModelFromJson(jsonString);

import 'dart:convert';

GetAllProductsModel getAllProductsModelFromJson(String str) =>
    GetAllProductsModel.fromJson(json.decode(str));

String getAllProductsModelToJson(GetAllProductsModel data) =>
    json.encode(data.toJson());

class GetAllProductsModel {
  int? status;
  String? message;
  List<ProductData>? data;

  GetAllProductsModel({this.status, this.message, this.data});

  factory GetAllProductsModel.fromJson(Map<String, dynamic> json) =>
      GetAllProductsModel(
        status: json["status"],
        message: json["message"],
        data:
            json["data"] == null
                ? []
                : List<ProductData>.from(
                  json["data"]!.map((x) => ProductData.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class ProductData {
  String? id;
  String? name;
  String? category;
  String? subCategory;
  num? price; // keeps both int and double prices safe
  String? image;
  String? description;
  double? rating;
  String? categoryId; // nullable — confirmed null in API response

  ProductData({
    this.id,
    this.name,
    this.category,
    this.subCategory,
    this.price,
    this.image,
    this.description,
    this.rating,
    this.categoryId,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) => ProductData(
    id: json["id"],
    name: json["name"],
    category: json["category"],
    subCategory: json["subCategory"],
    price: json["price"],
    image: json["image"],
    description: json["description"],
    rating: json["rating"]?.toDouble(),
    categoryId: json["categoryId"],
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
  };
}
