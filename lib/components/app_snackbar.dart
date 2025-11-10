import 'package:flutter/material.dart';

import '../constants/color_constants.dart';

class CustomSnackBar {
  static OverlayEntry? _currentOverlayEntry;

  static showCustomSnackBar({
    required BuildContext context,
    required String message,
    bool success = true,
    Duration duration = const Duration(seconds: 3),
    Duration animationDuration = const Duration(milliseconds: 300),
    double topOffset = 50.0,
    double leftOffset = 20.0,
    double rightOffset = 20.0,
    bool showCloseButton = false,
    bool autoDismiss = true,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Color? iconColor,
    double fontSize = 16.0,
    FontWeight fontWeight = FontWeight.bold,
    int maxLines = 4,
    EdgeInsets padding =
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(15)),
    List<BoxShadow>? boxShadow,
    VoidCallback? onTap,
    VoidCallback? onClose,
    bool dismissOnTap = false,
    double initialOffset = -100.0,
    double initialOpacity = 0.0,
    Curve animationCurve = Curves.easeInOut,
  }) {
    // Remove any existing snackbar
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;

    final overlay = Overlay.of(context);
    final snackBarWidget = _CustomSnackBarWidget(
      message: message,
      success: success,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
      iconColor: iconColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      maxLines: maxLines,
      padding: padding,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      showCloseButton: showCloseButton,
      onTap: onTap,
      onClose: onClose,
      dismissOnTap: dismissOnTap,
    );

    final overlayEntry = OverlayEntry(
      builder: (context) => _SnackBarAnimationWidget(
        snackBarWidget: snackBarWidget,
        topOffset: topOffset,
        leftOffset: leftOffset,
        rightOffset: rightOffset,
        animationDuration: animationDuration,
        initialOffset: initialOffset,
        initialOpacity: initialOpacity,
        animationCurve: animationCurve,
        onRemove: () {
          _currentOverlayEntry?.remove();
          _currentOverlayEntry = null;
        },
      ),
    );

    _currentOverlayEntry = overlayEntry;
    overlay.insert(overlayEntry);

    // Auto dismiss if enabled
    if (autoDismiss) {
      Future.delayed(duration, () {
        if (_currentOverlayEntry == overlayEntry) {
          overlayEntry.remove();
          _currentOverlayEntry = null;
        }
      });
    }
  }

  // Method to manually dismiss the current snackbar
  static void dismiss() {
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;
  }
}

class _SnackBarAnimationWidget extends StatefulWidget {
  final Widget snackBarWidget;
  final double topOffset;
  final double leftOffset;
  final double rightOffset;
  final Duration animationDuration;
  final double initialOffset;
  final double initialOpacity;
  final Curve animationCurve;
  final VoidCallback onRemove;

  _SnackBarAnimationWidget({
    required this.snackBarWidget,
    required this.topOffset,
    required this.leftOffset,
    required this.rightOffset,
    required this.animationDuration,
    required this.initialOffset,
    required this.initialOpacity,
    required this.animationCurve,
    required this.onRemove,
  });

  @override
  _SnackBarAnimationWidgetState createState() =>
      _SnackBarAnimationWidgetState();
}

class _SnackBarAnimationWidgetState extends State<_SnackBarAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _positionAnimation = Tween<double>(
      begin: widget.initialOffset,
      end: widget.topOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _opacityAnimation = Tween<double>(
      begin: widget.initialOpacity,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    // Start animation after a brief delay
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _positionAnimation.value,
          left: widget.leftOffset,
          right: widget.rightOffset,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.snackBarWidget,
          ),
        );
      },
    );
  }
}

class _CustomSnackBarWidget extends StatelessWidget {
  final String message;
  final bool success;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final Color? iconColor;
  final double fontSize;
  final FontWeight fontWeight;
  final int maxLines;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final List<BoxShadow>? boxShadow;
  final bool showCloseButton;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final bool dismissOnTap;

  _CustomSnackBarWidget({
    required this.message,
    required this.success,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.iconColor,
    required this.fontSize,
    required this.fontWeight,
    required this.maxLines,
    required this.padding,
    required this.borderRadius,
    this.boxShadow,
    required this.showCloseButton,
    this.onTap,
    this.onClose,
    required this.dismissOnTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor =
        success ? ColorConstants.primaryColor : ColorConstants.red;

    final defaultBoxShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        spreadRadius: 1,
        blurRadius: 6,
      ),
    ];

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          if (dismissOnTap) {
            CustomSnackBar.dismiss();
          }
          onTap?.call();
        },
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? defaultBackgroundColor,
            borderRadius: borderRadius,
            boxShadow: boxShadow ?? defaultBoxShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null || !showCloseButton) ...[
                Icon(
                  icon ?? (success ? Icons.check_circle : Icons.error),
                  color: iconColor ?? Colors.white,
                ),
                SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  message,
                  maxLines: maxLines,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontWeight: fontWeight,
                    fontSize: fontSize,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showCloseButton) ...[
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    CustomSnackBar.dismiss();
                    onClose?.call();
                  },
                  child: Icon(
                    Icons.cancel_rounded,
                    color: iconColor ?? Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
