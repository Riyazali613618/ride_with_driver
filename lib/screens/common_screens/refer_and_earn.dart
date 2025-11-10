import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/color_constants.dart';

class ReferScreen extends StatelessWidget {
  const ReferScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: CupertinoNavigationBarBackButton(),
      title: const Text(
        'My Profile',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGiftIcon(),
          const SizedBox(height: 24),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildSubtitle(),
          const SizedBox(height: 24),
          _buildReferralLink(context),
          const SizedBox(height: 24),
          _buildReferButton(),
        ],
      ),
    );
  }

  Widget _buildGiftIcon() {
    return Center(
        child: SvgPicture.asset(
      'assets/svg/gift.svg',
      height: 200,
    ));
  }

  Widget _buildTitle() {
    return const Text(
      ' ',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      ' ',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey,
        height: 1.4,
      ),
    );
  }

  Widget _buildReferralLink(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorConstants.primaryColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.share,
            size: 20,
            color: ColorConstants.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'https://food.net/76738b',
              style: TextStyle(
                  color: ColorConstants.appBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(const ClipboardData(
                text: 'https://food.net/76738b',
              )).then((_) {
                // Show a snackbar or toast to indicate successful copy
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Referral link copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              });
            },
            child: Icon(
              Icons.copy,
              size: 20,
              color: ColorConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Implement refer functionality
            Share.share('Join using my referral link: https://food.net/76738b');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstants.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Refer Now',
            style: TextStyle(
              fontSize: 16,
              color: ColorConstants.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// Add this to use the share functionality
