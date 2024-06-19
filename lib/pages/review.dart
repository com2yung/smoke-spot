class Review {
  String userId;
  int score;
  String text;
  String date;


  Review({
    required this.userId,
    required this.score,
    required this.text,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      userId: json['userId'] as String,
      score: json['score']as int,
      text: json['text'] as String,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson () {
    return {
      'userId': userId,
      'score': score,
      'text': text,
      'date': date,
    };
  }
}
