// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:flutter_whatsapp_clone/common/enums/message_enum.dart';
import 'package:flutter_whatsapp_clone/common/providers/message_reply_provider.dart';
import 'package:flutter_whatsapp_clone/common/widgets/error.dart';
import 'package:flutter_whatsapp_clone/common/widgets/loader.dart';
import 'package:flutter_whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:flutter_whatsapp_clone/features/chat/widgets/my_message_card.dart';
import 'package:flutter_whatsapp_clone/features/chat/widgets/sender_message_card.dart';
import 'package:flutter_whatsapp_clone/models/message.dart';

class ChatList extends ConsumerStatefulWidget {
  const ChatList({
    required this.receiverUserID,
    required this.isGroupChat,
    Key? key,
  }) : super(key: key);
  final String receiverUserID;
  final bool isGroupChat;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  void onMessageSwipe(String message, bool isMe, MessageEnum messageEnum) {
    ref
        .read(messageReplyProvider.state)
        .update((state) => MessageReply(message, isMe, messageEnum));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
        stream: widget.isGroupChat
            ? ref
                .read(chatControllerProvider)
                .groupChatStream(widget.receiverUserID)
            : ref
                .read(chatControllerProvider)
                .chatStream(widget.receiverUserID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          if (snapshot.hasError) {
            return ErrorScreen(error: snapshot.error.toString());
          }

          SchedulerBinding.instance.addPostFrameCallback((_) {
            scrollController.jumpTo(
              scrollController.position.maxScrollExtent,
            );
          });

          return ListView.builder(
            controller: scrollController,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final messageData = snapshot.data![index];
              if (!messageData.isSeen &&
                  messageData.receiverId ==
                      FirebaseAuth.instance.currentUser!.uid) {
                ref.read(chatControllerProvider).setChatMessageSeen(
                    context, widget.receiverUserID, messageData.messageId);
              }
              if (messageData.senderId ==
                  FirebaseAuth.instance.currentUser!.uid) {
                return MyMessageCard(
                  message: messageData.text,
                  type: messageData.type,
                  date: DateFormat.Hm().format(messageData.timeSent),
                  repliedText: messageData.repliedMessage,
                  username: messageData.repliedTo,
                  repliedMessageType: messageData.repliedMessageType,
                  onLeftSwipe: () =>
                      onMessageSwipe(messageData.text, true, messageData.type),
                  isSeen: messageData.isSeen,
                );
              } else {
                return SenderMessageCard(
                  type: messageData.type,
                  message: messageData.text,
                  date: DateFormat.Hm().format(messageData.timeSent),
                  repliedText: messageData.repliedMessage,
                  username: messageData.repliedTo,
                  repliedMessageType: messageData.repliedMessageType,
                  onRightSwipe: () =>
                      onMessageSwipe(messageData.text, false, messageData.type),
                );
              }
            },
          );
        });
  }
}
