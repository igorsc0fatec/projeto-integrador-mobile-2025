import 'package:flutter/material.dart';

class User {
  final int id;
  final String email;
  final int tipoUsuario;
  final int? idConfeitaria; // Adicione este campo

  User({
    required this.id,
    required this.email,
    required this.tipoUsuario,
    this.idConfeitaria, // Torne-o opcional
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_usuario'],
      email: json['email_usuario'],
      tipoUsuario: json['id_tipo_usuario'],
      idConfeitaria: json['id_confeitaria'], // Adicione esta linha
    );
  }
}

class UserProvider with ChangeNotifier {
  User? _user;
  
  User? get user => _user;
  
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
  
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}