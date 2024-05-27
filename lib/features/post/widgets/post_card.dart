import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:leaf_and_quill_app/features/post/controller/post_controller.dart';
import 'package:leaf_and_quill_app/models/post_model.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:routemaster/routemaster.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends ConsumerWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref
        .read(postControllerProvider.notifier)
        .deletePost(context: context, post: post);
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(post);
  }

  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityId}');
  }

  void navigateToPostDetails(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/details');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userProvider)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => navigateToPostDetails(context),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ref.watch(getCommunityByIdProvider(post.communityId)).when(
                      data: (community) => ref
                          .watch(getUserDataProvider(post.uid))
                          .when(
                            data: (user) => Row(
                              children: [
                                SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        child: SizedBox(
                                          height: 45,
                                          width: 45,
                                          child: CircleAvatar(
                                            radius: 10,
                                            backgroundImage:
                                                NetworkImage(community.avatar),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: SizedBox(
                                          height: 35,
                                          width: 35,
                                          child: CircleAvatar(
                                            radius: 10,
                                            backgroundImage:
                                                NetworkImage(user.profilePic),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () =>
                                            navigateToCommunity(context),
                                        child: Text(
                                          community.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge!
                                              .copyWith(
                                                fontSize: 20,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () =>
                                                navigateToUser(context),
                                            child: Text(
                                              user.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayLarge!
                                                  .copyWith(
                                                    fontSize: 16,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            timeago.format(post.createdAt),
                                            style: Theme.of(context)
                                                .textTheme
                                                .displaySmall!
                                                .copyWith(
                                                  fontSize: 14,
                                                ),
                                            overflow: TextOverflow.fade,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                (community.mods.contains(currentUser.uid) ||
                                        post.uid == currentUser.uid)
                                    ? IconButton(
                                        onPressed: () => showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: Text(
                                                'Xác nhận xóa bài viết ?',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge!
                                                    .copyWith(
                                                      fontSize: 22,
                                                    )),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () =>
                                                    Routemaster.of(context)
                                                        .pop(),
                                                child: Text('Thoát',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall!
                                                        .copyWith(
                                                          fontSize: 18,
                                                        )),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    deletePost(ref, context),
                                                child: Text('Xác nhận',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall!
                                                        .copyWith(
                                                          fontSize: 18,
                                                        )),
                                              ),
                                            ],
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          color: AppPalette.secondColor,
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                            error: (error, stackTrace) =>
                                ErrorPage(errorText: error.toString()),
                            loading: () => const LoaderPage(),
                          ),
                      error: (error, stackTrace) =>
                          ErrorPage(errorText: error.toString()),
                      loading: () => const LoaderPage(),
                    ),
                const SizedBox(height: 15),
                Text(
                  post.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 10),
                (post.link != '')
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'link: ${post.link}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(
                                fontSize: 16,
                              ),
                        ),
                      )
                    : const SizedBox(),
                (post.description != '')
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          post.description,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(
                                fontSize: 16,
                              ),
                        ),
                      )
                    : const SizedBox(),
                (post.image != '')
                    ? Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: SizedBox(
                            height: 250,
                            width: double.infinity,
                            child: Image.network(
                              post.image,
                              fit: BoxFit.cover,
                            )),
                      )
                    : const SizedBox(),
                (post.link != '' && post.image == '')
                    ? AnyLinkPreview(
                        displayDirection: UIDirection.uiDirectionHorizontal,
                        link: post.link,
                      )
                    : const SizedBox(),
                const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => upvotePost(ref),
                        icon: Icon(
                          Icons.thumb_up_rounded,
                          color: post.upvotes.contains(currentUser.uid)
                              ? AppPalette.mainColor
                              : AppPalette.secondColor,
                        ),
                      ),
                      Text(
                        '${post.upvotes.length}',
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  fontSize: 16,
                                ),
                      ),
                      IconButton(
                        onPressed: () => downvotePost(ref),
                        icon: Icon(
                          Icons.thumb_down_rounded,
                          color: post.downvotes.contains(currentUser.uid)
                              ? AppPalette.redColor
                              : AppPalette.secondColor,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                        child: VerticalDivider(
                          color: AppPalette.greyColor,
                          thickness: 1,
                        ),
                      ),
                      IconButton(
                        onPressed: () => navigateToPostDetails(context),
                        icon: const Icon(
                          Icons.comment_rounded,
                          color: AppPalette.secondColor,
                        ),
                      ),
                      Text(
                        post.commentCount.toString(),
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  fontSize: 16,
                                ),
                      ),
                      const SizedBox(width: 10)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
