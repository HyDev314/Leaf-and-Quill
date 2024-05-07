import 'package:flutter/material.dart';

class SkeletonPage extends StatelessWidget {
  const SkeletonPage(
      {super.key,
      required this.title,
      required this.bodyWidget,
      this.actionWidget,
      this.isBack});

  final Text title;
  final Widget bodyWidget;
  final Widget? actionWidget;
  final bool? isBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: [
          actionWidget ?? const SizedBox(),
        ],
        automaticallyImplyLeading: isBack ?? false,
        surfaceTintColor: Colors.white,
      ),
      body: bodyWidget,
    );
  }
}
