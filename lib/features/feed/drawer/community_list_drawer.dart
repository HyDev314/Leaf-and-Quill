import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:leaf_and_quill_app/models/community_model.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunity(BuildContext context, CommunityModel community) {
    Routemaster.of(context).push('/r/${community.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(userProvider)!;
    return Drawer(
      width: 250,
      shape: const BeveledRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            ListTile(
              title: Text('Tạo cộng đồng mới',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontSize: 18)),
              leading: const Icon(Icons.add),
              onTap: () => navigateToCreateCommunity(context),
            ),
            Divider(
              color: AppPalette.greyColor.withOpacity(0.3),
              thickness: 1,
              height: 10,
            ),
            ref.watch(userCommunitiesProvider(currentUser.uid)).when(
                  data: (communities) => Expanded(
                    child: (communities.isNotEmpty)
                        ? ListView.builder(
                            itemCount: communities.length,
                            itemBuilder: (BuildContext context, int index) {
                              final community = communities[index];
                              return ListTile(
                                leading: SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(community.avatar),
                                  ),
                                ),
                                title: Text(community.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(fontSize: 18)),
                                onTap: () {
                                  navigateToCommunity(context, community);
                                },
                              );
                            },
                          )
                        : Center(
                            child: Text('Hãy tạo cộng đồng của bạn!',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(fontSize: 18)),
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
