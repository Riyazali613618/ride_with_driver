import 'package:flutter/material.dart';
import 'vehicle_footer_loader.dart';

class VehicleList<T> extends StatelessWidget {
  final ScrollController controller;
  final List<T> vehicles;
  final bool hasMore;
  final bool isLoadingMore;
  final Future<void> Function() onRefresh;
  final Widget Function(T) itemBuilder;

  const VehicleList({
    super.key,
    required this.controller,
    required this.vehicles,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onRefresh,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: controller,
        itemCount: vehicles.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= vehicles.length) {
            return VehicleFooterLoader(isLoading: isLoadingMore);
          }
          return itemBuilder(vehicles[index]);
        },
      ),
    );
  }
}
