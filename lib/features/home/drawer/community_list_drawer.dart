import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:leaf_and_quill_app/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunity(BuildContext context, CommunityModel community) {
    Routemaster.of(context).push('/r/${community.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      width: 250,
      shape: BeveledRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            ListTile(
              title: Text('Create a community',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontSize: 18)),
              leading: const Icon(Icons.add),
              onTap: () {},
            ),
            ref.watch(userCommunitiesProvider).when(
                  data: (communities) => Expanded(
                    child: ListView.builder(
                      itemCount: communities.length,
                      itemBuilder: (BuildContext context, int index) {
                        final community = communities[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(community.avatar),
                          ),
                          title: Text('r/${community.name}'),
                          onTap: () {
                            navigateToCommunity(context, community);
                          },
                        );
                      },
                    ),
                  ),
                  error: (error, stackTrace) => ErrorPage(
                    errorText: error.toString(),
                  ),
                  loading: () => const LoaderPage(),
                ),
          ],
        ),
      ),
    );
  }
}
