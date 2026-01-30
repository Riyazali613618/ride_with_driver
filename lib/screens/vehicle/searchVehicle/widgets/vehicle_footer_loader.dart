import 'package:flutter/material.dart';

class VehicleFooterLoader extends StatelessWidget {
  final bool isLoading;

  const VehicleFooterLoader({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : const Text('All loaded'),
      ),
    );
  }
}
