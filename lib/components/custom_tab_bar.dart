import 'package:flutter/material.dart';

import '../constants/color_constants.dart';

class CustomTabBar extends StatelessWidget {
  final TabController tabController;
  final List<Tab> tabs;
  final List<Widget> tabContents;

  const CustomTabBar({
    super.key,
    required this.tabController,
    required this.tabs,
    required this.tabContents,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          tabAlignment: TabAlignment.start,
          controller: tabController,
          isScrollable: true,
          dividerColor: Colors.grey.withOpacity(0.3),
          labelColor: ColorConstants.primaryColor,
          indicatorSize: TabBarIndicatorSize.tab,
          padding: EdgeInsets.zero,
          indicatorPadding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
          indicatorWeight: 2,
          unselectedLabelColor: Colors.grey.withOpacity(0.8),
          unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
          labelStyle: Theme.of(context).textTheme.bodyMedium,
          indicatorColor: ColorConstants.primaryColor,
          tabs: tabs,
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: tabContents,
          ),
        ),
      ],
    );
  }
}
