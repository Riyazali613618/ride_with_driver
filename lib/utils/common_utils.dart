import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonUtils {
  static void goToScreen(BuildContext context, Widget className) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => className));
  }
}
