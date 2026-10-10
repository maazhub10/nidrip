// To parse this JSON data, do
//
//     final getProductsBySubCateforyIdModel = getProductsBySubCateforyIdModelFromJson(jsonString);

import 'dart:convert';

GetProductsBySubCateforyIdModel getProductsBySubCateforyIdModelFromJson(
  String str,
) => GetProductsBySubCateforyIdModel.fromJson(json.decode(str));

String getProductsBySubCateforyIdModelToJson(
  GetProductsBySubCateforyIdModel data,
) => json.encode(data.toJson());

class GetProductsBySubCateforyIdModel {
  int? status;
  String? message;
  List<SubCategoryProductData>? data;

  GetProductsBySubCateforyIdModel({this.status, this.message, this.data});

  factory GetProductsBySubCateforyIdModel.fromJson(Map<String, dynamic> json) =>
      GetProductsBySubCateforyIdModel(
        status: json["status"],
        message: json["message"],
        data:
            json["data"] == null
                ? []
                : List<SubCategoryProductData>.from(json["data"]!.map((x) => SubCategoryProductData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class SubCategoryProductData {
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

  SubCategoryProductData({
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

  factory SubCategoryProductData.fromJson(Map<String, dynamic> json) => SubCategoryProductData(
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
