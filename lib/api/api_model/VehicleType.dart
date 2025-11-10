
import 'package:flutter/material.dart';

class VehicleType {
  final String name;
  final IconData? icon;
  final String? assetImagePath;
  final Color color;
  final Color color1;

  VehicleType({
    required this.name,
    this.icon,
    this.assetImagePath,
    required this.color,
    required this.color1,
  });
}