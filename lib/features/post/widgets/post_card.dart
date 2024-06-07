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

class PostCard extends ConsumerStatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool flag = false;

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref
        .read(postControllerProvider.notifier)
        .deletePost(context: context, post: widget.post);
  }

  void approvePost(WidgetRef ref, BuildContext context) async {
    ref
        .read(postControllerProvider.notifier)
        .approvePost(context: context, post: widget.post);
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(widget.post);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(widget.post);
  }

  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('/u/${widget.post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${widget.post.communityId}');
  }

  void navigateToPostDetails(BuildContext context) {
    Routemaster.of(context).push('/post/${widget.post.id}/details');
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider)!;

    String displayedText = widget.post.description;
    if (!flag && widget.post.description.length > 50) {
      displayedText = '${widget.post.description.substring(0, 50)}...';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: widget.post.isApprove
            ? () => navigateToPostDetails(context)
            : () {},
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ref
                    .watch(getCommunityByIdProvider(widget.post.communityId))
                    .when(
                      data: (community) => ref
                          .watch(getUserDataProvider(widget.post.uid))
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
                                            backgroundImage:
                                                NetworkImage(community.avatar),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: SizedBox(
                                          height: 30,
                                          width: 30,
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
                                            timeago
                                                .format(widget.post.createdAt),
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
                                ((community.mods.contains(currentUser.uid) ||
                                            widget.post.uid ==
                                                currentUser.uid) &&
                                        widget.post.isApprove == true)
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
                                                onPressed: () {
                                                  deletePost(ref, context);
                                                },
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
                  widget.post.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 10),
                (widget.post.link != '')
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'link: ${widget.post.link}',
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
                (widget.post.description != '')
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayedText,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(fontSize: 16),
                          ),
                          if (widget.post.description.length > 50)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  flag = !flag;
                                });
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 10, top: 5),
                                child: Text(
                                  flag ? 'Thu gọn' : 'Xem thêm',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                          fontSize: 15,
                                          color: AppPalette.mainColor),
                                ),
                              ),
                            ),
                        ],
                      )
                    : const SizedBox(),
                (widget.post.image != '')
                    ? Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: SizedBox(
                            height: 250,
                            width: double.infinity,
                            child: Image.network(
                              widget.post.image,
                              fit: BoxFit.cover,
                            )),
                      )
                    : const SizedBox(),
                (widget.post.link != '' && widget.post.image == '')
                    ? AnyLinkPreview(
                        displayDirection: UIDirection.uiDirectionHorizontal,
                        link: widget.post.link,
                      )
                    : const SizedBox(),
                const SizedBox(height: 10),
                Text(
                  widget.post.type,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontSize: 15),
                ),
                const SizedBox(height: 10),
                widget.post.isApprove
                    ? IntrinsicHeight(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(18)),
                              border: Border.all(
                                  color:
                                      AppPalette.secondColor.withOpacity(0.5),
                                  width: 1)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () => upvotePost(ref),
                                icon: Icon(
                                  Icons.thumb_up_rounded,
                                  color: widget.post.upvotes
                                          .contains(currentUser.uid)
                                      ? AppPalette.mainColor
                                      : AppPalette.secondColor,
                                ),
                              ),
                              Text(
                                '${widget.post.upvotes.length}',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(
                                      fontSize: 16,
                                    ),
                              ),
                              IconButton(
                                onPressed: () => downvotePost(ref),
                                icon: Icon(
                                  Icons.thumb_down_rounded,
                                  color: widget.post.downvotes
                                          .contains(currentUser.uid)
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
                                widget.post.commentCount.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(
                                      fontSize: 16,
                                    ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.share_rounded,
                                  color: AppPalette.secondColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(18)),
                            border: Border.all(
                                color: AppPalette.secondColor.withOpacity(0.5),
                                width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                height: 40,
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: () => deletePost(ref, context),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppPalette.greyColor),
                                  child: Text('Hủy',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(fontSize: 16)),
                                ),
                              ),
                              SizedBox(
                                height: 40,
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: () => approvePost(ref, context),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppPalette.mainColor),
                                  child: Text('Duyệt',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(fontSize: 16)),
                                ),
                              ),
                            ],
                          ),
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
