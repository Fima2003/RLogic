import 'package:flutter/material.dart';

class MyTheme with ChangeNotifier{
  void switchTheme(){
    notifyListeners();
  }
}