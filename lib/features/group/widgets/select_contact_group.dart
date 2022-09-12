import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_whatsapp_clone/common/widgets/error.dart';
import 'package:flutter_whatsapp_clone/common/widgets/loader.dart';
import 'package:flutter_whatsapp_clone/features/select_contact/controller/select_contact_controller.dart';

final selectedGroupContactsProvider = StateProvider<List<Contact>>((ref) {
  return [];
});

class SelectContactGroup extends ConsumerStatefulWidget {
  const SelectContactGroup({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectContactGroupState();
}

class _SelectContactGroupState extends ConsumerState<SelectContactGroup> {
  List<int> selectedContactIndex = [];

  void selectContact(int index, Contact contact) {
    if (selectedContactIndex.contains(index)) {
      selectedContactIndex.removeAt(index);
    } else {
      selectedContactIndex.add(index);
    }
    setState(() {});
    ref
        .read(selectedGroupContactsProvider.state)
        .update((state) => [...state, contact]);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(getContactsProvider).when(
        data: (contact) {
          return Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: contact.length,
              itemBuilder: (context, index) {
                final contacts = contact[index];
                return InkWell(
                  onTap: () => selectContact(index, contacts),
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        title: Text(
                          contacts.displayName,
                          style: const TextStyle(fontSize: 18),
                        ),
                        leading: selectedContactIndex.contains(index)
                            ? IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.done,
                                ),
                              )
                            : null,
                      )),
                );
              },
            ),
          );
        },
        error: (err, trace) {
          return ErrorScreen(
            error: err.toString(),
          );
        },
        loading: () => const Loader());
  }
}
