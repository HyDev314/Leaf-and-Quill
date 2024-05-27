import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/enums/enums.dart';
import 'package:leaf_and_quill_app/features/message/chat/widgets/display_text_image_gif.dart';
import 'package:leaf_and_quill_app/info.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../../core/common/loader.dart';
import '../../../auth/controller/auth_controller.dart';

class SenderMessageCard extends ConsumerWidget {
  const SenderMessageCard({
    super.key,
    required this.message,
    required this.date,
    required this.type,
    required this.onRightSwipe,
    required this.repliedText,
    required this.username,
    required this.repliedMessageType,
    required this.senderId,
  });

  final String message;
  final String date;
  final MessageEnum type;
  final String senderId;
  final Function(DragUpdateDetails) onRightSwipe;
  final String repliedText;
  final String username;
  final MessageEnum repliedMessageType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReplying = repliedText.isNotEmpty;

    return SwipeTo(
      onRightSwipe: onRightSwipe,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ref.read(getUserDataProvider(senderId)).when(
                  data: (sender) => Padding(
                    padding: const EdgeInsets.only(top: 5, left: 5),
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(sender.profilePic),
                        radius: 30,
                      ),
                    ),
                  ),
                  error: (error, stackTrace) => ErrorPage(
                    errorText: error.toString(),
                  ),
                  loading: () => const LoaderPage(),
                ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 45,
                minWidth: MediaQuery.of(context).size.width * 0.3,
              ),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Stack(
                  children: [
                    Padding(
                      padding: type == MessageEnum.text
                          ? const EdgeInsets.only(
                              left: 10,
                              right: 30,
                              top: 10,
                              bottom: 25,
                            )
                          : const EdgeInsets.only(
                              left: 10,
                              top: 10,
                              right: 10,
                              bottom: 30,
                            ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isReplying) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: backgroundColor.withOpacity(0.5),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                    5,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(
                                          fontSize: 16,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  DisplayTextImageGIF(
                                    message: repliedText,
                                    type: repliedMessageType,
                                    isMe: false,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          DisplayTextImageGIF(
                            message: message,
                            type: type,
                            isMe: false,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 10,
                      child: Text(
                        date,
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge!
                            .copyWith(
                                fontSize: 13, color: AppPalette.greyColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
