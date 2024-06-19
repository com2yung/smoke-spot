import 'dart:convert';
import 'review.dart';

class User {
  String name;
  String email;
  String password;
  String confirmPassword;
  String birthdate;
  bool isAgreed;
  List<Review> reviews;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.birthdate,
    required this.isAgreed,
    List<Review>? reviews,
  }) : this.reviews = reviews ?? [];

  factory User.fromJson(Map<String, dynamic> json) {
    var reviewsList = json['reviews'] as List<dynamic>?;

    List<Review>? parsedReviews = [];
    if (reviewsList != null) {
      parsedReviews = reviewsList.map((reviewJson) => Review.fromJson(reviewJson as Map<String, dynamic>)).toList();
      print('Parsed ${parsedReviews.length} reviews');
    }

    return User(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirmPassword'] as String,
      birthdate: json['birthdate'] as String,
      isAgreed: json['isAgreed'] as bool,
      reviews: parsedReviews,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> reviewJson = reviews.map((review) => review.toJson()).toList();
    return {
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'birthdate': birthdate,
      'isAgreed': isAgreed,
      'reviews': reviewJson,
    };
  }

  void fetchReviewsForCurrentUser(List<Review> fetchedReviews) {
    reviews = fetchedReviews;
  }

}