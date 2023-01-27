import 'package:flutter/cupertino.dart';

class StateProvider with ChangeNotifier {
  int currentIndex = 0;

  int getCurrentIndex() {
    return currentIndex;
  }

  toIndex(int index){
    currentIndex=index;
    notifyListeners();
  }

  navigateToDirectMessage() {
    currentIndex = 0;
    notifyListeners();
  }

  navigateToDirectLogs() {
    currentIndex = 1;
    notifyListeners();
  }
}
