import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_whatsapp_clone/colors.dart';
import 'package:flutter_whatsapp_clone/common/enums/message_enum.dart';
import 'package:flutter_whatsapp_clone/common/providers/message_reply_provider.dart';
import 'package:flutter_whatsapp_clone/common/utils/utils.dart';
import 'package:flutter_whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:flutter_whatsapp_clone/features/chat/widgets/message_reply_preview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class BottomChatField extends ConsumerStatefulWidget {
  const BottomChatField({
    required this.receiverUserId,
    required this.isGroupChat,
    Key? key,
  }) : super(key: key);
  final String receiverUserId;
  final bool isGroupChat;
  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool isShowSendButton = false;

  final _messageController = TextEditingController();
  bool isShowEmoji = false;
  FocusNode focusNode = FocusNode();
  FlutterSoundRecorder? _soundRecorder;
  bool isRecorderInit = false;
  bool isRecording = false;
  bool isSendVideo = false;

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
        _messageController.text = "";
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

  void sendFileMessage(File file, MessageEnum messageEnum) {
    ref.read(chatControllerProvider).sendFileMessage(
          context,
          file,
          widget.receiverUserId,
          messageEnum,
          widget.isGroupChat,
        );
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    setState(() {
      isSendVideo = true;
    });
    const LinearProgressIndicator();
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
    setState(() {
      isSendVideo = false;
    });
  }

  void selectGIF() async {
    final gif = await pickGIF(context);
    if (gif != null) {
      // ignore: use_build_context_synchronously
      ref.read(chatControllerProvider).sendGIFMessage(
            context,
            gif.url,
            widget.receiverUserId,
            widget.isGroupChat,
          );
    }
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmoji = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmoji = true;
    });
  }

  void toggleEmojiKeybroadContainer() {
    if (isShowEmoji) {
      showKeybroad();
      hideEmojiContainer();
    } else {
      hideKeybroad();
      showEmojiContainer();
    }
  }

  void showKeybroad() => focusNode.requestFocus();

  void hideKeybroad() => focusNode.unfocus();

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
    print('messageReply: $messageReply');
    final isShowMessageReply = messageReply != null;
    return Column(
      children: [
        isShowMessageReply ? const MessageReplyReview() : const SizedBox(),
        Row(
          children: [
            Expanded(
              child: TextField(
                focusNode: focusNode,
                // onTap: () {
                //   setState(() {
                //     isShowEmoji = false;
                //   });
                // },
                controller: _messageController,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      isShowSendButton = true;
                    });
                  } else {
                    setState(() {
                      isShowSendButton = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: mobileChatBoxColor,
                  prefixIcon: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // setState(() {
                            //   isShowEmoji = true;
                            // });
                            toggleEmojiKeybroadContainer();
                          },
                          icon: const Icon(Icons.emoji_emotions),
                          color: Colors.grey,
                        ),
                        IconButton(
                          onPressed: selectGIF,
                          icon: const Icon(Icons.gif),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  suffixIcon: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.camera_alt),
                          color: Colors.grey,
                        ),
                        IconButton(
                          onPressed: selectVideo,
                          icon: const Icon(Icons.attach_file),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  hintText: 'Type a message!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
            CircleAvatar(
                backgroundColor: const Color(0xFF128C7E),
                radius: 25,
                child: GestureDetector(
                  onTap: sendTextMessage,
                  child: Icon(
                    isShowSendButton
                        ? Icons.send
                        : isRecording
                            ? Icons.close
                            : Icons.mic,
                    color: Colors.white,
                  ),
                ))
          ],
        ),
        isShowEmoji
            ? SizedBox(
                height: 310,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    setState(() {
                      _messageController.text =
                          _messageController.text + emoji.emoji;
                    });
                    if (!isShowSendButton) {
                      setState(() {
                        isShowSendButton = true;
                      });
                    }
                  },
                ),
              )
            : const SizedBox()
      ],
    );
  }
}
