import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'dart:io' show Platform;

// import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_phone_form_field/reactive_phone_form_field.dart';
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
  // String countryCode = '+91';

  // final TextEditingController _phone = TextEditingController();
  //
  // final TextEditingController _message = TextEditingController();
  // final TextEditingController _name = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  String phone = '';
  String name = '';

  @override
  void initState() {
    super.initState();
    phone = context.read<PhoneProvider>().phone;
    name = context.read<NameProvider>().name;
    print(phone);
  }

  Future saveInDb(Map<String, dynamic> value, PhoneNumber control) async {
    final contact = Contact(
        name: value['name'],
        contactNo: int.parse(control.nsn),
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

  void sendMessage(Map<String, dynamic> value, PhoneNumber control) async {
    await saveInDb(value, control);
    if (_key.currentState!.validate() && control.nsn.isNotEmpty) {
      final link = WhatsAppUnilink(
        phoneNumber: control.countryCode + control.nsn,
        text: value['message'],
      );

      // Convert the WhatsAppUnilink instance to a string.
      // Use either Dart's string interpolation or the toString() method.
      // The "launch" method is part of "url_launcher".
      await launch('$link');
    } else {
      // const snackBar = SnackBar(
      //   content: Text(
      //     'Phone number is empty!',
      //   ),
      // );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Map<String, dynamic>? validPhoneNumber(
    AbstractControl<dynamic> control,
  ) {
    if (control.value == null) {
      return null;
    }
    if (control.value! is! PhoneNumber) {
      return null;
    }
    if (!(control.value as PhoneNumber).isValid()) {
      return <String, bool>{'invalidPhone': true};
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: ReactiveFormBuilder(
        form: () => fb.group({
          'name': FormControl<String>(validators: [], value: name),
          'message': FormControl<String>(),
          'phone': FormControl<PhoneNumber>(
            validators: [validPhoneNumber,Validators.required],
            value: phone.contains("+")
                ? PhoneNumber.parse(phone)
                : PhoneNumber(
                    isoCode: IsoCode.IN,
                    nsn: phone,
                  ),
          ),
        }),
        builder: (context, formGroup, child) {
          return Padding(
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
                  ReactiveValueListenableBuilder<PhoneNumber>(
                    formControlName: 'phone',
                    builder: (context, control, child) =>
                        ReactivePhoneFormField<PhoneNumber>(
                      countrySelectorNavigator:
                          const CountrySelectorNavigator.draggableBottomSheet(),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      formControlName: 'phone',
                      defaultCountry: IsoCode.IN,
                      validationMessages: {
                        ValidationMessage.required: (control) =>
                            'Please enter phone number',
                        'invalidPhone': (control) =>
                            'Please  enter valid number'
                      },
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(right: 13, left: 13),
                        counterText: "",
                        hintText: "Enter Phone Number",
                        hintStyle:
                            TextStyle(fontSize: 14, color: Colors.white24),
                      ),
                      textAlignVertical: TextAlignVertical.center,
                    ),
                  ),
                  // IntlPhoneField(
                  //   showDropdownIcon: false,
                  //   controller: _phone,
                  //   initialCountryCode: 'IN',
                  //   onCountryChanged: (Country value) {
                  //     countryCode = value.dialCode.replaceAll(" ", "");
                  //   },
                  //   inputFormatters: [
                  //     FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  //   ],
                  //   validator: (PhoneNumber? string) {
                  //     Pattern pattern = r'(^(?:[+0]9)?[0-9]{10,}$)';
                  //     RegExp regExp = RegExp(pattern.toString());
                  //     if (string == null || string.number.isEmpty) {
                  //       return 'Please enter mobile number';
                  //     } else if (!regExp.hasMatch(string.number)) {
                  //       return 'Please enter valid mobile number';
                  //     }
                  //     return null;
                  //   },
                  //   keyboardType: TextInputType.number,
                  //   textInputAction: TextInputAction.next,
                  //   decoration: const InputDecoration(
                  //     contentPadding: EdgeInsets.only(right: 13, left: 13),
                  //     counterText: "",
                  //     hintText: "Enter Phone Number",
                  //     hintStyle: TextStyle(fontSize: 14, color: Colors.white24),
                  //   ),
                  //   textAlignVertical: TextAlignVertical.center,
                  // ),
                  ReactiveTextField(
                    formControlName: 'name',
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
                  // TextFormField(
                  //   controller: _name,
                  //   keyboardType: TextInputType.name,
                  //   textInputAction: TextInputAction.next,
                  //   maxLength: 20,
                  //   decoration: InputDecoration(
                  //       hintText: "Name(optional)",
                  //       hintStyle: TextStyle(
                  //         fontSize: 14,
                  //         color: Colors.grey.withOpacity(0.5),
                  //       ),
                  //       counterText: ""),
                  // ),
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
                      child: ReactiveTextField(
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          // sendMessage(formGroup.value);
                        },
                        maxLines: null,
                        // focusNode: focusNode,
                        formControlName: 'message',
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 13, vertical: 13),
                          hintText: "Message(optional)",
                          hintStyle:
                              TextStyle(color: Colors.white24, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  ReactiveValueListenableBuilder<PhoneNumber>(
                      formControlName: 'phone',
                      builder: (context, control, child) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: InkWell(
                            onTap: () => formGroup.valid
                                ? sendMessage(formGroup.value, control.value!)
                                : null,
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
                        );
                      })
                ],
              ),
            ),
          );
        },
      ),
    ));
  }
}
