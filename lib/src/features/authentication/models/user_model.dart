import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String phoneNo;
  final String? password;
  final double latitude; // Added latitude property
  final double longitude; // Added longitude property
  final String userName; // Added userName property

  const UserModel({
    this.id,
    required this.email,
    this.password,
    required this.fullName,
    required this.phoneNo,
    required this.latitude,
    required this.longitude,
    required this.userName,
  });

  toJson() {
    return {
      "FullName": fullName,
      "Email": email,
      "Phone": phoneNo,
      "Latitude": latitude,
      "Longitude": longitude,
      "UserName": userName,
    };
  }

  static UserModel empty() => const UserModel(
    id: '',
    email: '',
    fullName: '',
    phoneNo: '',
    latitude: 0,
    longitude: 0,
    userName: '',
  );

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() == null || document.data()!.isEmpty) return UserModel.empty();
    final data = document.data()!;
    return UserModel(
      id: document.id,
      email: data["Email"] ?? '',
      fullName: data["FullName"] ?? '',
      phoneNo: data["Phone"] ?? '',
      latitude: data["Latitude"] ?? 0,
      longitude: data["Longitude"] ?? 0,
      userName: data["UserName"] ?? '',
    );
  }
}
