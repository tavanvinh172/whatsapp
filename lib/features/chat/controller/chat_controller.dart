import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_whatsapp_clone/common/enums/message_enum.dart';
import 'package:flutter_whatsapp_clone/common/providers/message_reply_provider.dart';
import 'package:flutter_whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:flutter_whatsapp_clone/features/chat/repository/chat_repository.dart';
import 'package:flutter_whatsapp_clone/models/chat_contact.dart';
import 'package:flutter_whatsapp_clone/models/group.dart';
import 'package:flutter_whatsapp_clone/models/message.dart';

final chatControllerProvider = Provider<ChatController>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(
    chatRepository: chatRepository,
    ref: ref,
  );
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;

  ChatController({
    required this.chatRepository,
    required this.ref,
  });

  void sendTextMessage(
    BuildContext context,
    String text,
    String receiverUserId,
    bool isGroupChat,
  ) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendTextMessage(
            context: context,
            text: text,
            receiverUserId: receiverUserId,
            senderUser: value!,
            messageReply: messageReply,
            isGroupChat: isGroupChat,
          ),
        );
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  Stream<List<ChatContact>> chatContacts() {
    return chatRepository.getChatContact();
  }

  Stream<List<Group>> chatGroups() {
    return chatRepository.getChatGroups();
  }

  Stream<List<Message>> chatStream(String receiverUserId) {
    return chatRepository.getChatStream(receiverUserId);
  }

  Stream<List<Message>> groupChatStream(String groupId) {
    return chatRepository.getGroupChatStream(groupId);
  }

  void sendFileMessage(
    BuildContext context,
    File file,
    String receiverUserId,
    MessageEnum messageEnum,
    bool isGroupChat,
  ) {
    final messageReply = ref.read(messageReplyProvider);

    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendFileMessage(
            context: context,
            file: file,
            receiverUserId: receiverUserId,
            senderUserData: value!,
            messageEnum: messageEnum,
            ref: ref,
            isGroupChat: isGroupChat,
            messageReply: messageReply,
          ),
        );
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void sendGIFMessage(
    BuildContext context,
    String gifUrl,
    String receiverUserId,
    bool isGroupChat,
  ) {
    final messageReply = ref.read(messageReplyProvider);

    // https://giphy.com/gifs/justviralnet-funny-kitten-sleepy-YTETMtpsueseikztWR
    // https://i.giphy.com/media/YTETMtpsueseikztWR/200.gif
    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
    String gifUrlPath = gifUrl.substring(gifUrlPartIndex);
    String newgifUrl = 'https://i.giphy.com/media/$gifUrlPath/200.gif';

    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendGIFMessage(
            context: context,
            gifUrl: newgifUrl,
            receiverUserId: receiverUserId,
            senderUser: value!,
            isGroupChat: isGroupChat,
            messageReply: messageReply,
          ),
        );
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  Stream<List<ChatContact>> getCurrentContactList() {
    return chatRepository.getCurrentContactList();
  }

  void setChatMessageSeen(
      BuildContext context, String receiverUserId, String messageId) {
    chatRepository.setChatMessageSeen(context, receiverUserId, messageId);
  }
}
