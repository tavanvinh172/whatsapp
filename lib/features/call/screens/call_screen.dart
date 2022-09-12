// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_whatsapp_clone/common/widgets/loader.dart';
import 'package:flutter_whatsapp_clone/config/agora_config.dart';

import 'package:flutter_whatsapp_clone/models/call.dart';

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({
    required this.channelId,
    required this.call,
    required this.isGroupChat,
    Key? key,
  }) : super(key: key);
  final String channelId;
  final Call call;
  final bool isGroupChat;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  AgoraClient? client;
  String baseUrl = 'https://whatsapp-clone-flutter.herokuapp.com';
  @override
  void initState() {
    super.initState();
    client = AgoraClient(
        agoraConnectionData: AgoraConnectionData(
      appId: AgoraConfig.appId,
      channelName: widget.channelId,
      tokenUrl: baseUrl,
    ));
    initAgora();
  }

  void initAgora() async {
    await client!.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: client == null
          ? const Loader()
          : SafeArea(
              child: Stack(
                children: [
                  AgoraVideoViewer(client: client!),
                  AgoraVideoButtons(client: client!),
                ],
              ),
            ),
    );
  }
}
