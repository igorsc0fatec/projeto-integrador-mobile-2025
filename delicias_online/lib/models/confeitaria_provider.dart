import 'package:flutter/material.dart';

class ConfeitariaProvider extends ChangeNotifier {
  int? _idConfeitaria;

  int? get idConfeitaria => _idConfeitaria;

  void setIdConfeitaria(int id) {
    _idConfeitaria = id;
    notifyListeners();
  }

  void clear() {
    _idConfeitaria = null;
    notifyListeners();
  }
}