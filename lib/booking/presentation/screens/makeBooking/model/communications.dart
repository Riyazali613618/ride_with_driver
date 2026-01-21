class Communication {
  final String id;
  final String fullName;
  final String mobile;
  final bool canReview;
  final bool reviewGiven;

  Communication({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.canReview,
    required this.reviewGiven,
  });

  factory Communication.fromJson(Map<String, dynamic> json) {
    return Communication(
      id: json['_id'],
      fullName: json['partnerId']['fullName'],
      mobile: json['partnerId']['mobileNumber'],
      canReview: json['canReview'],
      reviewGiven: json['reviewGiven'],
    );
  }
}
