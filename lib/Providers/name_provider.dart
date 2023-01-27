import 'package:flutter/cupertino.dart';

class NameProvider extends ChangeNotifier {
  String name = '';

  upDateName(String name) {
    this.name = name;
    notifyListeners();
  }
}
