import 'package:flutter/material.dart';

class MultiStepProgressBar extends StatelessWidget {
  /// The index of the current active step.
  final int currentStep;

  /// A list of titles for each step. The length of this list determines
  /// the total number of steps.
  final List<String> stepTitles;

  /// The gradient colors to use for active/completed steps and lines.
  /// Defaults to [Colors.blue, Colors.purple] if not provided.
  final List<Color>? gradientColors;

  /// The color to use for inactive steps and lines.
  /// Defaults to Colors.grey[300].
  final Color? inactiveColor;

  const MultiStepProgressBar({
    super.key,
    required this.currentStep,
    required this.stepTitles,
    this.gradientColors,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    // Define default colors
    final List<Color> finalGradientColors =
        gradientColors ?? [Colors.blue, Colors.purple];
    final Color finalInactiveColor = inactiveColor ?? Colors.grey[300]!;
    final int stepCount = stepTitles.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // 1. Circles and Lines (using a Stack)
          Stack(
            alignment: Alignment.center,
            children: [
              // 1a. Background Line (full width inactive)
              Container(
                height: 4,
                // The margin ensures the line stops at the center of the first/last circles
                margin: const EdgeInsets.symmetric(horizontal: 18), // 36 / 2
                color: finalInactiveColor,
              ),

              // 1b. Progress Line (gradient)
              LayoutBuilder(
                builder: (context, constraints) {
                  // Total width of the line area (full width - one circle's width)
                  final double maxWidth = constraints.maxWidth - 36;
                  // Width of the progress line
                  final double progressWidth =
                      maxWidth * (currentStep / (stepCount - 1));

                  return Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 4,
                      width: progressWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: finalGradientColors),
                      ),
                    ),
                  );
                },
              ),

              // 1c. Circles (on top)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(stepCount, (index) {
                  final bool isActive = index == currentStep;
                  final bool isCompleted = index < currentStep;
                  final bool isGradientCircle = isActive || isCompleted;

                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Apply gradient if active/completed, else solid inactive color
                      gradient: isGradientCircle
                          ? LinearGradient(
                        colors: finalGradientColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                          : null,
                      color: isGradientCircle ? null : finalInactiveColor,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2. Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(stepCount, (index) {
              return Container(
                // Use a fixed width to ensure text wraps and centers correctly
                child: Text(
                  stepTitles[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2, // Allow wrapping for long titles
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}