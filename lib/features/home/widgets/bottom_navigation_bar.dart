import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';

class BottomNavigationBarW extends ConsumerWidget {
  final int currentIndex;
  final void onTap;
  const BottomNavigationBarW(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 8, left: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppPalette.whiteColor,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 10,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BottomNavigationItem(
              iconUrl: Icons.home_rounded,
              index: 0,
              selectedItemIndex: currentIndex,
              label: 'Trang chủ',
            ),
            BottomNavigationItem(
              iconUrl: Icons.search_rounded,
              index: 1,
              selectedItemIndex: currentIndex,
              label: 'Tìm kiếm',
            ),
            BottomNavigationItem(
              iconUrl: Icons.notifications_active_rounded,
              index: 2,
              selectedItemIndex: currentIndex,
              label: 'Thông báo',
            ),
            BottomNavigationItem(
              iconUrl: Icons.eco_rounded,
              index: 3,
              selectedItemIndex: currentIndex,
              label: 'Góc học tập',
            ),
            BottomNavigationItem(
              iconUrl: Icons.menu_rounded,
              index: 4,
              selectedItemIndex: currentIndex,
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavigationItem extends ConsumerWidget {
  final IconData iconUrl;
  final int selectedItemIndex;
  final int index;
  final String label;

  const BottomNavigationItem(
      {super.key,
      required this.iconUrl,
      required this.index,
      required this.selectedItemIndex,
      required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {},
      icon: Icon(
        iconUrl,
        size: 30,
        color:
            index == selectedItemIndex ? Colors.blue : AppPalette.secondColor,
      ),
    );
  }
}
