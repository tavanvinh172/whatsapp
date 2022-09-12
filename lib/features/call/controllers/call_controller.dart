// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:flutter_whatsapp_clone/features/call/repository/call_repository.dart';
import 'package:flutter_whatsapp_clone/models/call.dart';
import 'package:uuid/uuid.dart';

final callControllerProvider = Provider<CallController>((ref) {
  final callRepository = ref.read(callRepositoryProvider);
  return CallController(
      callRepository: callRepository, ref: ref, auth: FirebaseAuth.instance);
});

class CallController {
  final CallRepository callRepository;
  final ProviderRef ref;
  final FirebaseAuth auth;
  CallController({
    required this.callRepository,
    required this.ref,
    required this.auth,
  });

  Stream<DocumentSnapshot> get callStream => callRepository.callStream;

  void makeCall(BuildContext context, String receiverName, String receiverUid,
      String receiverProfilePic, bool isGroupChat) {
    ref.read(userDataAuthProvider).whenData((value) {
      String callId = const Uuid().v1();
      Call senderCallData = Call(
        callerId: auth.currentUser!.uid,
        callerName: value!.name,
        callerPic: value.profilePic,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPic: receiverProfilePic,
        callId: callId,
        hasDialled: true,
      );
      Call receiverCallData = Call(
        callerId: auth.currentUser!.uid,
        callerName: value.name,
        callerPic: value.profilePic,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPic: receiverProfilePic,
        callId: callId,
        hasDialled: false,
      );
      callRepository.makeCall(
        senderCallData,
        context,
        receiverCallData,
      );
    });
  }
}
