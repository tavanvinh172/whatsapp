import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_whatsapp_clone/common/repository/common_firebase_storage_repository.dart';
import 'package:flutter_whatsapp_clone/common/utils/utils.dart';
import 'package:flutter_whatsapp_clone/features/auth/screens/otp_screen.dart';
import 'package:flutter_whatsapp_clone/features/auth/screens/user_information_screen.dart';
import 'package:flutter_whatsapp_clone/models/user.dart';
import 'package:flutter_whatsapp_clone/screens/mobile_layout_screen.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
      auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance);
});

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({required this.auth, required this.firestore});

  Future<UserModel?> getCurrentUserData() async {
    var userData =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();
    UserModel? user;
    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }

  void signInWithPhone(
    String phoneNumber,
    BuildContext context,
  ) async {
    try {
      await auth.verifyPhoneNumber(
          verificationCompleted: (PhoneAuthCredential credential) async {
            await auth.signInWithCredential(credential);
          },
          phoneNumber: phoneNumber,
          verificationFailed: (e) {
            throw Exception(e.message);
          },
          codeSent: (verificationId, int? resendingToken) {
            Navigator.pushNamed(context, OTPScreen.routeName,
                arguments: verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {});
    } on FirebaseException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void verifyOTP(
      {required BuildContext context,
      required String verificationId,
      required String userOTP}) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOTP);
      await auth.signInWithCredential(credential);
      Navigator.pushNamedAndRemoveUntil(
          context, UserInformationScreen.routeName, (route) => false);
    } on FirebaseException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void saveUserDataToFirebase(
      {required String name,
      required File? profilePic,
      required ProviderRef ref,
      required BuildContext context}) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl =
          'https://images.unsplash.com/photo-1661698048572-95812cdcf44b?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwxNXx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60';
      if (profilePic != null) {
        photoUrl = await ref
            .read(conmmonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase('profilePics/$uid', profilePic);
      }
      var user = UserModel(
          name: name,
          uid: uid,
          profilePic: photoUrl,
          isOnline: false,
          phoneNumber: auth.currentUser!.phoneNumber!,
          groupId: []);
      await firestore.collection('users').doc(uid).set(user.toMap());

      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return const MobileLayoutScreen();
      }), (route) => false);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<UserModel> userData(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((event) => UserModel.fromMap(
              event.data()!,
            ));
  }

  void setUserState(bool isOnline) async {
    firestore.collection('users').doc(auth.currentUser!.uid).update(
      {
        'isOnline': isOnline,
      },
    );
  }
}
