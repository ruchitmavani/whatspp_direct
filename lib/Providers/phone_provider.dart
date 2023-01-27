import 'package:flutter/cupertino.dart';

class PhoneProvider extends ChangeNotifier {
  String phone = '';

  upDatePhone(String number) {
    phone = number.replaceAll(" ", "");
    notifyListeners();
  }
}
