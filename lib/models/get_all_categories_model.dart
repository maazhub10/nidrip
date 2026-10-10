// To parse this JSON data, do
//
//     final getAllCategoriesModel = getAllCategoriesModelFromJson(jsonString);

import 'dart:convert';

GetAllCategoriesModel getAllCategoriesModelFromJson(String str) =>
    GetAllCategoriesModel.fromJson(json.decode(str));

String getAllCategoriesModelToJson(GetAllCategoriesModel data) =>
    json.encode(data.toJson());

class GetAllCategoriesModel {
  int? status;
  String? message;
  List<Datum>? data;

  GetAllCategoriesModel({this.status, this.message, this.data});

  factory GetAllCategoriesModel.fromJson(Map<String, dynamic> json) =>
      GetAllCategoriesModel(
        status: json["status"],
        message: json["message"],
        data:
            json["data"] == null
                ? []
                : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? id;
  String? name;
  String? slug;
  String? image;

  Datum({this.id, this.name, this.slug, this.image});

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
