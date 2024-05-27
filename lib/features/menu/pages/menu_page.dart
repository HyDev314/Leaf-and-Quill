import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/menu/widgets/sign_out_button.dart';
import 'package:leaf_and_quill_app/features/menu/widgets/tool_card.dart';
import 'package:leaf_and_quill_app/features/menu/widgets/user_card.dart';
import 'package:leaf_and_quill_app/themes/theme.dart';

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  void toggleTheme(WidgetRef ref) {
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SkeletonPage(
      title: Text(
        'Mục lục',
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
              fontSize: 22,
            ),
      ),
      bodyW: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const UserCard(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Bật giao diện tối',
                        style:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  fontSize: 18,
                                ),
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: ref.watch(themeNotifierProvider.notifier).mode ==
                            ThemeMode.dark,
                        onChanged: (val) => toggleTheme(ref),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const ToolCard(
              name: 'Công cụ',
              list: [
                ExtensionItem(name: 'Dịch tiếng anh'),
                ExtensionItem(name: 'Máy tính'),
                ExtensionItem(name: 'Đồng hồ'),
              ],
            ),
            const ToolCard(
              name: 'Trợ giúp',
              list: [
                ExtensionItem(name: 'Thông Báo'),
                ExtensionItem(name: 'Chăm sóc khách hàng'),
              ],
            ),
            const Spacer(),
            const SignOutButton(),
          ],
        ),
      ),
    );
  }
}
