import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_whatsapp_clone/colors.dart';
import 'package:flutter_whatsapp_clone/common/widgets/error.dart';
import 'package:flutter_whatsapp_clone/common/widgets/loader.dart';
import 'package:flutter_whatsapp_clone/features/status/controller/status_controller.dart';
import 'package:flutter_whatsapp_clone/features/status/screens/status_screen.dart';
import 'package:flutter_whatsapp_clone/models/status_model.dart';

class StatusContactScreen extends ConsumerWidget {
  const StatusContactScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Status>>(
      future: ref.read(statusControllerProvider).getStatus(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        if (snapshot.hasError) {
          return ErrorScreen(
            error: snapshot.error.toString(),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var statusData = snapshot.data![index];
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        StatusScreen.routeName,
                        arguments: statusData,
                      );
                    },
                    child:
                        FirebaseAuth.instance.currentUser!.uid == statusData.uid
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
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      statusData.profilePic,
                                    ),
                                    radius: 30,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ListTile(
                                  title: Text(
                                    statusData.username,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      statusData.profilePic,
                                    ),
                                    radius: 30,
                                  ),
                                ),
                              ),
                  ),
                  const Divider(color: dividerColor, indent: 85),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
