import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:routemaster/routemaster.dart';

class UserCard extends ConsumerWidget {
  const UserCard({super.key});

  void navigateToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          onTap: () => navigateToUserProfile(context, user.uid),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundImage: NetworkImage(user.profilePic),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'u/${user.name}',
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          fontSize: 18,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
