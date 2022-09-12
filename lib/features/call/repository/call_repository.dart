// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_whatsapp_clone/common/utils/utils.dart';
import 'package:flutter_whatsapp_clone/features/call/screens/call_screen.dart';
import 'package:flutter_whatsapp_clone/models/call.dart';

final callRepositoryProvider = Provider<CallRepository>((ref) {
  return CallRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

class CallRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  CallRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<DocumentSnapshot> get callStream =>
      firestore.collection('call').doc(auth.currentUser!.uid).snapshots();

  void makeCall(
      Call senderCallData, BuildContext context, Call receiverCallData) async {
    try {
      await firestore
          .collection('call')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());
      await firestore
          .collection('call')
          .doc(senderCallData.receiverId)
          .set(senderCallData.toMap());

      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return CallScreen(
          channelId: senderCallData.callId,
          call: senderCallData,
          isGroupChat: false,
        );
      }));
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
