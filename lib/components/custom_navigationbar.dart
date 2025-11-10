import 'package:flutter/material.dart';


enum PageTransitionDirection { bottomToTop, topToBottom, leftToRight, rightToLeft }

void navigateWithCustomTransition(BuildContext context, Widget page, PageTransitionDirection direction) {
  Offset beginOffset;

  switch (direction) {
    case PageTransitionDirection.bottomToTop:
      beginOffset = Offset(0.0, 1.0);
      break;
    case PageTransitionDirection.topToBottom:
      beginOffset = Offset(0.0, -1.0);
      break;
    case PageTransitionDirection.leftToRight:
      beginOffset = Offset(-1.0, 0.0);
      break;
    case PageTransitionDirection.rightToLeft:
      beginOffset = Offset(1.0, 0.0);
      break;
  }

  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400), // Adjust duration as needed
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(begin: beginOffset, end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    ),
  );
}
