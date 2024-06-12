import 'dart:convert';

class User {
  String name;
  String email;
  String password;
  String confirmPassword;
  String birthdate;
  bool isAgreed;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.birthdate,
    required this.isAgreed,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      confirmPassword: json['confirmPassword'],
      birthdate: json['birthdate'],
      isAgreed: json['isAgreed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'birthdate': birthdate,
      'isAgreed': isAgreed,
    };
  }
}
