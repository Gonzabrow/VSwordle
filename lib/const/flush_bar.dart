import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

void showTopMessage(BuildContext context, String message) {
  final double appBarHeight = Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight;

  Flushbar(
    message: message,
    duration: const Duration(seconds: 2),
    flushbarPosition: FlushbarPosition.TOP, // 上部に表示
    backgroundColor: Colors.redAccent,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    positionOffset: appBarHeight + MediaQuery.of(context).padding.top + 8, 
    animationDuration: const Duration(milliseconds: 1),
  ).show(context);
}