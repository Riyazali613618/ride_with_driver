class Review {
  final String id;
  final String review;
  final int rating;
  final DateTime createdAt;
  final String userName;
  final String userPhoto;

  Review({
    required this.id,
    required this.review,
    required this.rating,
    required this.createdAt,
    required this.userName,
    required this.userPhoto,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      review: json['review'] as String,
      rating: json['rating'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userName: json['userName'] as String,
      userPhoto: json['userPhoto'] as String,
    );
  }
}
