import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:leaf_and_quill_app/core/enums/enums.dart';
import 'package:leaf_and_quill_app/core/providers/message_reply_provider.dart';
import 'package:leaf_and_quill_app/core/utils/pick_image.dart';
import 'package:leaf_and_quill_app/features/message/chat/controller/chat_controller.dart';
import 'package:leaf_and_quill_app/features/message/chat/widgets/message_reply_preview.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:leaf_and_quill_app/themes/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatField extends ConsumerStatefulWidget {
  final String receiverUserId;
  final bool isGroupChat;

  const ChatField({
    super.key,
    required this.receiverUserId,
    required this.isGroupChat,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatFieldState();
}

class _ChatFieldState extends ConsumerState<ChatField> {
  bool isShowSendButton = false;
  final TextEditingController _messageController = TextEditingController();
  FlutterSoundRecorder? _soundRecorder;
  bool isRecorderInit = false;
  bool isShowEmojiContainer = false;
  bool isRecording = false;
  FocusNode focusNode = FocusNode();
  File? imageFile;
  File? videoFile;

  @override
  void initState() {
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    openAudio();
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic permission not allowed!');
    }
    await _soundRecorder!.openRecorder();
    isRecorderInit = true;
  }

  void sendTextMessage() async {
    if (isShowSendButton) {
      ref.read(chatControllerProvider).sendTextMessage(
            context,
            _messageController.text.trim(),
            widget.receiverUserId,
            widget.isGroupChat,
          );
      setState(() {
        _messageController.text = '';
      });
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';
      if (!isRecorderInit) {
        return;
      }
      if (isRecording) {
        await _soundRecorder!.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecorder!.startRecorder(
          toFile: path,
        );
      }

      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void sendFileMessage(
    File file,
    MessageEnum messageEnum,
  ) {
    ref.read(chatControllerProvider).sendFileMessage(
          context,
          file,
          widget.receiverUserId,
          messageEnum,
          widget.isGroupChat,
        );
  }

  void selectImage() async {
    final image = await pickImage();

    if (image != null) {
      setState(() {
        imageFile = File(image.files.first.path!);
      });
      sendFileMessage(imageFile!, MessageEnum.image);
    }
  }

  void selectVideo() async {
    final video = await pickVideo();

    if (video != null) {
      setState(() {
        videoFile = File(video.files.first.path!);
      });
      sendFileMessage(videoFile!, MessageEnum.video);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _soundRecorder!.closeRecorder();
    isRecorderInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(messageReplyProvider);
    final isShowMessageReply = messageReply != null;
    final currentTheme = ref.watch(themeNotifierProvider);

    return Column(
      children: [
        isShowMessageReply
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: MessageReplyPreview(),
              )
            : const SizedBox(),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  focusNode: focusNode,
                  controller: _messageController,
                  onChanged: (val) {
                    if (val.isNotEmpty) {
                      setState(() {
                        isShowSendButton = true;
                      });
                    } else {
                      setState(() {
                        isShowSendButton = false;
                      });
                    }
                  },
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontSize: 18,
                      ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: currentTheme.cardColor,
                    suffixIcon: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: selectImage,
                            icon: const Icon(
                              Icons.image_rounded,
                              color: AppPalette.greyColor,
                            ),
                          ),
                          IconButton(
                            onPressed: selectVideo,
                            icon: const Icon(
                              Icons.video_camera_back_rounded,
                              color: AppPalette.greyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    hintText: 'Type a message!',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide:
                          const BorderSide(width: 1, style: BorderStyle.solid),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                onPressed: sendTextMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.mainColor,
                  shape: const CircleBorder(),
                ),
                icon: Icon(
                  isShowSendButton
                      ? Icons.send
                      : isRecording
                          ? Icons.close
                          : Icons.mic,
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
