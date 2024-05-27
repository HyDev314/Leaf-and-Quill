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

  void addFriend(WidgetRef ref, UserModel userModel, BuildContext context) {
    ref
        .read(userProfileControllerProvider.notifier)
        .addFriend(userModel, context);
  }

  void navigateToEditUser(BuildContext context, String uid) {
    Routemaster.of(context).push('/edit-profile/$uid');
  }

  void navigateToAddPost(BuildContext context) {
    Routemaster.of(context).push('/add-post');
  }

  Future<void> _onRefresh(WidgetRef ref, String uid) async {
    await ref.read(postControllerProvider.notifier).refreshUserPosts(uid);
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading(WidgetRef ref, String uid) async {
    _hasFetchedInitialPosts = true;
    await ref.read(postControllerProvider.notifier).fetchMoreUserPosts(uid);
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider)!;

    return ref.watch(getUserDataProvider(widget.uid)).when(
          data: (user) {
            if (!_hasFetchedInitialPosts) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(postControllerProvider.notifier)
                    .fetchInitialUserPosts(widget.uid);
              });
            }
            final posts = ref.watch(postControllerProvider);
            return SkeletonPage(
              title: const SizedBox(),
              leadingW: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () {
                    Routemaster.of(context).history.back();
                  }),
              bodyW: SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: ref.read(postControllerProvider.notifier).hasMore,
                onRefresh: () => _onRefresh(ref, widget.uid),
                onLoading: () => _onLoading(ref, widget.uid),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              image: DecorationImage(
                                  image: NetworkImage(user.banner),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 110, left: 20),
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(user.profilePic),
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .copyWith(fontSize: 20)),
                                  const SizedBox(height: 5),
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
                      const SizedBox(height: 20),
                      (user.description != '')
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text('Mô tả',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .copyWith(fontSize: 18)),
                            )
                          : const SizedBox(),
                      (user.description != '')
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  top: 5, bottom: 20, left: 10),
                              child: Text(user.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(fontSize: 16)),
                            )
                          : const SizedBox(),
                      (currentUser.uid == widget.uid)
                          ? ElevatedButton(
                              onPressed: () =>
                                  navigateToEditUser(context, currentUser.uid),
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(250, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  )),
                              child: Text('Chỉnh sửa trang cá nhân',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(fontSize: 18)),
                            )
                          : const SizedBox(),
                      Divider(
                        color: AppPalette.greyColor.withOpacity(0.5),
                        thickness: 1,
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text('Bài viết',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(fontSize: 20)),
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
              floatingButtonW: FloatingActionButton(
                onPressed: () => navigateToAddPost(context),
                child: const Icon(Icons.add),
              ),
            );
          },
          error: (error, stackTrace) => ErrorPage(errorText: error.toString()),
          loading: () => const LoaderPage(),
        );
  }
}
