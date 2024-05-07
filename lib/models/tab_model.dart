import 'package:flutter/material.dart';

class TabModel {
  final Text title;
  final Widget body;
  final Widget? action;
  final Widget? leading;
  final bool? isBack;
  final Widget? bottomNavigation;
  final Widget? drawer;
  final Widget? endDrawer;

  TabModel(
      {required this.title,
      required this.body,
      this.action,
      this.leading,
      this.isBack,
      this.bottomNavigation,
      this.drawer,
      this.endDrawer});
}
