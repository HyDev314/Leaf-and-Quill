import 'dart:io';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/core/utils/pick_image.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:leaf_and_quill_app/features/post/controller/post_controller.dart';
import 'package:leaf_and_quill_app/features/post/pages/full_screen_image_page.dart';
import 'package:leaf_and_quill_app/features/post/widgets/comment_card.dart';
import 'package:leaf_and_quill_app/models/post_model.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:routemaster/routemaster.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailsPage extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailsPage({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PostDetailsPageState();
}

class _PostDetailsPageState extends ConsumerState<PostDetailsPage> {
  final commentController = TextEditingController();
  bool _isError = false;
  File? imageFile;

  void selectCommentImage() async {
    final image = await pickImage();

    if (image != null) {
      setState(() {
        imageFile = File(image.files.first.path!);
      });
    }
  }

  void deletePost(WidgetRef ref, BuildContext context, PostModel post) async {
    ref
        .read(postControllerProvider.notifier)
        .deletePost(context: context, post: post);
  }

  void upvotePost(WidgetRef ref, PostModel post) async {
    ref.read(postControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref, PostModel post) async {
    ref.read(postControllerProvider.notifier).downvote(post);
  }

  void navigateToUser(BuildContext context, PostModel post) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context, PostModel post) {
    Routemaster.of(context).push('/r/${post.communityId}');
  }

  void fullImage(BuildContext context, String imageUrl) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FullScreenImage(imageUrl: imageUrl);
    }));
  }

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(PostModel post) {
    ref.read(postControllerProvider.notifier).addComment(
          context: context,
          text: commentController.text.trim(),
          file: imageFile,
          post: post,
        );
    setState(() {
      commentController.text = '';
      imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider)!;

    return SkeletonPage(
      title: const SizedBox(),
      leadingW: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Routemaster.of(context).history.back();
          }),
      bodyW: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (post) {
              if (post.isDeleted) {
                return Center(
                  child: Text(
                    'Bài viết này đã bị xóa!',
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          fontSize: 20,
                        ),
                  ),
                );
              } else {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ref
                          .watch(getCommunityByIdProvider(post.communityId))
                          .when(
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
                                                height: 40,
                                                width: 40,
                                                child: CircleAvatar(
                                                  radius: 10,
                                                  backgroundImage: NetworkImage(
                                                      community.avatar),
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
                                                  backgroundImage: NetworkImage(
                                                      user.profilePic),
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
                                              onTap: () => navigateToCommunity(
                                                  context, post),
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
                                                  onTap: () => navigateToUser(
                                                      context, post),
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
                                                  timeago
                                                      .format(post.createdAt),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displaySmall!
                                                      .copyWith(
                                                        fontSize: 14,
                                                      ),
                                                  overflow: TextOverflow.fade,
                                                  maxLines: 1,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // if (post.uid == currentUser.uid)
                                      //   IconButton(
                                      //     onPressed: () {},
                                      //     icon: const Icon(
                                      //       Icons.info_outline_rounded,
                                      //       color: AppPalette.secondColor,
                                      //     ),
                                      //   ),
                                      ref
                                          .watch(getCommunityByIdProvider(
                                              post.communityId))
                                          .when(
                                            data: (data) {
                                              if (data.mods.contains(
                                                      currentUser.uid) ||
                                                  post.uid == currentUser.uid) {
                                                return IconButton(
                                                  onPressed: () =>
                                                      showDialog<String>(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        AlertDialog(
                                                      title: Text(
                                                          'Xác nhận xóa bài viết ?',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .displayLarge!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        22,
                                                                  )),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () =>
                                                              Routemaster.of(
                                                                      context)
                                                                  .pop(),
                                                          child: Text('Thoát',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .displaySmall!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        18,
                                                                  )),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            deletePost(ref,
                                                                context, post);
                                                            Routemaster.of(
                                                                    context)
                                                                .history
                                                                .back();
                                                          },
                                                          child: Text(
                                                              'Xác nhận',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .displaySmall!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        18,
                                                                  )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.close_rounded,
                                                    color:
                                                        AppPalette.secondColor,
                                                  ),
                                                );
                                              }
                                              return const SizedBox();
                                            },
                                            error: (error, stackTrace) =>
                                                ErrorPage(
                                              errorText: error.toString(),
                                            ),
                                            loading: () => const LoaderPage(),
                                          ),
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
                        style:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  fontSize: 18,
                                ),
                      ),
                      const SizedBox(height: 10),
                      (post.description != '')
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                post.description,
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
                              child: GestureDetector(
                                  onTap: () => fullImage(context, post.image),
                                  child: Image.network(post.image)),
                            )
                          : const SizedBox(),
                      (post.link != '' && post.image == '')
                          ? AnyLinkPreview(
                              displayDirection:
                                  UIDirection.uiDirectionHorizontal,
                              link: post.link,
                            )
                          : const SizedBox(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            post.type,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                  fontSize: 15,
                                ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => upvotePost(ref, post),
                            icon: Icon(
                              Icons.thumb_up_rounded,
                              color: post.upvotes.contains(currentUser.uid)
                                  ? AppPalette.mainColor
                                  : AppPalette.secondColor,
                            ),
                          ),
                          Text(
                            '${post.upvotes.length}',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                  fontSize: 16,
                                ),
                          ),
                          IconButton(
                            onPressed: () => downvotePost(ref, post),
                            icon: Icon(
                              Icons.thumb_down_rounded,
                              color: post.downvotes.contains(currentUser.uid)
                                  ? AppPalette.redColor
                                  : AppPalette.secondColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.share_rounded,
                              color: AppPalette.secondColor,
                            ),
                          ),
                        ],
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: commentController,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .copyWith(
                                        fontSize: 18,
                                      ),
                                  onSubmitted: (val) {
                                    setState(() {
                                      _isError = commentController.text.isEmpty;
                                    });
                                    if (!_isError) {
                                      addComment(post);
                                    }
                                  },
                                  cursorColor: Colors.blue,
                                  decoration: InputDecoration.collapsed(
                                    border: InputBorder.none,
                                    hintText: 'Suy nghĩ của bạn?',
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge!
                                        .copyWith(
                                            fontSize: 18,
                                            color: AppPalette.greyColor),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.image_outlined,
                                    size: 20,
                                    color: AppPalette.greyColor,
                                  ),
                                  onPressed: selectCommentImage,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.navigate_next_rounded,
                                  size: 20,
                                  color: AppPalette.greyColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isError = commentController.text.isEmpty;
                                  });
                                  if (!_isError) {
                                    addComment(post);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      imageFile != null
                          ? SizedBox(
                              height: 100,
                              child: Image.file(
                                imageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(height: 10),
                      ref.watch(getPostCommentsProvider(widget.postId)).when(
                            data: (data) {
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final comment = data[index];
                                  return CommentCard(comment: comment);
                                },
                              );
                            },
                            error: (error, stackTrace) {
                              return ErrorPage(
                                errorText: error.toString(),
                              );
                            },
                            loading: () => const LoaderPage(),
                          ),
                    ],
                  ),
                );
              }
            },
            error: (error, stackTrace) {
              return ErrorPage(
                errorText: error.toString(),
              );
            },
            loading: () => const LoaderPage(),
          ),
    );
  }
}
