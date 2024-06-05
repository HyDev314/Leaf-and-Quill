import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:leaf_and_quill_app/features/feed/drawer/community_list_drawer.dart';
import 'package:leaf_and_quill_app/features/post/controller/post_controller.dart';
import 'package:leaf_and_quill_app/features/post/widgets/hot_feeds_card.dart';
import 'package:leaf_and_quill_app/features/post/widgets/post_card.dart';
import 'package:leaf_and_quill_app/models/community_model.dart';
import 'package:leaf_and_quill_app/models/post_model.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:leaf_and_quill_app/themes/theme.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final PageController _pageController = PageController();
  bool _hasFetchedInitialPosts = false;
  late List<PostModel> posts;

  @override
  void initState() {
    posts = [];
    super.initState();
  }

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
    await ref
        .read(feedPostControllerProvider.notifier)
        .refreshPosts(communities);
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading(
      WidgetRef ref, List<CommunityModel> communities) async {
    _hasFetchedInitialPosts = true;
    await ref
        .read(feedPostControllerProvider.notifier)
        .fetchMorePosts(communities);
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(userProvider)!.uid;
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
                Icons.chat_bubble_outline_rounded,
                color: currentTheme.textTheme.displaySmall!.color,
                size: 30,
              )),
        ),
      ],
      bodyW: ref.watch(userCommunitiesProvider(uid)).when(
            data: (communities) {
              if (communities.isNotEmpty) {
                if (!_hasFetchedInitialPosts) {
                  ref
                      .watch(feedPostControllerProvider.notifier)
                      .fetchInitialPosts(communities);
                }

                posts = ref.read(feedPostControllerProvider);

                return SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  enablePullUp:
                      ref.watch(feedPostControllerProvider.notifier).hasMore,
                  onRefresh: () => _onRefresh(ref, communities),
                  onLoading: () => _onLoading(ref, communities),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: ref.read(getHotNewsProvider(communities)).when(
                              data: (hotNews) {
                                if (hotNews.isNotEmpty) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, left: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Bài viết nổi bật',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayLarge!
                                                  .copyWith(
                                                    fontSize: 18,
                                                  ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(
                                              Icons
                                                  .local_fire_department_rounded,
                                              color: AppPalette.redColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 180,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 10),
                                        child: PageView.builder(
                                          controller: _pageController,
                                          itemCount: hotNews.length,
                                          itemBuilder: (context, index) {
                                            return HotFeedsCard(
                                                post: hotNews[index]);
                                          },
                                        ),
                                      ),
                                      Center(
                                        child: SmoothPageIndicator(
                                          controller: _pageController,
                                          count: hotNews.length,
                                          effect: WormEffect(
                                            dotHeight: 10,
                                            dotWidth: 10,
                                            dotColor: AppPalette.greyColor
                                                .withOpacity(0.5),
                                            activeDotColor:
                                                AppPalette.mainColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return const SizedBox();
                              },
                              error: (error, stackTrace) => ErrorPage(
                                errorText: error.toString(),
                              ),
                              loading: () => const LoaderPage(),
                            ),
                      ),
                      SliverToBoxAdapter(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          itemBuilder: (BuildContext context, int index) {
                            final post = posts[index];
                            return PostCard(post: post);
                          },
                        ),
                      ),
                    ],
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
