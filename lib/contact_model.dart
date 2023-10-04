// To parse this JSON data, do
//
//     final contactModel = contactModelFromJson(jsonString);

import 'dart:convert';

List<ContactModel> contactModelFromJson(String str) => List<ContactModel>.from(json.decode(str).map((x) => ContactModel.fromJson(x)));

String contactModelToJson(List<ContactModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ContactModel {
  String? id;
  String? firstName;
  String? lastName;
  String? contact;
  bool? invited;

  ContactModel({
    this.id,
    this.firstName,
    this.lastName,
    this.contact,
    this.invited,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    contact: json["contact"],
    invited: json["invited"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "contact": contact,
    "invited": invited,
  };
}
