import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/post/controller/post_controller.dart';
import 'package:leaf_and_quill_app/features/post/widgets/post_card.dart';
import 'package:leaf_and_quill_app/features/user_profile/controller/user_controller.dart';
import 'package:leaf_and_quill_app/models/user_model.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:routemaster/routemaster.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _hasFetchedInitialPosts = false;

  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0;

  _scrollListener() {
    setState(() {
      _scrollPosition = _scrollController.position.pixels;
    });
  }

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  void addFriend(WidgetRef ref, UserModel userModel, BuildContext context) {
    ref
        .read(userProfileControllerProvider.notifier)
        .addFriend(userModel, context);
  }

  void navigateToEditUser(BuildContext context, String uid) {
    Routemaster.of(context).push('/edit-profile/$uid');
  }

  Future<void> _onRefresh(WidgetRef ref, String uid) async {
    await ref.read(userPostControllerProvider.notifier).refreshUserPosts(uid);
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading(WidgetRef ref, String uid) async {
    _hasFetchedInitialPosts = true;
    await ref.read(userPostControllerProvider.notifier).fetchMoreUserPosts(uid);
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
    final currentUser = ref.watch(userProvider)!;

    return ref.watch(getUserDataProvider(widget.uid)).when(
          data: (user) {
            if (!_hasFetchedInitialPosts) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(userPostControllerProvider.notifier)
                    .fetchInitialUserPosts(widget.uid);
              });
            }
            final posts = ref.watch(userPostControllerProvider);

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
                        backgroundImage: NetworkImage(user.profilePic),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge!
                            .copyWith(fontSize: 16)),
                    const Spacer(),
                    const Icon(
                      Icons.verified,
                      color: AppPalette.mainColor,
                      size: 30,
                    )
                  ],
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
                    ref.read(userPostControllerProvider.notifier).hasMore,
                onRefresh: () => _onRefresh(ref, widget.uid),
                onLoading: () => _onLoading(ref, widget.uid),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Stack(
                          children: [
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                border: Border.all(
                                    color: AppPalette.lightCardColor, width: 2),
                                image: DecorationImage(
                                    image: NetworkImage(user.banner),
                                    fit: BoxFit.cover),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20, left: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: CircleAvatar(
                                          backgroundColor:
                                              AppPalette.lightCardColor,
                                          child: SizedBox(
                                            height: 45,
                                            width: 45,
                                            child: CircleAvatar(
                                              backgroundImage:
                                                  NetworkImage(user.profilePic),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(18)),
                                            color: AppPalette.greyColor
                                                .withOpacity(0.5)),
                                        child: Text(user.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge!
                                                .copyWith(fontSize: 20)),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.verified,
                                        color: AppPalette.mainColor,
                                        size: 30,
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(18)),
                                        color: AppPalette.greyColor
                                            .withOpacity(0.5)),
                                    child: Text('100 points',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(fontSize: 14)),
                                  ),
                                ],
                              ),
                            ),
                            (currentUser.uid == widget.uid)
                                ? Positioned(
                                    bottom: 5,
                                    right: 5,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        backgroundColor: AppPalette.greyColor
                                            .withOpacity(0.8),
                                      ),
                                      onPressed: () => navigateToEditUser(
                                          context, currentUser.uid),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 40,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${user.friends.length} bạn bè',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .copyWith(fontSize: 16)),
                                ],
                              ),
                            ),
                            (currentUser.uid != widget.uid)
                                ? OutlinedButton(
                                    onPressed: () =>
                                        addFriend(ref, user, context),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25),
                                    ),
                                    child: Text(
                                        user.friends.contains(currentUser.uid)
                                            ? 'Bạn bè'
                                            : 'Kết bạn',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge!
                                            .copyWith(fontSize: 14)),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                        child: (user.description != '')
                            ? Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text('Mô tả',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge!
                                        .copyWith(fontSize: 16)),
                              )
                            : const SizedBox()),
                    SliverToBoxAdapter(
                        child: (user.description != '')
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    top: 5, bottom: 5, left: 10),
                                child: Text(user.description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(fontSize: 16)),
                              )
                            : const SizedBox()),
                    SliverToBoxAdapter(
                      child: Divider(
                        color: AppPalette.greyColor.withOpacity(0.5),
                        thickness: 1,
                        height: 30,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text('Bài viết',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(fontSize: 20)),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(5),
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
              ),
            );
          },
          error: (error, stackTrace) => ErrorPage(errorText: error.toString()),
          loading: () => const LoaderPage(),
        );
  }
}
