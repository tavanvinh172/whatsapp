// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_whatsapp_clone/common/widgets/error.dart';
import 'package:flutter_whatsapp_clone/common/widgets/loader.dart';
import 'package:flutter_whatsapp_clone/features/call/controllers/call_controller.dart';
import 'package:flutter_whatsapp_clone/features/call/screens/call_screen.dart';
import 'package:flutter_whatsapp_clone/models/call.dart';

class CallPickupScreen extends ConsumerWidget {
  const CallPickupScreen({
    required this.scaffold,
    Key? key,
  }) : super(key: key);
  final Widget scaffold;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ref.watch(callControllerProvider).callStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        if (snapshot.hasError) {
          return ErrorScreen(error: snapshot.error.toString());
        }
        if (snapshot.hasData && snapshot.data!.data() != null) {
          Call call =
              Call.fromMap(snapshot.data!.data() as Map<String, dynamic>);
          if (!call.hasDialled) {
            return Scaffold(
              body: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                          call.callerPic,
                        ),
                        opacity: 0.2)),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(),
                    ),
                    const Text(
                      'Incoming Call',
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    CircleAvatar(
                      backgroundImage: NetworkImage(call.callerPic),
                      radius: 60,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Text(
                      call.callerName,
                      style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.call_end,
                              color: Colors.redAccent,
                              size: 30,
                            )),
                        const SizedBox(
                          width: 25,
                        ),
                        IconButton(
                            onPressed: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return CallScreen(
                                    channelId: call.callId,
                                    call: call,
                                    isGroupChat: false,
                                  );
                                })),
                            icon: const Icon(
                              Icons.call,
                              color: Colors.green,
                              size: 30,
                            ))
                      ],
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(),
                    ),
                  ],
                ),
              ),
            );
          }
        }
        return scaffold;
      },
    );
  }
}
