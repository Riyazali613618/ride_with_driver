import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/color.dart';

class CommonParentContainer extends StatelessWidget {
  final Widget child;
  final bool showLargeGradient;

  const CommonParentContainer(
      {required this.child, this.showLargeGradient = true, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gradientFirst,
            gradientSecond,
            gradientThird,
            Colors.white,
            Colors.white,
            Colors.white,
            Colors.white,
            Colors.white,
            if (showLargeGradient) Colors.white,
            if (showLargeGradient) Colors.white,
            if (showLargeGradient) Colors.white,
            if (showLargeGradient) Colors.white,
          ],
        ),
      ),
      child: child,
    );
  }
}
