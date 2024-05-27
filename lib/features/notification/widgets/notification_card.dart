import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/notification/controller/notification_controller.dart';
import 'package:leaf_and_quill_app/features/post/controller/post_controller.dart';
import 'package:leaf_and_quill_app/models/notification_model.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:routemaster/routemaster.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends ConsumerWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  void navigateToPostDetails(BuildContext context, String postId) {
    Routemaster.of(context).push('/post/$postId/details');
  }

  void markReadNotificationAsRead(
      WidgetRef ref, BuildContext context, String notificationId) async {
    ref
        .read(notificationControllerProvider.notifier)
        .markReadNotificationAsRead(
            context: context, notificationId: notificationId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getCommentByIdProvider(notification.commentId)).when(
          data: (comment) => ref
              .watch(getUserDataProvider(comment.userId))
              .when(
                data: (user) => GestureDetector(
                  onTap: () {
                    markReadNotificationAsRead(ref, context, notification.id);
                    navigateToPostDetails(context, comment.postId);
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  timeago.format(notification.createdAt),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                        fontSize: 16,
                                      ),
                                ),
                                const SizedBox(height: 5),
                                (comment.image != '')
                                    ? RichText(
                                        text: TextSpan(
                                          text: user.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge!
                                              .copyWith(
                                                  fontSize: 18,
                                                  color: AppPalette.mainColor),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text:
                                                  " đã bình luận ở một bài viết của bạn bằng một hình ảnh. ",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      )
                                    : RichText(
                                        text: TextSpan(
                                          text: user.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge!
                                              .copyWith(
                                                  fontSize: 18,
                                                  color: AppPalette.mainColor),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text:
                                                  " đã bình luận ở một bài viết của bạn với nội dung: ",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(fontSize: 18),
                                            ),
                                            TextSpan(
                                              text: ' " ${comment.text} " ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayLarge!
                                                  .copyWith(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          notification.isRead
                              ? const SizedBox()
                              : const Icon(Icons.new_releases_outlined,
                                  color: AppPalette.redColor, size: 30),
                        ],
                      ),
                    ),
                  ),
                ),
                error: (error, stackTrace) {
                  return ErrorPage(errorText: error.toString());
                },
                loading: () => const LoaderPage(),
              ),
          error: (error, stackTrace) {
            return ErrorPage(errorText: error.toString());
          },
          loading: () => const LoaderPage(),
        );
  }
}
