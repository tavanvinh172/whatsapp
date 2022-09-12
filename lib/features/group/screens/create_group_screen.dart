import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_whatsapp_clone/common/utils/utils.dart';
import 'package:flutter_whatsapp_clone/features/group/controllers/group_controller.dart';
import 'package:flutter_whatsapp_clone/features/group/widgets/select_contact_group.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  static const String routeName = '/create-group';
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  File? image;
  final TextEditingController groupNameController = TextEditingController();
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

  void createGroup() {
    if (groupNameController.text.trim().isNotEmpty && image != null) {
      ref.read(groupControllerProvider).createGroup(
            context,
            groupNameController.text,
            image!,
            ref.read(selectedGroupContactsProvider),
          );
      ref.read(selectedGroupContactsProvider.state).update((state) => []);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: groupNameController,
                decoration: const InputDecoration(hintText: 'Enter Group Name'),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.topLeft,
              child: const Text(
                'Select Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SelectContactGroup()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createGroup,
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}
