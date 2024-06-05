import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:leaf_and_quill_app/features/post/controller/post_controller.dart';
import 'package:leaf_and_quill_app/features/post/widgets/post_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:routemaster/routemaster.dart';

class ApprovePostScreen extends ConsumerStatefulWidget {
  final String id;
  const ApprovePostScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ApprovePostScreenState();
}

class _ApprovePostScreenState extends ConsumerState<ApprovePostScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _hasFetchedInitialPosts = false;

  Future<void> _onRefresh(WidgetRef ref, String id) async {
    await ref
        .read(communityPostControllerProvider.notifier)
        .refreshCommunityPosts(id: id, isApprove: false);
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading(WidgetRef ref, String id) async {
    _hasFetchedInitialPosts = true;
    await ref
        .read(communityPostControllerProvider.notifier)
        .fetchMoreCommunityPosts(id: id, isApprove: false);
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(getCommunityByIdProvider(widget.id)).when(
          data: (community) {
            if (!_hasFetchedInitialPosts) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(communityPostControllerProvider.notifier)
                    .fetchInitialCommunityPosts(
                        id: widget.id, isApprove: false);
              });
            }
            final posts = ref.watch(communityPostControllerProvider);

            return SkeletonPage(
              title: Text(
                'Bài viết cần duyệt',
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontSize: 22,
                    ),
              ),
              leadingW: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () {
                    Routemaster.of(context).history.back();
                  }),
              bodyW: SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp:
                    ref.read(communityPostControllerProvider.notifier).hasMore,
                onRefresh: () => _onRefresh(ref, widget.id),
                onLoading: () => _onLoading(ref, widget.id),
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  itemCount: posts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final post = posts[index];
                    return PostCard(post: post);
                  },
                ),
              ),
            );
          },
          error: (error, stackTrace) => ErrorPage(errorText: error.toString()),
          loading: () => const LoaderPage(),
        );
  }
}
