import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:leaf_and_quill_app/features/feed/drawer/community_list_drawer.dart';
import 'package:leaf_and_quill_app/features/post/controller/post_controller.dart';
import 'package:leaf_and_quill_app/features/post/widgets/post_card.dart';
import 'package:leaf_and_quill_app/models/community_model.dart';
import 'package:leaf_and_quill_app/themes/theme.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:routemaster/routemaster.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _hasFetchedInitialPosts = false;

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void navigateToAddPost(BuildContext context) {
    Routemaster.of(context).push('/add-post');
  }

  void navigateToMessage(BuildContext context) {
    Routemaster.of(context).push('/m');
  }

  Future<void> _onRefresh(
      WidgetRef ref, List<CommunityModel> communities) async {
    await ref.read(postControllerProvider.notifier).refreshPosts(communities);
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading(
      WidgetRef ref, List<CommunityModel> communities) async {
    _hasFetchedInitialPosts = true;
    await ref.read(postControllerProvider.notifier).fetchMorePosts(communities);
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider)!;
    final currentTheme = ref.watch(themeNotifierProvider);

    return SkeletonPage(
      title: Text(
        'Bảng tin',
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
              fontSize: 22,
            ),
      ),
      leadingW: Builder(builder: (context) {
        return IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => displayDrawer(context),
        );
      }),
      drawerW: const CommunityListDrawer(),
      actionWs: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
              onPressed: () => navigateToMessage(context),
              icon: Icon(
                Icons.chat_outlined,
                color: currentTheme.textTheme.displaySmall!.color,
                size: 30,
              )),
        ),
      ],
      bodyW: ref.watch(userCommunitiesProvider(user.uid)).when(
            data: (communities) {
              if (communities.isNotEmpty) {
                if (!_hasFetchedInitialPosts) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref
                        .read(postControllerProvider.notifier)
                        .fetchInitialPosts(communities);
                  });
                }
                final posts = ref.watch(postControllerProvider);

                return SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  enablePullUp:
                      ref.read(postControllerProvider.notifier).hasMore,
                  onRefresh: () => _onRefresh(ref, communities),
                  onLoading: () => _onLoading(ref, communities),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(right: 5, left: 5, top: 15),
                    itemCount: posts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final post = posts[index];
                      return PostCard(post: post);
                    },
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    'Hãy tham gia một cộng đồng!',
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          fontSize: 20,
                        ),
                  ),
                );
              }
            },
            error: (error, stackTrace) => ErrorPage(
              errorText: error.toString(),
            ),
            loading: () => const LoaderPage(),
          ),
      floatingButtonW: FloatingActionButton(
        onPressed: () => navigateToAddPost(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
