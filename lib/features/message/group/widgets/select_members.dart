import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';

final selectedGroupContacts = StateProvider<List<String>>((ref) => []);

class SelectMembers extends ConsumerStatefulWidget {
  const SelectMembers({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SelectMembersState();
}

class _SelectMembersState extends ConsumerState<SelectMembers> {
  List<int> selectedContactsIndex = [];

  void selectContact(int index, String uid) {
    if (selectedContactsIndex.contains(index)) {
      selectedContactsIndex.removeAt(index);
    } else {
      selectedContactsIndex.add(index);
    }
    setState(() {});
    ref.read(selectedGroupContacts.state).update((state) => [...state, uid]);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider)!;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: user.friends.length,
      itemBuilder: (context, index) {
        final friendId = user.friends[index];

        return ref.watch(getUserDataProvider(friendId)).when(
              data: (friend) => InkWell(
                onTap: () => selectContact(index, friendId),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: ListTile(
                    title: Text(
                      'u/${friend.name}',
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            fontSize: 18,
                          ),
                    ),
                    leading: selectedContactsIndex.contains(index)
                        ? IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.done),
                          )
                        : null,
                  ),
                ),
              ),
              error: (error, stackTrace) => ErrorPage(
                errorText: error.toString(),
              ),
              loading: () => const LoaderPage(),
            );
      },
    );
  }
}
