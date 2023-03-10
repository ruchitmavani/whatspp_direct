import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:whatspp_direct/Providers/name_provider.dart';
import 'package:whatspp_direct/Providers/phone_provider.dart';
import 'package:whatspp_direct/models/hive_contact.dart';

import '../constants.dart';
import '../models/Boxes.dart';

class DirectMessage extends StatefulWidget {
  const DirectMessage({Key? key}) : super(key: key);

  @override
  State<DirectMessage> createState() => _DirectMessageState();
}

class _DirectMessageState extends State<DirectMessage> {
  String countryCode = '+91';

  final TextEditingController _phone = TextEditingController();

  final TextEditingController _message = TextEditingController();
  final TextEditingController _name = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _phone.text = context.read<PhoneProvider>().phone;
    _name.text = context.read<NameProvider>().name;
  }

  Future saveInDb() async {
    final contact = Contact(
        name: _name.text,
        contactNo: int.parse(_phone.text),
        date: DateTime.now());

    final box = Boxes.getContacts();
    if (box.values.toList().contains(contact)) {
      int index =
          box.values.toList().indexWhere((element) => element == contact);
      if (kDebugMode) {
        print(box.keyAt(index));
      }
      String name = box.values.elementAt(index).name;
      if (contact.name == "") {
        contact.name = name;
      }
      box.deleteAt(index);
      box.add(contact);
    } else {
      box.add(contact);
    }
  }

  void sendMessage() async {
    await saveInDb();
    if (_key.currentState!.validate() && _phone.text.isNotEmpty) {
      final link = WhatsAppUnilink(
        phoneNumber: countryCode + _phone.text,
        text: _message.text,
      );

      // Convert the WhatsAppUnilink instance to a string.
      // Use either Dart's string interpolation or the toString() method.
      // The "launch" method is part of "url_launcher".
      await launch('$link');
    } else {
      const snackBar = SnackBar(
        content: Text(
          'Phone number is empty!',
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _key,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Phone Number",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const Text(
                  "Insert phone number you want to send a whatsapp message to.",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.start,
                ),
                IntlPhoneField(
                  showDropdownIcon: false,
                  controller: _phone,
                  initialCountryCode: 'IN',
                  onCountryChanged: (Country value) {
                    countryCode = value.dialCode.replaceAll(" ", "");
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                  validator: (PhoneNumber? string) {
                    Pattern pattern = r'(^(?:[+0]9)?[0-9]{10,}$)';
                    RegExp regExp = RegExp(pattern.toString());
                    if (string == null || string.number.isEmpty) {
                      return 'Please enter mobile number';
                    } else if (!regExp.hasMatch(string.number)) {
                      return 'Please enter valid mobile number';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(right: 13, left: 13),
                    counterText: "",
                    hintText: "Enter Phone Number",
                    hintStyle: TextStyle(fontSize: 14, color: Colors.white24),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
                TextFormField(
                  controller: _name,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  maxLength: 20,
                  decoration: InputDecoration(
                      hintText: "Name(optional)",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      counterText: ""),
                ),
                Container(
                  // alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 20, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                    maxWidth: MediaQuery.of(context).size.width,
                    minHeight: 25.0,
                    maxHeight: 100.0,
                  ),
                  child: Scrollbar(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        sendMessage();
                      },
                      maxLines: null,
                      // focusNode: focusNode,
                      controller: _message,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                        hintText: "Message(optional)",
                        hintStyle:
                            TextStyle(color: Colors.white24, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: InkWell(
                    onTap: sendMessage,
                    child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        decoration: BoxDecoration(
                          color: green,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          "SEND",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        )),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
