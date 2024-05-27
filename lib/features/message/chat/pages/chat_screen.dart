import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/features/message/chat/widgets/chat_field.dart';
import 'package:leaf_and_quill_app/features/message/group/controller/group_controller.dart';
import 'package:routemaster/routemaster.dart';

import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/message/chat/widgets/chat_list.dart';

class ChatScreen extends ConsumerWidget {
  final String id;
  final bool isGroupChat;
  const ChatScreen({
    super.key,
    required this.id,
    required this.isGroupChat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SkeletonPage(
      title: isGroupChat
          ? ref.read(getGroupByIdProvider(id)).when(
                data: (group) => Row(
                  children: [
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(group.groupPic),
                        radius: 30,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        group.name,
                        overflow: TextOverflow.fade,
                        style:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  fontSize: 20,
                                ),
                      ),
                    ),
                  ],
                ),
                error: (error, stackTrace) => ErrorPage(
                  errorText: error.toString(),
                ),
                loading: () => const LoaderPage(),
              )
          : ref.read(getUserDataProvider(id)).when(
                data: (contact) => Row(
                  children: [
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(contact.profilePic),
                        radius: 30,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        contact.name,
                        overflow: TextOverflow.fade,
                        style:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  fontSize: 20,
                                ),
                      ),
                    ),
                  ],
                ),
                error: (error, stackTrace) => ErrorPage(
                  errorText: error.toString(),
                ),
                loading: () => const LoaderPage(),
              ),
      leadingW: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Routemaster.of(context).history.back();
          }),
      actionWs: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.videocam_rounded, size: 30),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.call_rounded, size: 30),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
        ),
      ],
      bodyW: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: ChatList(
              receiverUserId: id,
              isGroupChat: isGroupChat,
            ),
          ),
          ChatField(
            receiverUserId: id,
            isGroupChat: isGroupChat,
          ),
        ],
      ),
    );
  }
}
