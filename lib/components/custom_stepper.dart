import 'package:flutter/material.dart';

import '../constants/color_constants.dart';

class CustomStepper extends StatelessWidget {
  final int currentStep;
  final List<String> stepTitles;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final double stepSize;
  final double dividerLength;
  final double verticalSpacing;

  const CustomStepper({
    Key? key,
    required this.currentStep,
    required this.stepTitles,
    this.activeColor = ColorConstants.primaryColor,
    this.inactiveColor = ColorConstants.greyLight,
    this.activeTextColor = ColorConstants.primaryColor,
    this.inactiveTextColor = Colors.grey,
    this.stepSize = 32.0,
    this.dividerLength = 24.0,
    this.verticalSpacing = 8.0,
  })  : assert(currentStep >= 0 && currentStep <= stepTitles.length),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: Column(
        children: [
          SizedBox(height: 5),
          SizedBox(
            height: stepSize +
                verticalSpacing * 4, // Space for step + text + padding99
            child: Stack(
              children: [
                // Background line
                Positioned(
                  left: stepSize / 2,
                  right: stepSize / 2,
                  top: stepSize / 2,
                  child: Container(
                    height: 2.0,
                    color: inactiveColor.withOpacity(0.3),
                  ),
                ),
                // // Active line
                Positioned(
                  left: stepSize / 2,
                  right: _calculateActiveLinePosition(context),
                  top: stepSize / 2,
                  child: Container(
                    height: 2.0,
                    color: activeColor,
                  ),
                ),
                // Steps
                Row(
                  children: List.generate(stepTitles.length, (index) {
                    final isActive = index <= currentStep;
                    final isCompleted = index < currentStep;
                    // final isLast = index == stepTitles.length - 1;

                    return Expanded(
                      child: Container(
                        height: stepSize + verticalSpacing * 5,
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: stepSize,
                              height: stepSize,
                              decoration: BoxDecoration(
                                color: isActive ? activeColor : inactiveColor,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: isActive ? activeColor : inactiveColor,
                                  width: 2.0,
                                ),
                              ),
                              child: Center(
                                child: isCompleted
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: stepSize * 0.5,
                                      )
                                    : Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: isActive
                                              ? Colors.white
                                              : Colors.grey[700],
                                          fontWeight: FontWeight.bold,
                                          fontSize: stepSize * 0.4,
                                        ),
                                      ),
                              ),
                            ),
                            // Step Title
                            // SizedBox(height: verticalSpacing),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                stepTitles[index],
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isActive
                                      ? activeTextColor
                                      : inactiveTextColor,
                                  fontSize: stepSize * 0.3,
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateActiveLinePosition(BuildContext context) {
    if (currentStep >= stepTitles.length - 1) return stepSize / 2;

    final screenWidth =
        MediaQuery.of(context).size.width - 32.0; // Padding removed
    final stepWidth = screenWidth / stepTitles.length;

    return stepSize / 2 + (stepTitles.length - currentStep - 1) * stepWidth;
  }
}
