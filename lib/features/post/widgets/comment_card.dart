import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/models/comment_model.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:routemaster/routemaster.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentCard extends ConsumerWidget {
  final CommentModel comment;
  const CommentCard({super.key, required this.comment});

  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('/u/${comment.userId}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ref.watch(getUserDataProvider(comment.userId)).when(
                    data: (user) {
                      return Row(
                        children: [
                          SizedBox(
                            height: 30,
                            width: 30,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundImage: NetworkImage(user.profilePic),
                            ),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () => navigateToUser(
                              context,
                            ),
                            child: Text(
                              'u/${user.name}',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(
                                    fontSize: 16,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            timeago.format(comment.createdAt),
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                  fontSize: 14,
                                ),
                          ),
                        ],
                      );
                    },
                    error: (error, stackTrace) {
                      return ErrorPage(
                        errorText: error.toString(),
                      );
                    },
                    loading: () => const LoaderPage(),
                  ),
              const SizedBox(height: 10),
              Text(
                comment.text,
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      fontSize: 16,
                    ),
              ),
              (comment.image != '')
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.network(comment.image),
                    )
                  : const SizedBox(),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                      onPressed: () {},
                      child: Text("Trả lời",
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(
                                  fontSize: 14, color: AppPalette.greyColor))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
