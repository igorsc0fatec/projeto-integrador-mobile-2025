import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delicias_online/models/confeitaria_provider.dart';
import 'package:delicias_online/views/login_page.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ConfeitariaProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delícias Online',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}