class Review {
  final String id;
  final String userId;
  final String review;
  final int rating;
  final DateTime createdAt;
  final String userName;
  final String userPhoto;
  final bool isReviewedByMe;

  Review({
    required this.id,
    required this.userId,
    required this.review,
    required this.rating,
    required this.createdAt,
    required this.userName,
    required this.userPhoto,
    required this.isReviewedByMe,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      review: json['review'] ?? '',
      rating: json['rating'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      userName: json['userName'] ?? '',
      userPhoto: json['userPhoto'] ?? '',
      isReviewedByMe: json['isReviewedByMe'] ?? false,
    );
  }
}
