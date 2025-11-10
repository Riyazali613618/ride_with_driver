import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../components/app_appbar.dart';
import '../constants/assets_constant.dart';
import '../constants/color_constants.dart';

class TeaserHome extends StatefulWidget {
  const TeaserHome({super.key});
  @override
  State<TeaserHome> createState() => _TeaserHomeState();
}

class _TeaserHomeState extends State<TeaserHome> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: ColorConstants.primaryColor,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."),
                ),
                Container(
                  height: 50,
                  width: double.minPositive,
                  decoration: BoxDecoration(
                    color: ColorConstants.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    Text(
                      'Video',
                      style: TextStyle(color: ColorConstants.white),
                    ),
                    Icon(
                      Icons.play_arrow_outlined,
                      color: ColorConstants.white,
                    )
                  ]),
                ),
                _buildPaymentCard(),
                _buildDriverSubscription(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      height: 160,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          SvgPicture.asset(
            AssetsConstant.paymentBanner,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Finalize payment:",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                Text(
                  "₹170.71",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                Row(
                  children: const [
                    Text(
                      "Pay",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverSubscription() {
    return Container(
      height: 160,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          SvgPicture.asset(
            AssetsConstant.backgroundOne,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          Positioned(
              bottom: 4,
              left: 0,
              child: Image.asset(
                "assets/img/person1.png",
                height: 108,
                fit: BoxFit.fill,
              )),
          Positioned(
            top: 0,
            bottom: 0,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Become Driver/Transporter",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorConstants.white),
                ),
                Text(
                  "₹170.71",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: ColorConstants.white),
                ),
                SizedBox(height: 10),
                Row(
                  children: const [
                    Icon(
                      Icons.arrow_back,
                      color: ColorConstants.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Subscribe Now",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
