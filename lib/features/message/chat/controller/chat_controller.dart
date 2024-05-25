import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/enums/enums.dart';
import 'package:leaf_and_quill_app/core/providers/message_reply_provider.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/message/chat/repository/chat_repository.dart';
import 'package:leaf_and_quill_app/models/message/chat_contact_model.dart';
import 'package:leaf_and_quill_app/models/message/group_model.dart';
import 'package:leaf_and_quill_app/models/message/message_model.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(
    chatRepository: chatRepository,
    ref: ref,
  );
});

class ChatController extends StateNotifier<bool> {
  final ChatRepository _chatRepository;
  final ProviderRef _ref;

  ChatController(
      {required ChatRepository chatRepository, required ProviderRef ref})
      : _chatRepository = chatRepository,
        _ref = ref,
        super(false);

  Stream<List<ChatContactModel>> chatContacts() {
    return _chatRepository.getChatContacts();
  }

  Stream<List<GroupModel>> chatGroups() {
    return _chatRepository.getChatGroups();
  }

  Stream<List<MessageModel>> chatStream(String receiverUserId) {
    return _chatRepository.getChatStream(receiverUserId);
  }

  Stream<List<MessageModel>> groupChatStream(String groupId) {
    return _chatRepository.getGroupChatStream(groupId);
  }

  void sendTextMessage(
    BuildContext context,
    String text,
    String receiverUserId,
    bool isGroupChat,
  ) {
    state = true;
    final messageReply = _ref.read(messageReplyProvider);
    final user = _ref.read(userProvider)!;

    _chatRepository.sendTextMessage(
      context: context,
      text: text,
      receiverUserId: receiverUserId,
      senderUser: user,
      messageReply: messageReply,
      isGroupChat: isGroupChat,
    );
    _ref.read(messageReplyProvider.state).update((state) => null);
    state = false;
  }

  void sendFileMessage(
    BuildContext context,
    File file,
    String receiverUserId,
    MessageEnum messageEnum,
    bool isGroupChat,
  ) {
    state = true;
    final messageReply = _ref.read(messageReplyProvider);
    final user = _ref.read(userProvider)!;

    _chatRepository.sendFileMessage(
      context: context,
      file: file,
      receiverUserId: receiverUserId,
      senderUserData: user,
      messageEnum: messageEnum,
      ref: _ref,
      messageReply: messageReply,
      isGroupChat: isGroupChat,
    );
    _ref.read(messageReplyProvider.state).update((state) => null);
    state = false;
  }

  void setChatMessageSeen(
    BuildContext context,
    String receiverUserId,
    String messageId,
  ) {
    _chatRepository.setChatMessageSeen(
      context,
      receiverUserId,
      messageId,
    );
  }
}
