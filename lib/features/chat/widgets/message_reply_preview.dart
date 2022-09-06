import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_whatsapp_clone/common/providers/message_reply_provider.dart';
import 'package:flutter_whatsapp_clone/features/chat/widgets/display_text_image_gif.dart';

class MessageReplyReview extends ConsumerWidget {
  const MessageReplyReview({Key? key}) : super(key: key);

  void cancelReply(WidgetRef ref) {
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReply = ref.watch(messageReplyProvider);
    ref.listen<MessageReply?>(messageReplyProvider, (previous, next) {
      print('message changes: ${next!.messageEnum}');
    });
    return Container(
      width: 350,
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  messageReply!.isMe
                      ? 'You\'re replying yourself '
                      : 'Replying to ${messageReply.message}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                child: const Icon(
                  Icons.close,
                  size: 16,
                ),
                onTap: () => cancelReply(ref),
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          DisplayTextGIF(
              message: messageReply.message, type: messageReply.messageEnum)
        ],
      ),
    );
  }
}
