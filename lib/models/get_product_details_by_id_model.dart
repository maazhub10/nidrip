// To parse this JSON data, do
//
//     final getProductsDetailsByIdModel = getProductsDetailsByIdModelFromJson(jsonString);

import 'dart:convert';

GetProductsDetailsByIdModel getProductsDetailsByIdModelFromJson(String str) =>
    GetProductsDetailsByIdModel.fromJson(json.decode(str));

String getProductsDetailsByIdModelToJson(GetProductsDetailsByIdModel data) =>
    json.encode(data.toJson());

class GetProductsDetailsByIdModel {
  int? status;
  String? message;
  ProductDetailsData? data;

  GetProductsDetailsByIdModel({this.status, this.message, this.data});

  factory GetProductsDetailsByIdModel.fromJson(Map<String, dynamic> json) =>
      GetProductsDetailsByIdModel(
        status: json["status"],
        message: json["message"],
        data:
            json["data"] == null
                ? null
                : ProductDetailsData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class ProductDetailsData {
  String? id;
  String? name;
  String? category;
  String? subCategory;
  num? price;
  String? image;
  String? description;
  double? rating;
  String? categoryId;
  String? subCategoryId;
  DateTime? createdAt;
  DateTime? updatedAt;

  ProductDetailsData({
    // ✅ Fixed: was incorrectly named "Data"
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
    this.createdAt,
    this.updatedAt,
  });

  factory ProductDetailsData.fromJson(
    Map<String, dynamic> json,
  ) => ProductDetailsData(
    id: json["id"],
    name: json["name"],
    category: json["category"],
    subCategory: json["subCategory"],
    price: json["price"] as num?,
    image: json["image"],
    description: json["description"],
    rating: json["rating"]?.toDouble(),
    categoryId: json["categoryId"],
    subCategoryId: json["subCategoryId"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
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
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
