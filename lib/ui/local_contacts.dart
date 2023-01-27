import 'package:contacts_service/contacts_service.dart' as cs;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:whatspp_direct/Providers/name_provider.dart';

import '../Providers/phone_provider.dart';
import '../Providers/state_provider.dart';
import '../models/Boxes.dart';
import '../models/hive_contact.dart';

class RecentTransactions extends StatefulWidget {
  const RecentTransactions({Key? key}) : super(key: key);

  @override
  _RecentTransactionsState createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends State<RecentTransactions> {
  Future<void> saveContactInPhone(String number, String name) async {
    try {
      PermissionStatus permission = await Permission.contacts.status;

      if (permission != PermissionStatus.granted) {
        await Permission.contacts.request();
        PermissionStatus permission = await Permission.contacts.status;

        if (permission == PermissionStatus.granted) {
          // Contact updatedContact = new Contact();
          Iterable<cs.Contact> updatedContact =
              await cs.ContactsService.getContacts(query: number);

          cs.Contact updatedContact1 = cs.Contact();
          updatedContact1 = updatedContact.first;
          await cs.ContactsService.deleteContact(updatedContact1);
          cs.Contact newContact = cs.Contact();
          newContact.givenName = name;
          newContact.phones = [cs.Item(label: "mobile", value: number)];
          await cs.ContactsService.addContact(newContact);
        }
      } else {
        // Contact updatedContact = new Contact();
        Iterable<cs.Contact> updatedContact =
            await cs.ContactsService.getContacts(query: number);

        await cs.ContactsService.deleteContact(updatedContact.first);
        // Contact updatedContact1 = new Contact();
        // updatedContact1= updatedContact.first;
        cs.Contact newContact = cs.Contact();
        newContact.givenName = name;
        newContact.phones = [cs.Item(label: "mobile", value: number)];
        await cs.ContactsService.addContact(newContact);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Contact>>(
      valueListenable: Boxes.getContacts().listenable(),
      builder: (context, box, _) {
        final contacts = box.values.toList().cast<Contact>().reversed;
        if (contacts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("No Interactions Yet"),
                ElevatedButton(onPressed: () {
                  context.read<StateProvider>().navigateToDirectMessage();
                }, child: const Text('Get Started'))
              ],
            ),
          );
        } else {
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(top: 7.0),
              child: InkWell(
                onTap: () {
                  context.read<PhoneProvider>().phone =
                      contacts.elementAt(index).contactNo.toString();
                  context.read<NameProvider>().name =
                      contacts.elementAt(index).name;
                  context.read<StateProvider>().navigateToDirectMessage();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                contacts.elementAt(index).name != ""
                                    ? contacts.elementAt(index).name
                                    : '${contacts.elementAt(index).contactNo}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    letterSpacing: 0.5)),
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Text(
                                  '${contacts.elementAt(index).contactNo}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.withOpacity(0.5))),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                        DateFormat('hh:mm a dd/MM/yyyy')
                            .format(contacts.elementAt(index).date),
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 12,
                            color: Colors.grey.withOpacity(0.5))),
                    IgnorePointer(
                      child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            CupertinoIcons.chevron_right,
                            size: 16,
                          )),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
