import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:leaf_and_quill_app/features/post/controller/post_controller.dart';
import 'package:leaf_and_quill_app/features/post/widgets/post_card.dart';
import 'package:leaf_and_quill_app/models/community_model.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:routemaster/routemaster.dart';

class CommunityPage extends ConsumerStatefulWidget {
  final String id;
  const CommunityPage({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _hasFetchedInitialPosts = false;

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/$widget.id');
  }

  void joinCommunity(
      WidgetRef ref, CommunityModel community, BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .joinCommunity(community, context);
  }

  Future<void> _onRefresh(WidgetRef ref, String id) async {
    await ref.read(postControllerProvider.notifier).refreshCommunityPosts(id);
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading(WidgetRef ref, String id) async {
    _hasFetchedInitialPosts = true;
    await ref.read(postControllerProvider.notifier).fetchMoreCommunityPosts(id);
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;

    return ref.watch(getCommunityByIdProvider(widget.id)).when(
          data: (community) {
            if (!_hasFetchedInitialPosts) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(postControllerProvider.notifier)
                    .fetchInitialCommunityPosts(widget.id);
              });
            }
            final posts = ref.watch(postControllerProvider);

            return SkeletonPage(
              title: const SizedBox(),
              backgroundImage: Image.network(
                community.banner,
                fit: BoxFit.cover,
              ),
              leadingW: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () {
                    Routemaster.of(context).history.back();
                  }),
              bodyW: SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: ref.read(postControllerProvider.notifier).hasMore,
                onRefresh: () => _onRefresh(ref, widget.id),
                onLoading: () => _onLoading(ref, widget.id),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(community.avatar),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('r/${community.name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .copyWith(fontSize: 20)),
                                  const SizedBox(height: 5),
                                  Text('${community.members.length} members',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .copyWith(fontSize: 16)),
                                ],
                              ),
                            ),
                            const Spacer(),
                            community.mods.contains(user.uid)
                                ? OutlinedButton(
                                    onPressed: () =>
                                        navigateToModTools(context),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                    ),
                                    child: Text('Mod Tools',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge!
                                            .copyWith(fontSize: 14)),
                                  )
                                : OutlinedButton(
                                    onPressed: () =>
                                        joinCommunity(ref, community, context),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25),
                                    ),
                                    child: Text(
                                        community.members.contains(user.uid)
                                            ? 'Joined'
                                            : 'Join',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge!
                                            .copyWith(fontSize: 14)),
                                  ),
                          ],
                        ),
                      ),
                      (community.description != '')
                          ? Text('Mô tả về cộng đồng',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(fontSize: 18))
                          : const SizedBox(),
                      (community.description != '')
                          ? Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(community.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(fontSize: 16)),
                            )
                          : const SizedBox(),
                      Divider(
                        color: AppPalette.greyColor.withOpacity(0.5),
                        thickness: 1,
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text('Bài viết',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(fontSize: 18)),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (BuildContext context, int index) {
                          final post = posts[index];
                          return PostCard(post: post);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          error: (error, stackTrace) => ErrorPage(errorText: error.toString()),
          loading: () => const LoaderPage(),
        );
  }
}
