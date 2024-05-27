import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/providers/message_reply_provider.dart';
import 'package:leaf_and_quill_app/features/message/chat/widgets/display_text_image_gif.dart';

class MessageReplyPreview extends ConsumerWidget {
  const MessageReplyPreview({Key? key}) : super(key: key);

  void cancelReply(WidgetRef ref) {
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReply = ref.watch(messageReplyProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Trả lời tin nhắn ',
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          fontSize: 16,
                        ),
                  ),
                ),
                GestureDetector(
                  child: const Icon(
                    Icons.close,
                    size: 25,
                  ),
                  onTap: () => cancelReply(ref),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DisplayTextImageGIF(
              message: messageReply!.message,
              type: messageReply.messageEnum,
              isMe: false,
            ),
          ],
        ),
      ),
    );
  }
}
