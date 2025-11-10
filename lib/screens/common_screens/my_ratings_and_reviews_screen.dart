import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:r_w_r/constants/color_constants.dart';

import '../../../constants/api_constants.dart';
import '../../../constants/token_manager.dart';
import '../../components/app_appbar.dart';
import '../../l10n/app_localizations.dart';
import '../block/provider/profile_provider.dart';

class RatingModel {
  final String userId;
  final String review;
  final int rating;
  final DateTime createdAt;
  final String id;
  final String userName;
  final String? userPhoto;
  final bool isReviewedByMe;

  RatingModel({
    required this.userId,
    required this.review,
    required this.rating,
    required this.createdAt,
    required this.id,
    required this.userName,
    this.userPhoto,
    required this.isReviewedByMe,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      userId: json['userId'] ?? '',
      review: json['review'] ?? '',
      rating: json['rating'] ?? 0,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      id: json['id'] ?? '',
      userName: json['userName'] ?? 'Unknown User',
      userPhoto: json['userPhoto'],
      isReviewedByMe: json['isReviewedByMe'] ?? false,
    );
  }
}

class MyRatingsScreen extends StatefulWidget {
  const MyRatingsScreen({super.key});

  @override
  State<MyRatingsScreen> createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> {
  List<RatingModel> _ratings = [];
  bool _isLoading = true;
  String? _error;
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRatings();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading && _ratings.isEmpty) {
      _loadRatings();
    }
  }

  Future<void> _loadRatings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final localizations = AppLocalizations.of(context)!;

      final profileProvider = context.read<ProfileProvider>();
      final userType = profileProvider.userType;

      if (userType == null) {
        throw Exception(localizations.retry);
      }

      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception(localizations.no_data_available);
      }

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/user/rtr/review-rating?type=${userType
                .toUpperCase()}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true) {
          final List<dynamic> ratingsData = data['data'] ?? [];

          setState(() {
            _ratings =
                ratingsData.map((item) => RatingModel.fromJson(item)).toList();
            _averageRating = _calculateAverageRating();
            _isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? localizations.no_data_available);
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _ratings = [];
          _averageRating = 0.0;
          _isLoading = false;
        });
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to load ratings');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  double _calculateAverageRating() {
    if (_ratings.isEmpty) return 0.0;

    final totalRating =
    _ratings.fold<double>(0, (sum, rating) => sum + rating.rating);
    return totalRating / _ratings.length;
  }

  Widget _buildRatingStars(int rating, {double size = 20}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? Colors.amber : Colors.grey[400],
          size: size,
        );
      }),
    );
  }

  Widget _buildHeader() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorConstants.primaryColor,
            ColorConstants.primaryColor.withAlpha(180)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                  localizations.totalReviews, _ratings.length.toString()),
              _buildStatCard(localizations.averageRating,
                  _averageRating.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 12),
          _buildRatingStars(_averageRating.round(), size: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(RatingModel rating) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: rating.userPhoto != null
                      ? NetworkImage(rating.userPhoto!)
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: rating.userPhoto == null
                      ? Icon(Icons.person, color: Colors.grey[600])
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rating.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(rating.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRatingStars(rating.rating),
              ],
            ),
            if (rating.review.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rating.review,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            if (rating.isReviewedByMe) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  localizations.your_review,
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final localizations = AppLocalizations.of(context)!;

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years > 1 ? localizations.years : localizations
          .year} ${localizations.ago}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months > 1 ? localizations.months : localizations
          .month} ${localizations.ago}';
    } else if (difference.inDays > 0) {
      final days = difference.inDays;
      return '$days ${days > 1 ? localizations.days : localizations
          .day} ${localizations.ago}';
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      return '$hours ${hours > 1 ? localizations.hours : localizations
          .hour} ${localizations.ago}';
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes > 1 ? localizations.minutes : localizations
          .minute} ${localizations.ago}';
    } else {
      return localizations.justNow;
    }
  }

  Widget _buildErrorState() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.something_went_wrong,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? ' ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loadRatings,
                icon: const Icon(Icons.refresh),
                label: Text(localizations.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.no_reviews_yet,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.no_reviews_received,
              // 'You haven\'t received any reviews yet. Keep providing great service!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      // appBar: CustomAppBar(
      //   centerTitle: true,
      //   title: localizations.my_ratings_reviews,
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorConstants.primaryColorNew,
              ColorConstants.redColorNew,
              ColorConstants.whiteNew,
            ],
            stops: const [0.0, 0.20, 0.80],
          ),
        ),
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : _error != null
            ? _buildErrorState()
            : Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: ColorConstants.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.my_ratings_reviews,
                          style: TextStyle(
                            color: ColorConstants.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildHeader(),
            Expanded(
              child: _ratings.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                onRefresh: _loadRatings,
                child: ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _ratings.length,
                  itemBuilder: (context, index) {
                    return _buildRatingCard(_ratings[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
