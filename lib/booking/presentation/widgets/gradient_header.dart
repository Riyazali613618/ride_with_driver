import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GradientHeader extends StatelessWidget {
  final String title;
  final bool showBack;

  const GradientHeader({super.key, required this.title, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFF7B2CBF), Color(0xFFC77D50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
      ),
      padding: const EdgeInsets.only(left: 8, top: 28),
      child: Row(
        children: [
          if (showBack)
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back, color: Colors.white)),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
