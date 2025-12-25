import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/color.dart';

class BookingContainer extends StatelessWidget {
  final Widget child;
  final bool showLargeGradient;

  const BookingContainer(
      {required this.child, this.showLargeGradient = false, super.key});

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
            if(showLargeGradient)
              ...[
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
              ]
          ],
        ),
      ),
      child: child,
    );
  }
}
