import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

import '../../api/api_model/rating_reviews_model.dart';
import '../../constants/color_constants.dart';
import '../../l10n/app_localizations.dart';
import '../user_screens/rating_and_reviews.dart';

class ReviewsWidget extends StatefulWidget {
  final String usertype;
  final String driverId;
  final ValueChanged<bool>? onReviewStatusChanged;

  const ReviewsWidget({
    Key? key,
    required this.usertype,
    required this.driverId,
    this.onReviewStatusChanged,
  }) : super(key: key);

  @override
  State<ReviewsWidget> createState() => _ReviewsWidgetState();
}

class _ReviewsWidgetState extends State<ReviewsWidget> {
  late Future<List<Review>> _reviewsFuture;
  bool _hasReviewed = false;
  final baseUrl = ApiConstants.baseUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _reviewsFuture = fetchReviews(); // Set the future to actual fetch call
    });

    // try {
      final reviews = await fetchReviews();
      final userId = await TokenManager.getToken();

      final hasReviewed =
          userId != null && reviews.any((review) => review.userId == userId);

      if (widget.onReviewStatusChanged != null) {
        widget.onReviewStatusChanged!(hasReviewed);
      }

      setState(() {
        _hasReviewed = hasReviewed;
        _isLoading = false;
      });
    // } catch (e) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   debugPrint('Error loading reviews: $e');
    // }
  }

  Future<List<Review>> fetchReviews() async {
    final token = await TokenManager.getToken();
    final url = Uri.parse(
        '$baseUrl/user/reviews');

    debugPrint('Fetching reviews from: $url');
    // try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint(
          'Reviews API response: ${response.statusCode}\n${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data']['reviews'] is List) {
          return (jsonResponse['data']['reviews'] as List)
              .map((e) => Review.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(jsonResponse['message'] ?? 'Unknown API error');
        }
      } else {
        throw Exception(
            'Failed to fetch reviews. Code: ${response.statusCode}');
      }
    // } catch (e, stack) {
    //   debugPrint('Error fetching reviews: $e\n$stack');
    //   rethrow;
    // }
  }

  // Add this method to refresh reviews from parent
  void refreshReviews() {
    _loadReviews();
  }

  Future<void> _deleteReview(String reviewId) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final token = await TokenManager.getToken();
      final url = Uri.parse('$baseUrl/user/rtr/review-rating/$reviewId');
      debugPrint('Deleting review at: $url');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Delete response: ${response.statusCode}\n${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ??
                localizations.reviewDeletedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh reviews and update parent
        _loadReviews();
      } else {
        throw Exception(localizations.retry);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('  $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditReviewDialog(Review review) {
    showDialog(
      context: context,
      builder: (context) => EditReviewDialog(
        review: review,
        onReviewUpdated: () {
          // Refresh reviews and update parent
          _loadReviews();
        },
      ),
    );
  }

  void _showDeleteConfirmation(String reviewId) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.confirm_delete),
        content: Text(localizations.confirm_delete_review),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReview(reviewId);
            },
            child:
                Text(localizations.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Widget to build the total reviews header
  Widget _buildTotalReviewsHeader(int totalReviews) {
    final localizations = AppLocalizations.of(context)!;

    return Row(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorConstants.backgroundColor.withAlpha(10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.star_outline,
                color: ColorConstants.primaryColorLight,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "${localizations.ratings_reviews} ($totalReviews)",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final localizations = AppLocalizations.of(context)!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  ' ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadReviews,
                  child: Text(localizations.retry),
                ),
              ],
            ),
          );
        }
        final reviews = snapshot.data ?? [];
        final localizations = AppLocalizations.of(context)!;

        // Show total reviews header even when no reviews exist
        return Column(
          children: [
            _buildTotalReviewsHeader(reviews.length),
            if (reviews.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.no_reviews_yet,
                      // 'No reviews yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.be_first_to_review,
                      // 'Be the first to share your experience!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    // if (!_hasReviewed) ...[
                    //   //this is the button of be a first reviewer
                    //   ElevatedButton(
                    //       onPressed: () {
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => RatingsReviewScreen(
                    //               serviceId: widget.driverId,
                    //               serviceType: widget.usertype,
                    //             ),
                    //           ),
                    //         ).then((_) {
                    //           _loadReviews();
                    //         });
                    //       },
                    //       child: Text(localizations.rate_now)),
                    // ],
                  ],
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              CircleAvatar(
                                backgroundImage: NetworkImage(review.userPhoto),
                                onBackgroundImageError: (_, __) {},
                                radius: 24,
                                child: review.userPhoto.isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              const SizedBox(width: 12),

                              // Username, rating, stars
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              review.userName,
                                              maxLines: 2,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "${review.rating}.0",
                                          style: TextStyle(
                                            color: ColorConstants.primaryColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        _RatingStars(rating: review.rating),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (review.isReviewedByMe)
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                          onTap: () =>
                                              _showEditReviewDialog(review),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: ColorConstants
                                                    .primaryColorLight
                                                    .withAlpha(60),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Icon(
                                                Icons.edit_note,
                                                size: 18,
                                                color:
                                                    ColorConstants.primaryColor,
                                              ),
                                            ),
                                          )),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                          onTap: () => _showDeleteConfirmation(
                                              review.id),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: ColorConstants
                                                    .primaryColorLight
                                                    .withAlpha(60),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Icon(
                                                Icons.delete_sweep_outlined,
                                                color: ColorConstants.red,
                                                size: 18,
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Review content
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  review.review,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              // Date (right aligned)
                              Text(
                                _formatDate(review.createdAt),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _RatingStars extends StatelessWidget {
  final int rating;

  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final isFilled = i < rating;
        return Icon(
          isFilled ? Icons.star : Icons.star_border,
          color: isFilled ? Colors.amber : Colors.grey,
          size: 18,
        );
      }),
    );
  }
}

class EditReviewDialog extends StatefulWidget {
  final Review review;
  final VoidCallback onReviewUpdated;

  const EditReviewDialog({
    Key? key,
    required this.review,
    required this.onReviewUpdated,
  }) : super(key: key);

  @override
  State<EditReviewDialog> createState() => _EditReviewDialogState();
}

class _EditReviewDialogState extends State<EditReviewDialog> {
  late int _rating;
  late TextEditingController _reviewController;
  final baseUrl = ApiConstants.baseUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.review.rating;
    _reviewController = TextEditingController(text: widget.review.review);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _updateReview() async {
    final localizations = AppLocalizations.of(context)!;
    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.enter_your_review),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await TokenManager.getToken();
      final url =
          Uri.parse('$baseUrl/user/rtr/review-rating/${widget.review.id}');

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'rating': _rating,
          'review': _reviewController.text,
          'id': widget.review.id,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ??
                localizations.reviewSubmittedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        widget.onReviewUpdated();
        Navigator.pop(context);
      } else {
        throw Exception(responseData['message'] ?? localizations.retry);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.edit_review),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      _rating > index ? Icons.star : Icons.star_border,
                      color: _rating > index ? Colors.amber : Colors.grey,
                      size: 30.0,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                labelText: localizations.your_review,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateReview,
          child: _isLoading
              ? const CircularProgressIndicator()
              : Text(localizations.update),
        ),
      ],
    );
  }
}
