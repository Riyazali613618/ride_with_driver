import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r_w_r/constants/color_constants.dart';

import '../../../components/app_appbar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // State variables for toggle switches
  bool inboxMessages = false;
  bool ratingsReminders = false;
  bool promotionsAndTips = false;
  bool accountUpdates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: CupertinoNavigationBarBackButton(),
      title: 'Notifications',
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDivider(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Text(
            'Get push notifications about...',
            style: TextStyle(
              color: ColorConstants.appBlue,
              fontSize: 14,
            ),
          ),
        ),
        _buildNotificationSection(
          title: 'Inbox messages',
          subtitle: 'Receive notifications when a Skills responds.',
          value: inboxMessages,
          onChanged: (value) {
            setState(() {
              inboxMessages = value;
            });
          },
        ),
        _buildDivider(),
        _buildNotificationSection(
          title: 'Ratings reminders',
          subtitle:
              'Get notifications on rating a Skillr after\nservice has been provided.',
          value: ratingsReminders,
          onChanged: (value) {
            setState(() {
              ratingsReminders = value;
            });
          },
        ),
        _buildDivider(),
        _buildNotificationSection(
          title: 'Promotions and tips',
          subtitle: 'There are discounts, coupons and tips you\nmight like.',
          value: promotionsAndTips,
          onChanged: (value) {
            setState(() {
              promotionsAndTips = value;
            });
          },
        ),
        _buildDivider(),
        _buildNotificationSection(
          title: 'Your account',
          subtitle: 'We have updates about your account and\nsecurity matters.',
          value: accountUpdates,
          onChanged: (value) {
            setState(() {
              accountUpdates = value;
            });
          },
        ),
        _buildDivider(),
      ],
    );
  }

  Widget _buildNotificationSection({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: ColorConstants.appColorGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: ColorConstants.greyLight,
      indent: 16,
      endIndent: 16,
    );
  }
}
