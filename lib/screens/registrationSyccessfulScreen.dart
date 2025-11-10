import 'dart:math';

import 'package:flutter/material.dart';
import 'package:r_w_r/screens/vehicle/vehicleRegistrationScreen.dart';
import '../utils/color.dart';

class RegistrationSuccessfulScreen extends StatelessWidget {
  final String userType;

  const RegistrationSuccessfulScreen({super.key, required this.userType});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            stops: [0.0, 0.15, 0.30, 0.90],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Main content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        children: [
                          // Star-like decoration around the circle
                          Positioned.fill(
                            child: CustomPaint(
                              painter: StarDecorationPainter(),
                            ),
                          ),
                          // Check mark in center
                          Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
                    // Success text
                    Text(
                      'Registration Successful',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 30),
                    // Description text
                    (userType!='DRIVER')?  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Now, you may continue to list your Vehicles',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ):Container(),
                    SizedBox(height: 50),
                    // Continue button
                    (userType!='DRIVER')? _buildContinueButton(context):Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (){
          _navigateToVehicleListingScreen(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF8B5CF6),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _navigateToVehicleListingScreen(BuildContext context) {
    // Navigate to vehicle listing screen
    Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleRegistrationForm(userType: userType)));

    // For now, just pop back to previous screens
    // Navigator.popUntil(context, (route) => route.isFirst);
  }
}

// Custom painter for the star decoration around the success icon
class StarDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw star-like points around the circle
    const numberOfPoints = 12;
    const pointLength = 8.0;

    for (int i = 0; i < numberOfPoints; i++) {
      final angle = (2 * 3.14159 * i) / numberOfPoints;
      final x1 = center.dx + (radius - 2) * cos(angle);
      final y1 = center.dy + (radius - 2) * sin(angle);
      final x2 = center.dx + (radius + pointLength) * cos(angle);
      final y2 = center.dy + (radius + pointLength) * sin(angle);

      // Draw small triangular points
      final path = Path();
      path.moveTo(x1, y1);

      final leftAngle = angle - 0.2;
      final rightAngle = angle + 0.2;

      path.lineTo(
        center.dx + (radius + pointLength) * cos(leftAngle),
        center.dy + (radius + pointLength) * sin(leftAngle),
      );
      path.lineTo(
        center.dx + (radius + pointLength) * cos(rightAngle),
        center.dy + (radius + pointLength) * sin(rightAngle),
      );
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Import this at the top of your file if not already imported