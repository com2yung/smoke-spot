import 'dart:convert';

class SmokeSpot {
  final String address;
  final String addressDetail;
  final String image;
  final double latitude;
  final double longitude;
  final double averageScore;
  final int reviewCount;
  final Details details;

  SmokeSpot({
    required this.address,
    required this.addressDetail,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.averageScore,
    required this.reviewCount,
    required this.details,
  });

  factory SmokeSpot.fromJson(Map<String, dynamic> json) {
    return SmokeSpot(
      address: json['address'],
      addressDetail: json['addressDetail'],
      image: json['image'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      averageScore: json['averageScore'],
      reviewCount: json['reviewCount'],
      details: Details.fromJson(json['details']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'addressDetail': addressDetail,
      'image': image,
      'latitude': latitude,
      'longitude': longitude,
      'averageScore': averageScore,
      'reviewCount': reviewCount,
      'details': details.toJson(),
    };
  }
}

class Details {
  final bool booth;
  final bool ventilation;
  final bool sealed;
  final List<Review> reviews;

  Details({
    required this.booth,
    required this.ventilation,
    required this.sealed,
    required this.reviews,
  });

  factory Details.fromJson(Map<String, dynamic> json) {
    var list = json['reviews'] as List;
    List<Review> reviewList = list.map((i) => Review.fromJson(i)).toList();

    return Details(
      booth: json['booth'],
      ventilation: json['ventilation'],
      sealed: json['sealed'],
      reviews: reviewList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booth': booth,
      'ventilation': ventilation,
      'sealed': sealed,
      'reviews': reviews.map((review) => review.toJson()).toList(),
    };
  }
}

class Review {
  final String userId;
  final String userNickname;
  final int score;
  final String text;
  final String date;

  Review({
    required this.userId,
    required this.userNickname,
    required this.score,
    required this.text,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      userId: json['userId'],
      userNickname: json['userNickname'],
      score: json['score'],
      text: json['text'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userNickname': userNickname,
      'score': score,
      'text': text,
      'date': date,
    };
  }
}

// Functions to encode and decode JSON
List<SmokeSpot> decodeSmokeSpots(String jsonString) {
  final List<dynamic> jsonData = jsonDecode(jsonString);
  return jsonData.map((item) => SmokeSpot.fromJson(item)).toList();
}

String encodeSmokeSpots(List<SmokeSpot> spots) {
  final List<Map<String, dynamic>> jsonData =
  spots.map((spot) => spot.toJson()).toList();
  return jsonEncode(jsonData);
}
