import 'package:flutter/material.dart';

import '../../components/app_appbar.dart';
import '../../constants/color_constants.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: " "),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Terms and Conditions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 20.0),
                child: Text(
                  'Effective Date: 15 Apr 2025',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Text(
              'Welcome to RideNow Taxi App. By using our services, you agree to the terms and conditions outlined below. Please read them carefully before booking a ride.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 24),
            _buildSection(
              '1. Booking Policy',
              [
                'Bookings are subject to availability of drivers in your area.',
                'Users must ensure their pickup and drop locations are correct.',
              ],
              Icons.local_taxi,
            ),
            _buildSection(
              '2. Payment Terms',
              [
                'All rides must be paid in full at the end of the trip via app-supported payment methods.',
                'Promo codes and discounts may be limited to certain rides and times.',
              ],
              Icons.payment,
            ),
            _buildSection(
              '3. Cancellation Policy',
              [
                'Cancellations within 2 minutes are free of charge.',
                'Late cancellations may incur a fee depending on the trip distance and time.',
              ],
              Icons.cancel,
            ),
            _buildSection(
              '4. User Responsibilities',
              [
                'Users are expected to behave respectfully with drivers.',
                'Damaging vehicle interiors or misbehavior may lead to penalties or account suspension.',
              ],
              Icons.verified_user,
            ),
            _buildSection(
              '5. Driver Responsibilities',
              [
                'Drivers must reach pickup location on time and ensure a safe, hygienic experience.',
                'Drivers cannot refuse rides without valid reason once assigned.',
              ],
              Icons.directions_car,
            ),
            _buildSection(
              '6. Location Tracking',
              [
                'The app uses real-time GPS tracking to manage bookings and ride paths.',
                'Users must allow location access during ride usage.',
              ],
              Icons.location_on,
            ),
            _buildSection(
              '7. Data Privacy',
              [
                'Personal data such as name, phone, and location is collected for booking purposes.',
                'Data is securely stored and not shared without user consent unless required by law.',
              ],
              Icons.lock,
            ),
            SizedBox(height: 24),
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone, color: ColorConstants.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Need Help?\nContact Support',
                          style: TextStyle(
                            color: ColorConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '24x7 Customer Care',
                      style: TextStyle(
                        color: ColorConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    GestureDetector(
                      // onTap: () => launchUrl(Uri.parse("tel:+919999999999")),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📞  ',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            '+91-9999999999',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      // onTap: () =>
                      //     launchUrl(Uri.parse("mailto:support@ridenow.com")),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📧  ',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            'support@ridenow.com',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> contents, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              Icon(icon, color: ColorConstants.primaryColor, size: 24),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.primaryColor,
                ),
              ),
            ],
          ),
        ),
        ...contents.map((content) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 32.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle,
                      size: 8, color: ColorConstants.primaryColor),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        SizedBox(height: 8),
      ],
    );
  }
}
