// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_whatsapp_clone/colors.dart';
import 'package:flutter_whatsapp_clone/common/widgets/error.dart';
import 'package:flutter_whatsapp_clone/common/widgets/loader.dart';
import 'package:flutter_whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:flutter_whatsapp_clone/features/call/controllers/call_controller.dart';
import 'package:flutter_whatsapp_clone/features/call/screens/call_pickup_screen.dart';
import 'package:flutter_whatsapp_clone/features/chat/widgets/bottom_chat_field.dart';
import 'package:flutter_whatsapp_clone/features/chat/widgets/chat_list.dart';
import 'package:flutter_whatsapp_clone/models/user.dart';

class MobileChatScreen extends ConsumerWidget {
  const MobileChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.profilePic,
    required this.isGroupChat,
  }) : super(key: key);
  final String name;
  final String uid;
  final String profilePic;
  final bool isGroupChat;
  static const String routeName = '/mobile-chat-screen';

  void makeCall(WidgetRef ref, BuildContext context) {
    ref.read(callControllerProvider).makeCall(
          context,
          name,
          uid,
          profilePic,
          isGroupChat,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print(uid);
    return CallPickupScreen(
      scaffold: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: isGroupChat
              ? Text(name)
              : StreamBuilder<UserModel>(
                  stream: ref.read(authControllerProvider).userDataById(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loader();
                    }
                    if (snapshot.hasError) {
                      print(snapshot.error.toString());
                      return ErrorScreen(error: snapshot.error.toString());
                    }
                    return Column(
                      children: [
                        FirebaseAuth.instance.currentUser!.uid == uid
                            ? const Text(
                                'My Cloud',
                              )
                            : Text(
                                name,
                              ),
                        Text(
                          snapshot.data!.isOnline ? 'online' : 'offline',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color:
                                  snapshot.data!.isOnline ? Colors.green : null,
                              fontSize: 13),
                        )
                      ],
                    );
                  }),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () => makeCall(ref, context),
              icon: const Icon(Icons.video_call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ChatList(
                receiverUserID: uid,
                isGroupChat: isGroupChat,
              ),
            ),
            BottomChatField(
              receiverUserId: uid,
              isGroupChat: isGroupChat,
            ),
          ],
        ),
      ),
    );
  }
}
