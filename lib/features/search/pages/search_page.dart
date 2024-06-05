import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:leaf_and_quill_app/features/user_profile/controller/user_controller.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:routemaster/routemaster.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final searchTextController = TextEditingController();

  void navigateToCommunity(BuildContext context, String id) {
    Routemaster.of(context).push('/r/$id');
  }

  void navigateToProfile(BuildContext context, String id) {
    Routemaster.of(context).push('/u/$id');
  }

  void searchCommunityByName(WidgetRef ref, String communityName) {
    ref
        .read(communityControllerProvider.notifier)
        .searchCommunity(communityName);
  }

  void searchUserByName(WidgetRef ref, String userName) {
    ref.read(searchUserProvider(userName));
  }

  @override
  void dispose() {
    super.dispose();
    searchTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SkeletonPage(
      title: Text(
        'Tìm kiếm ',
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
              fontSize: 22,
            ),
      ),
      bodyW: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 60,
                      child: Icon(
                        Icons.search_rounded,
                        size: 30,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: searchTextController,
                        onSubmitted: (value) => setState(() {
                          searchCommunityByName(ref, value);
                          searchUserByName(ref, value);
                        }),
                        style:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  fontSize: 18,
                                ),
                        cursorColor: Colors.blue,
                        decoration: InputDecoration.collapsed(
                          border: InputBorder.none,
                          hintText: 'Tìm kiếm',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                  fontSize: 18, color: AppPalette.greyColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            (searchTextController.text == '')
                ? ref.watch(getSuggestCommunityPostsProvider).when(
                      data: (communities) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cộng đồng nổi bật',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(
                                    fontSize: 20,
                                  ),
                            ),
                            const SizedBox(height: 15),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: communities.length,
                              itemBuilder: (BuildContext context, int index) {
                                final community = communities[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(community.avatar),
                                      ),
                                      title: Text(
                                        community.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge!
                                            .copyWith(
                                              fontSize: 18,
                                            ),
                                      ),
                                      trailing: Text(
                                        '${community.members.length} members',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .copyWith(
                                              fontSize: 16,
                                            ),
                                      ),
                                      onTap: () => navigateToCommunity(
                                          context, community.id),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      error: (error, stackTrace) => ErrorPage(
                        errorText: error.toString(),
                      ),
                      loading: () => const LoaderPage(),
                    )
                : const SizedBox(),
            ref.watch(searchCommunityProvider(searchTextController.text)).when(
                  data: (communities) {
                    if (communities.isEmpty) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cộng đồng',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                                  fontSize: 20,
                                ),
                          ),
                          const SizedBox(height: 15),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: communities.length,
                            itemBuilder: (BuildContext context, int index) {
                              final community = communities[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(community.avatar),
                                    ),
                                    title: Text(
                                      community.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .copyWith(
                                            fontSize: 18,
                                          ),
                                    ),
                                    trailing: Text(
                                      '${community.members.length} members',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .copyWith(
                                            fontSize: 16,
                                          ),
                                    ),
                                    onTap: () => navigateToCommunity(
                                        context, community.id),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  error: (error, stackTrace) => ErrorPage(
                    errorText: error.toString(),
                  ),
                  loading: () => const LoaderPage(),
                ),
            ref.watch(searchUserProvider(searchTextController.text)).when(
                  data: (users) {
                    if (users.isEmpty) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Người dùng',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                                  fontSize: 20,
                                ),
                          ),
                          const SizedBox(height: 15),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: users.length,
                            itemBuilder: (BuildContext context, int index) {
                              final user = users[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(user.profilePic),
                                    ),
                                    title: Text(
                                      user.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .copyWith(
                                            fontSize: 18,
                                          ),
                                    ),
                                    trailing: Text('100 points',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(fontSize: 14)),
                                    onTap: () =>
                                        navigateToProfile(context, user.uid),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
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
