import 'package:flutter/material.dart';

import '../constants/color_constants.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: ColorConstants.white, // Background color
          borderRadius: BorderRadius.circular(12), // Border radius
          boxShadow: [
            BoxShadow(
              color: ColorConstants.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ], // Box shadow
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(child: Text("Loading...")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showNoInternetDialog(BuildContext context, {VoidCallback? onRetry}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: Icon(
          AppIcons.noInternet,
          color: AppColors.warning,
          size: 48,
        ),
        title: Text(
          'No Internet Connection',
          style: TextStyle(
            color: AppColors.warning,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize
              .min, // To make the column take only the required space
          children: [
            Text(
              'Please check your internet connection and try again.',
              style: TextStyle(
                color: AppColors.neutral,
              ),
            ),
            SizedBox(height: 20), // Add some spacing
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                if (onRetry != null) {
                  onRetry(); // Retry action
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning, // Button color
                foregroundColor: Colors.white, // Text color
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    },
  );
}

class AppColors {
  static const Color warning = Color(0xFFFFA000); // Orange
  static const Color neutral = Color(0xFF757575); // Gray
  static const Color blue = Color(0xFF641BB4);

  static const Color darkGrey=Color(0xFF757575); // Gray
}

class AppIcons {
  static const IconData noInternet = Icons.wifi_off;
}
// widgets/loading_indicator.dart

class LoadingIndicator extends StatelessWidget {
  final Color? color;

  const LoadingIndicator({
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: color ?? Theme.of(context).primaryColor,
    );
  }
}
