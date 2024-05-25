import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/message/chat/widgets/contacts_list.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:routemaster/routemaster.dart';

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

  void navigateToSelectContacts(BuildContext context) {
    Routemaster.of(context).push('/select-contacts');
  }

  void navigateToCreateGroup(BuildContext context) {
    Routemaster.of(context).push('/create_group');
  }

  @override
  Widget build(BuildContext context) {
    return SkeletonPage(
      title: const SizedBox(),
      leadingW: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Routemaster.of(context).history.back();
          }),
      actionWs: [
        IconButton(
          icon: const Icon(
            Icons.search,
            size: 30,
          ),
          onPressed: () {},
        ),
        PopupMenuButton(
          icon: const Icon(
            Icons.more_vert,
            size: 30,
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text(
                'Tạo nhóm',
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      fontSize: 20,
                    ),
              ),
              onTap: () => navigateToCreateGroup(context),
            )
          ],
        ),
      ],
      bottomW: TabBar(
        controller: tabBarController,
        indicatorColor: AppPalette.mainColor,
        indicatorWeight: 2,
        labelColor: AppPalette.mainColor,
        unselectedLabelColor: AppPalette.greyColor,
        labelStyle: Theme.of(context).textTheme.displayLarge!.copyWith(
              fontSize: 20,
            ),
        tabs: const [
          Tab(
            text: 'Tin nhắn',
          ),
          Tab(
            text: 'Cuộc gọi',
          ),
        ],
      ),
      bodyW: TabBarView(
        controller: tabBarController,
        children: const [ContactsList(), Center(child: Text('Calls'))],
      ),
      floatingButtonW: FloatingActionButton(
        onPressed: () => navigateToSelectContacts(context),
        child: const Icon(
          Icons.chat_outlined,
          size: 30,
        ),
      ),
    );
  }
}
