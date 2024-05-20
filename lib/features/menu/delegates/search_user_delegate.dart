import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/features/user_profile/controller/user_controller.dart';
import 'package:routemaster/routemaster.dart';

class SearchUserDelegate extends SearchDelegate {
  final WidgetRef ref;
  SearchUserDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ref.watch(searchUserProvider(query)).when(
          data: (users) => ListView.builder(
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePic),
                ),
                title: Text('u/${user.name}'),
                onTap: () => navigateToUserProfile(context, user.uid),
              );
            },
          ),
          error: (error, stackTrace) => ErrorPage(
            errorText: error.toString(),
          ),
          loading: () => const LoaderPage(),
        );
  }

  void navigateToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }
}
