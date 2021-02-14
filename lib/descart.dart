import 'package:descart/login_page.dart';
import 'package:flutter/material.dart';

class DesCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Des-Cart',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
      routes: {
        "/logout": (_) => new LoginPage(),
      },
    );
  }
}
