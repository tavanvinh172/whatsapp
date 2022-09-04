import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_whatsapp_clone/colors.dart';
import 'package:flutter_whatsapp_clone/common/widgets/error.dart';
import 'package:flutter_whatsapp_clone/common/widgets/loader.dart';
import 'package:flutter_whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:flutter_whatsapp_clone/features/chat/screens/mobile_chat_screen.dart';
import 'package:flutter_whatsapp_clone/models/chat_contact.dart';
import 'package:intl/intl.dart';

class ContactsList extends ConsumerWidget {
  const ContactsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: StreamBuilder<List<ChatContact>>(
          stream: ref.watch(chatControllerProvider).getCurrentContactList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            if (snapshot.hasError) {
              return ErrorScreen(error: snapshot.error.toString());
            }
            return ListView.builder(
              shrinkWrap: true,
              reverse: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final chatContactData = snapshot.data![index];
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, MobileChatScreen.routeName,
                            arguments: {
                              'name': chatContactData.name,
                              'uid': chatContactData.contactId,
                            });
                      },
                      child: FirebaseAuth.instance.currentUser!.uid ==
                              chatContactData.contactId
                          ? Container(
                              color: const Color.fromARGB(255, 84, 94, 102),
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: const Text(
                                  'My Cloud',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    chatContactData.lassMessage,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    chatContactData.profilePic,
                                  ),
                                  radius: 30,
                                ),
                                trailing: Text(
                                  DateFormat.Hm()
                                      .format(chatContactData.timeSent),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text(
                                  chatContactData.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    chatContactData.lassMessage,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    chatContactData.profilePic,
                                  ),
                                  radius: 30,
                                ),
                                trailing: Text(
                                  DateFormat.Hm()
                                      .format(chatContactData.timeSent),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const Divider(color: dividerColor, indent: 85),
                  ],
                );
              },
            );
          }),
    );
  }
}
