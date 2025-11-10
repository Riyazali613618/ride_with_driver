import 'dart:convert'; // Add this for JSON handling
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:r_w_r/components/app_button.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/color_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

import '../../components/custom_text_field.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/color.dart';

class RatingsReviewScreen extends StatefulWidget {
  final String serviceId;
  final String serviceType;

  const RatingsReviewScreen({
    Key? key,
    required this.serviceId,
    required this.serviceType,
  }) : super(key: key);

  @override
  State<RatingsReviewScreen> createState() => _RatingsReviewScreenState();
}

class _RatingsReviewScreenState extends State<RatingsReviewScreen> {
  int _rating = 0;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _reviewController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final baseUrl = ApiConstants.baseUrl;

  Future<void> _submitReview() async {
    print("Submit review function called");

    if (_rating == 0) {
      print("Error: No rating selected");
      _showError("Please select a rating");
      return;
    }

    if (_reviewController.text.isEmpty) {
      print("Error: Review text is empty");
      _showError("Please write a review");
      return;
    }

    print("Rating: $_rating");
    print("Review: ${_reviewController.text}");
    print("Service ID: ${widget.serviceId}");
    print("Service Type: ${widget.serviceType}");

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await TokenManager.getToken();
      final url = Uri.parse('$baseUrl/user/reviews');
      print("API URL: $url");

      final requestBody = {
        'rating': _rating,
        'review': _reviewController.text,
        'partnerId': widget.serviceId,
      };

      print("Request Body: ${jsonEncode(requestBody)}");
      print("Token: $token");

      final response = await http.post(
        url,
        body: json.encode(requestBody),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Success
        final localizations = AppLocalizations.of(context)!;

        final message = responseData['message'] ??
            localizations.reviewSubmittedSuccessfully;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        final message = responseData['message'] ?? " ";
        _showError(message);
      }
    } catch (e) {
      print("Exception occurred: ${e.toString()}");
      _showError("Network error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    setState(() {
      _errorMessage = message;
    });

    // Optional: Show a snackbar for immediate feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(localizations.ratings_reviews,style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientFirst,
              gradientSecond,
              gradientThird,
              Colors.white
            ],
            stops: [0.0, 0.15, 0.30, .90],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // // Debug info at the top
                // Text(
                //   'Debug Info: serviceId=${widget.serviceId}, serviceType=${widget.serviceType}',
                //   style: const TextStyle(fontSize: 12, color: Colors.grey),
                // ),
                const SizedBox(height: 10.0),

                // Rating section
                Text(
                  localizations.rating,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = index + 1;
                        });
                        print("Rating selected: ${index + 1}");
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          _rating > index ? Icons.star : Icons.star_border,
                          color: _rating > index ? Colors.amber : Colors.grey,
                          size: 40.0,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24.0),

                // Review section
                Text(
                  localizations.review,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8.0),
                CustomTextField(
                  controller: _reviewController,
                  keyboardType: TextInputType.multiline,
                  label: localizations.writeYourReviewHere,
                  maxLines: 5,
                ),
                const SizedBox(height: 16.0),

                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14.0,
                      ),
                    ),
                  ),

                // Submit button
                CustomButton(
                  backgroundColor: ColorConstants.primaryColor,
                  text: _isLoading
                      ? localizations.submitting
                      : localizations.submitReview,
                  onPressed: _isLoading
                      ? () {
                          print("Button pressed while loading - ignoring");
                        }
                      : () {
                          print("Submit button pressed");
                          _submitReview();
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
