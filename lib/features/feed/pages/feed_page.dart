import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/home/drawer/community_list_drawer.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SkeletonPage(
      title: const Text('Bảng tin'),
      leading: Builder(builder: (context) {
        return IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => displayDrawer(context),
        );
      }),
      drawer: const CommunityListDrawer(),
      body: const Center(
        child: Text('page 1'),
      ),
      floatingButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
