import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String? phone;
  String? name;
  String? email;
  String? id;
  String? address;

  UserModel({
    this.phone,
    this.name,
    this.email,
    this.id,
    this.address,
  });

  UserModel.fromSnapshot(DataSnapshot snap) {
    phone = (snap.value as dynamic)["phone"];
    name = (snap.value as dynamic)["name"];
    email = (snap.value as dynamic)["email"];
    id = snap.key;
    address = (snap.value as dynamic)["address"];
  }
}
