import 'package:flutter/material.dart';
import 'package:leaf_and_quill_app/core/enums/enums.dart';
import 'package:leaf_and_quill_app/features/message/chat/widgets/video_player_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';

class DisplayTextImageGIF extends StatelessWidget {
  final String message;
  final MessageEnum type;
  final bool isMe;
  const DisplayTextImageGIF({
    super.key,
    required this.message,
    required this.type,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    final AudioPlayer audioPlayer = AudioPlayer();

    return type == MessageEnum.text
        ? Text(
            message,
            style: isMe
                ? Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontSize: 18,
                    )
                : Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontSize: 18,
                    ),
          )
        : type == MessageEnum.audio
            ? StatefulBuilder(builder: (context, setState) {
                return IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 100,
                  ),
                  onPressed: () async {
                    if (isPlaying) {
                      await audioPlayer.pause();
                      setState(() {
                        isPlaying = false;
                      });
                    } else {
                      await audioPlayer.play(UrlSource(message));
                      setState(() {
                        isPlaying = true;
                      });
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                  ),
                );
              })
            : type == MessageEnum.video
                ? VideoPlayerItem(
                    videoUrl: message,
                  )
                : SizedBox(
                    height: 200,
                    child: CachedNetworkImage(
                      imageUrl: message,
                    ),
                  );
  }
}
