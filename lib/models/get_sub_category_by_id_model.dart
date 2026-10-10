// To parse this JSON data, do
//
//     final getSubCategoryByIdModel = getSubCategoryByIdModelFromJson(jsonString);

import 'dart:convert';

GetSubCategoryByIdModel getSubCategoryByIdModelFromJson(String str) =>
    GetSubCategoryByIdModel.fromJson(json.decode(str));

String getSubCategoryByIdModelToJson(GetSubCategoryByIdModel data) =>
    json.encode(data.toJson());

class GetSubCategoryByIdModel {
  int? status;
  String? message;
  Data? data;

  GetSubCategoryByIdModel({this.status, this.message, this.data});

  factory GetSubCategoryByIdModel.fromJson(Map<String, dynamic> json) =>
      GetSubCategoryByIdModel(
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
  SubCategoryData? category;
  List<SubCategoryData>? subCategories;

  Data({this.category, this.subCategories});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    category:
        json["category"] == null ? null : SubCategoryData.fromJson(json["category"]),
    subCategories:
        json["subCategories"] == null
            ? []
            : List<SubCategoryData>.from(
              json["subCategories"]!.map((x) => SubCategoryData.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "category": category?.toJson(),
    "subCategories":
        subCategories == null
            ? []
            : List<dynamic>.from(subCategories!.map((x) => x.toJson())),
  };
}

class SubCategoryData {
  String? id;
  String? name;
  String? slug;
  String? image;

  SubCategoryData({this.id, this.name, this.slug, this.image});

  factory SubCategoryData.fromJson(Map<String, dynamic> json) => SubCategoryData(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "image": image,
  };
}
