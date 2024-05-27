import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:routemaster/routemaster.dart';

class SelectContactsPage extends ConsumerWidget {
  const SelectContactsPage({super.key});

  void navigateToChat(BuildContext context, String id) {
    Routemaster.of(context).push('/chat/$id/false');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider)!;

    return SkeletonPage(
        title: Text(
          'Thêm liên lạc',
          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                fontSize: 22,
              ),
        ),
        leadingW: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Routemaster.of(context).history.back();
            }),
        actionWs: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              size: 30,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              size: 30,
            ),
          ),
        ],
        bodyW: ListView.builder(
          itemCount: user.friends.length,
          itemBuilder: (context, index) {
            final friendId = user.friends[index];

            return ref.watch(getUserDataProvider(friendId)).when(
                  data: (friend) => InkWell(
                    onTap: () => navigateToChat(context, friendId),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: ListTile(
                        title: Text(
                          friend.name,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                fontSize: 20,
                              ),
                        ),
                        leading: SizedBox(
                          height: 45,
                          width: 45,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(friend.profilePic),
                            radius: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                  error: (error, stackTrace) => ErrorPage(
                    errorText: error.toString(),
                  ),
                  loading: () => const LoaderPage(),
                );
          },
        ));
  }
}
