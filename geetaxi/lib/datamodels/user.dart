import 'package:firebase_database/firebase_database.dart';

class user{
  String fullName;
  String email;
  String phone;
  String id;

  user({
    this.phone,
    this.email,
    this.fullName,
    this.id,
});

  user.fromSnapshot(DataSnapshot snapshot){
    id = snapshot.key;
    phone = snapshot.value['phone'];
    email = snapshot.value['email'];
    fullName = snapshot.value['fullname'];
  }
}