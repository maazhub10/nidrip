// To parse this JSON data, do
//
//     final getListAddressModel = getListAddressModelFromJson(jsonString);

import 'dart:convert';

GetListAddressModel getListAddressModelFromJson(String str) =>
    GetListAddressModel.fromJson(json.decode(str));

String getListAddressModelToJson(GetListAddressModel data) =>
    json.encode(data.toJson());

class GetListAddressModel {
  bool? success;
  List<Address>? addresses;

  GetListAddressModel({this.success, this.addresses});

  factory GetListAddressModel.fromJson(Map<String, dynamic> json) =>
      GetListAddressModel(
        success: json["success"],
        addresses:
            json["addresses"] == null
                ? []
                : List<Address>.from(
                  json["addresses"]!.map((x) => Address.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "addresses":
        addresses == null
            ? []
            : List<dynamic>.from(addresses!.map((x) => x.toJson())),
  };
}

class Address {
  String? id;
  String? user;
  String? fullName;
  String? phone;
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? state;
  String? postalCode;
  String? country;
  bool? isDefault;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Address({
    this.id,
    this.user,
    this.fullName,
    this.phone,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json["_id"],
    user: json["user"],
    fullName: json["fullName"],
    phone: json["phone"],
    addressLine1: json["addressLine1"],
    addressLine2: json["addressLine2"],
    city: json["city"],
    state: json["state"],
    postalCode: json["postalCode"],
    country: json["country"],
    isDefault: json["isDefault"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": user,
    "fullName": fullName,
    "phone": phone,
    "addressLine1": addressLine1,
    "addressLine2": addressLine2,
    "city": city,
    "state": state,
    "postalCode": postalCode,
    "country": country,
    "isDefault": isDefault,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}
