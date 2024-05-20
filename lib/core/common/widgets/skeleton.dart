import 'package:flutter/material.dart';

class SkeletonPage extends StatelessWidget {
  const SkeletonPage(
      {super.key,
      required this.title,
      required this.bodyW,
      this.actionW,
      this.leadingW,
      this.bottomNavigationW,
      this.drawerW,
      this.endDrawerW,
      this.floatingButtonW,
      this.backgroundImage,
      this.bottomW});

  final Widget title;
  final Widget bodyW;
  final Widget? actionW;
  final Widget? leadingW;
  final Widget? bottomNavigationW;
  final Widget? drawerW;
  final Widget? endDrawerW;
  final Widget? floatingButtonW;
  final Widget? backgroundImage;
  final TabBar? bottomW;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        flexibleSpace: backgroundImage,
        actions: [
          actionW ?? const SizedBox(),
        ],
        leading: leadingW,
        toolbarHeight: 80,
        bottom: bottomW,
      ),
      drawer: drawerW,
      endDrawer: endDrawerW,
      body: bodyW,
      floatingActionButton: floatingButtonW,
      bottomNavigationBar: bottomNavigationW,
    );
  }
}
