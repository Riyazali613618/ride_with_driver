import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r_w_r/components/app_appbar.dart';
import 'package:r_w_r/constants/color_constants.dart';

class NotAllowed extends StatelessWidget {
  final String message;

  const NotAllowed({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backgroundColor: ColorConstants.white,
        leading: CupertinoNavigationBarBackButton(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.do_not_disturb_off_outlined,
                size: 80, // Added size
                color: ColorConstants.errorColor, // Added color
              ),
              const SizedBox(height: 24), // Added spacing
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ColorConstants.primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
