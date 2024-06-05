import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:leaf_and_quill_app/models/post_model.dart';
import 'package:routemaster/routemaster.dart';

class HotFeedsCard extends ConsumerStatefulWidget {
  final PostModel post;
  const HotFeedsCard({
    super.key,
    required this.post,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HotFeedsCardState();
}

class _HotFeedsCardState extends ConsumerState<HotFeedsCard> {
  void navigateToPostDetails(BuildContext context) {
    Routemaster.of(context).push('/post/${widget.post.id}/details');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateToPostDetails(context),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ref
                        .watch(
                            getCommunityByIdProvider(widget.post.communityId))
                        .when(
                          data: (community) => ref
                              .watch(getUserDataProvider(widget.post.uid))
                              .when(
                                data: (user) => Row(
                                  children: [
                                    SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            child: SizedBox(
                                              height: 30,
                                              width: 30,
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
                                              height: 25,
                                              width: 25,
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
                                          Text(
                                            community.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge!
                                                .copyWith(
                                                  fontSize: 18,
                                                ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(
                                                user.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge!
                                                    .copyWith(
                                                      fontSize: 14,
                                                    ),
                                              ),
                                              const SizedBox(width: 5),
                                              Flexible(
                                                child: Text(
                                                  timeago.format(
                                                      widget.post.createdAt),
                                                  maxLines: 1,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displaySmall!
                                                      .copyWith(
                                                        fontSize: 14,
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
                    const SizedBox(height: 10),
                    Text(
                      widget.post.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(height: 5),
                    (widget.post.link != '')
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              'link: ${widget.post.link}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(
                                    fontSize: 16,
                                  ),
                            ),
                          )
                        : const SizedBox(),
                    (widget.post.description != '' && widget.post.link == '')
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              widget.post.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(fontSize: 16),
                            ),
                          )
                        : const SizedBox(),
                    const Spacer(),
                    Text(
                      widget.post.type,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall!
                          .copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              (widget.post.link != '' || widget.post.image != '')
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox(
                        height: 120,
                        width: 120,
                        child: (widget.post.image != '')
                            ? Image.network(
                                widget.post.image,
                                fit: BoxFit.cover,
                              )
                            : (widget.post.link != '' &&
                                    widget.post.image == '')
                                ? AnyLinkPreview(
                                    displayDirection:
                                        UIDirection.uiDirectionHorizontal,
                                    link: widget.post.link,
                                  )
                                : const SizedBox(),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
