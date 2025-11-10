import 'package:flutter/material.dart';

import '../../../utils/color.dart';

class LinearGradientProgressBar extends StatefulWidget {
  final double progress; // Value between 0.0 and 1.0
  final List<Color> gradientColors;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  const LinearGradientProgressBar({
    Key? key,
    required this.progress,
    required this.gradientColors,
    this.height = 10.0,
    this.borderRadius,
  }) : super(key: key);

  @override
  _LinearGradientProgressBarState createState() => _LinearGradientProgressBarState();
}

class _LinearGradientProgressBarState extends State<LinearGradientProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Adjust animation duration
    );
    _animation = Tween<double>(begin: 0.0, end: widget.progress).animate(_controller);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant LinearGradientProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(begin: oldWidget.progress, end: widget.progress).animate(_controller);
      _controller.forward(from: 0.0); // Restart animation from the beginning
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey[300], // Background color of the progress bar
            borderRadius: widget.borderRadius ?? BorderRadius.circular(5.0),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return FractionallySizedBox(
                widthFactor: _animation.value,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        gradientFirst,
                        gradientSecond,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}