import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';

class MessagePage extends ConsumerStatefulWidget {
  const MessagePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessagePageState();
}

class _MessagePageState extends ConsumerState<MessagePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController tabBarController;
  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   switch (state) {
  //     case AppLifecycleState.resumed:
  //       ref.read(authControllerProvider).setUserState(true);
  //       break;
  //     case AppLifecycleState.inactive:
  //     case AppLifecycleState.detached:
  //     case AppLifecycleState.paused:
  //       ref.read(authControllerProvider).setUserState(false);
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SkeletonPage(
      title: Text(
        'Nhắn tin',
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
              fontSize: 22,
            ),
      ),
      bottomW: TabBar(
        controller: tabBarController,
        indicatorColor: AppPalette.mainColor,
        indicatorWeight: 4,
        labelColor: AppPalette.whiteColor,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(
            text: 'CHATS',
          ),
          Tab(
            text: 'CALLS',
          ),
        ],
      ),
      bodyW: TabBarView(
        controller: tabBarController,
        children: const [Text('Chat'), Text('Calls')],
      ),
    );
  }
}
