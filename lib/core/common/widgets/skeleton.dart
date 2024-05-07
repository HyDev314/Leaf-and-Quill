import 'package:flutter/material.dart';

class SkeletonPage extends StatelessWidget {
  const SkeletonPage(
      {super.key,
      required this.title,
      required this.body,
      this.action,
      this.isBack,
      this.leading,
      this.bottomNavigation,
      this.drawer,
      this.endDrawer,
      this.floatingButton});

  final Text title;
  final Widget body;
  final Widget? action;
  final Widget? leading;
  final bool? isBack;
  final Widget? bottomNavigation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: [
          action ?? const SizedBox(),
        ],
        leading: leading ?? const SizedBox(),
        automaticallyImplyLeading: isBack ?? false,
        toolbarHeight: 100,
      ),
      drawer: drawer ?? const SizedBox(),
      endDrawer: endDrawer ?? const SizedBox(),
      body: body,
      floatingActionButton: floatingButton ?? const SizedBox(),
      bottomNavigationBar: bottomNavigation ?? const SizedBox(),
    );
  }
}
