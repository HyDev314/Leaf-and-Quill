import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/config/constants/constants.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/core/enums/enums.dart';
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

  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0;

  late PostEnum? postType;

  _scrollListener() {
    setState(() {
      _scrollPosition = _scrollController.position.pixels;
    });
  }

  @override
  void initState() {
    postType = null;
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/${widget.id}');
  }

  void navigateToApprovePost(BuildContext context) {
    Routemaster.of(context).push('/approve-posts/${widget.id}');
  }

  void joinCommunity(
      WidgetRef ref, CommunityModel community, BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .joinCommunity(community, context);
  }

  Future<void> _onRefresh(WidgetRef ref, String id) async {
    _hasFetchedInitialPosts = true;
    if (postType != null) {
      await ref
          .read(communityPostControllerProvider.notifier)
          .refreshCommunityPosts(id: id, isApprove: true, type: postType!.type);
    } else {
      await ref
          .read(communityPostControllerProvider.notifier)
          .refreshCommunityPosts(id: id, isApprove: true);
    }
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading(WidgetRef ref, String id) async {
    _hasFetchedInitialPosts = true;
    if (postType != null) {
      await ref
          .read(communityPostControllerProvider.notifier)
          .fetchMoreCommunityPosts(
              id: id, isApprove: true, type: postType!.type);
    } else {
      await ref
          .read(communityPostControllerProvider.notifier)
          .fetchMoreCommunityPosts(id: id, isApprove: true);
    }
    _refreshController.loadComplete();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;

    return ref.watch(getCommunityByIdProvider(widget.id)).when(
          data: (community) {
            if (!_hasFetchedInitialPosts) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(communityPostControllerProvider.notifier)
                    .fetchInitialCommunityPosts(id: widget.id, isApprove: true);
              });
            }
            final posts = ref.watch(communityPostControllerProvider);

            double appBarOpacity = _scrollPosition / 150;
            if (appBarOpacity > 1) appBarOpacity = 1;

            return SkeletonPage(
              title: AnimatedOpacity(
                opacity: _scrollPosition > 150 ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(community.avatar),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(community.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(fontSize: 16)),
                            const SizedBox(height: 2),
                            Text('${community.members.length} members',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(fontSize: 14)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              backgroundImage: Image.network(
                community.banner,
                fit: BoxFit.cover,
              ),
              leadingW: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () {
                    Routemaster.of(context).history.back();
                  }),
              actionWs: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: AnimatedOpacity(
                    opacity: _scrollPosition > 150 ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: (community.admin == user.uid)
                        ? OutlinedButton(
                            onPressed: () => navigateToModTools(context),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                            ),
                            child: Text('Cài đặt',
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                            ),
                            child: Text(
                                community.members.contains(user.uid)
                                    ? 'Đã tham gia'
                                    : 'Tham gia',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(fontSize: 14)),
                          ),
                  ),
                ),
              ],
              bodyW: SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp:
                    ref.read(communityPostControllerProvider.notifier).hasMore,
                onRefresh: () => _onRefresh(ref, widget.id),
                onLoading: () => _onLoading(ref, widget.id),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
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
                            Expanded(
                              child: SizedBox(
                                width: 200,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(community.name,
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
                            ),
                            (community.admin == user.uid)
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
                                    child: Text('Cài đặt',
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
                                          horizontal: 15),
                                    ),
                                    child: Text(
                                        community.members.contains(user.uid)
                                            ? 'Đã tham gia'
                                            : 'Tham gia',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge!
                                            .copyWith(fontSize: 14)),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    if (community.description.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, top: 5),
                          child: Text(community.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(fontSize: 14)),
                        ),
                      ),
                    if (community.mods.contains(user.uid))
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, top: 10, right: 200),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => navigateToApprovePost(context),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppPalette.greyColor),
                              child: Text('Bài viết cần duyệt',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(fontSize: 16)),
                            ),
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Divider(
                        color: AppPalette.greyColor.withOpacity(0.5),
                        thickness: 1,
                        height: 30,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 55,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(5),
                          scrollDirection: Axis.horizontal,
                          itemCount: AppConstants.topics.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    postType = AppConstants.topics[index].type;
                                  });
                                  _onRefresh(ref, widget.id);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(AppConstants.topics[index].text,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall!
                                              .copyWith(fontSize: 14)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: Text('Bài viết',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(fontSize: 18)),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 10),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final post = posts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: PostCard(post: post),
                          );
                        },
                        childCount: posts.length,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          error: (error, stackTrace) => ErrorPage(errorText: error.toString()),
          loading: () => const LoaderPage(),
        );
  }
}
