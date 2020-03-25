import 'package:flutter/material.dart';


class CurrentIndexProvide with ChangeNotifier {
  int currentIndex = 0;

  bool hostBadge_show = false;

  changeIndex(int newIndex){
    
    currentIndex = newIndex;
    notifyListeners();
  }

  changeHostBadge(bool b) {
    hostBadge_show = b;
    notifyListeners();
  }
}