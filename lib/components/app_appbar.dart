import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:r_w_r/constants/color_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Color? backgroundColor;
  final Color? titleColor;
  final List<Widget>? actions;
  final Widget? leading;
  final bool? centerTitle;
  final double elevation;
  final double height;
  final PreferredSizeWidget? bottom;
  final ShapeBorder? shape;
  final Brightness? brightness;
  final IconThemeData? iconTheme;
  final TextStyle? titleTextStyle;
  final bool automaticallyImplyLeading;
  final double? titleSpacing;
  final double? leadingWidth;
  final bool? primary;
  final VoidCallback? onLeadingTap;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final double? toolbarOpacity;
  final double? bottomOpacity;
  final bool excludeHeaderSemantics;
  final double? toolbarHeight;
  final Widget? flexibleSpace;

  const CustomAppBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.backgroundColor,
    this.titleColor,
    this.actions,
    this.leading,
    this.centerTitle,
    this.elevation = 4.0,
    this.height = kToolbarHeight,
    this.bottom,
    this.shape,
    this.brightness,
    this.iconTheme,
    this.titleTextStyle,
    this.automaticallyImplyLeading = true,
    this.titleSpacing,
    this.leadingWidth,
    this.primary = true,
    this.onLeadingTap,
    this.systemOverlayStyle,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.excludeHeaderSemantics = false,
    this.toolbarHeight,
    this.flexibleSpace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget = leading ??
        CupertinoNavigationBarBackButton(
          color: ColorConstants.white,
          onPressed: onLeadingTap ?? () => Navigator.of(context).pop(),
        );

    if (leading != null && onLeadingTap != null) {
      leadingWidget = GestureDetector(
        onTap: onLeadingTap,
        child: leading!,
      );
    }

    Widget? finalTitleWidget;
    if (titleWidget != null) {
      finalTitleWidget = titleWidget;
    } else if (title != null) {
      finalTitleWidget = Text(
        title!,
        style: titleTextStyle ??
            TextStyle(
              color: titleColor ?? ColorConstants.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
      );
    }

    return AppBar(
      title: finalTitleWidget,
      backgroundColor: Colors.transparent,
      actions: actions,
      leading: leadingWidget,
      centerTitle: centerTitle ?? false,
      elevation: elevation,
      shape: shape,
      iconTheme: iconTheme,
      automaticallyImplyLeading: automaticallyImplyLeading,
      titleSpacing: titleSpacing,
      leadingWidth: leadingWidth,
      primary: primary ?? true,
      systemOverlayStyle: systemOverlayStyle,
      toolbarOpacity: toolbarOpacity ?? 1.0,
      bottomOpacity: bottomOpacity ?? 1.0,
      excludeHeaderSemantics: excludeHeaderSemantics,
      toolbarHeight: toolbarHeight ?? height,
      bottom: bottom,
      flexibleSpace: flexibleSpace,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        bottom == null ? height : height + bottom!.preferredSize.height,
      );
}
