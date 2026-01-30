import 'package:flutter/material.dart';

class VehicleSearchController {
  final ScrollController scrollController = ScrollController();

  bool isLoadingMore = false;
  bool hasMore = true;

  void attachScrollListener(VoidCallback onLoadMore) {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMore) {
        onLoadMore();
      }
    });
  }

  void dispose() {
    scrollController.dispose();
  }
}
