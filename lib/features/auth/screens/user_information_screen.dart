import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_whatsapp_clone/common/utils/utils.dart';
import 'package:flutter_whatsapp_clone/features/auth/controller/auth_controller.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  const UserInformationScreen({Key? key}) : super(key: key);
  static const String routeName = '/user-information';

  @override
  ConsumerState<UserInformationScreen> createState() =>
      _UserInformationScreenState();
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen> {
  final nameController = TextEditingController();
  File? image;
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  void storeUserData() async {
    String name = nameController.text.trim();
    if (name.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .saveUserDataToFirebase(context, name, image);
    }
  }

  void showDialogPickerImage(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      'Take a picture',
                      textAlign: TextAlign.center,
                    )),
                onTap: () async {
                  image = await pickImageFromCamera(context);
                  setState(() {});
                },
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      'Choose from gallery',
                      textAlign: TextAlign.center,
                    )),
                onTap: () async {
                  image = await pickImageFromGallery(context);
                  setState(() {});
                },
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      'Cancel',
                      textAlign: TextAlign.center,
                    )),
                onTap: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Stack(
                children: [
                  image == null
                      ? const CircleAvatar(
                          backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1661698048572-95812cdcf44b?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwxNXx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60'),
                          radius: 64,
                        )
                      : CircleAvatar(
                          backgroundImage: FileImage(image!),
                          radius: 64,
                        ),
                  Positioned(
                    bottom: -10,
                    right: 0,
                    child: IconButton(
                        onPressed: () => showDialogPickerImage(context),
                        icon: const Icon(Icons.add_a_photo)),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: size.width * 0.85,
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: storeUserData,
                    icon: const Icon(Icons.done),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
