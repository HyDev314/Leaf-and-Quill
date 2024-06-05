import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/notification/controller/notification_controller.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:leaf_and_quill_app/themes/theme.dart';

class BottomNavigationBarW extends ConsumerWidget {
  final int currentIndex;
  final void Function(int) onTap;
  const BottomNavigationBarW(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(userProvider)!.uid;
    final currentTheme = ref.watch(themeNotifierProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: currentTheme.bottomNavigationBarTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18), topRight: Radius.circular(18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () => onTap(0),
            icon: Icon(
              Icons.home_rounded,
              size: 30,
              color: currentIndex == 0
                  ? AppPalette.mainColor
                  : AppPalette.secondColor,
            ),
          ),
          IconButton(
            onPressed: () => onTap(1),
            icon: Icon(
              Icons.search_rounded,
              size: 30,
              color: currentIndex == 1
                  ? AppPalette.mainColor
                  : AppPalette.secondColor,
            ),
          ),
          ref.watch(getUserNotificationsProvider(uid)).when(
                data: (notifications) {
                  final hasUnread =
                      notifications.any((notification) => !notification.isRead);
                  return Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_on_rounded,
                          color: currentIndex == 2
                              ? AppPalette.mainColor
                              : AppPalette.secondColor,
                          size: 30,
                        ),
                        onPressed: () => onTap(2),
                      ),
                      if (hasUnread)
                        Positioned(
                          right: 5,
                          top: 5,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
                error: (error, stackTrace) {
                  return ErrorPage(errorText: error.toString());
                },
                loading: () => IconButton(
                  icon: const Icon(
                    Icons.notifications_on_rounded,
                    color: AppPalette.secondColor,
                    size: 30,
                  ),
                  onPressed: () {},
                ),
              ),
          IconButton(
            onPressed: () => onTap(3),
            icon: Icon(
              Icons.account_circle_rounded,
              size: 30,
              color: currentIndex == 3
                  ? AppPalette.mainColor
                  : AppPalette.secondColor,
            ),
          ),
        ],
      ),
    );
  }
}
