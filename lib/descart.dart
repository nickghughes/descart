import 'package:descart/login_page.dart';
import 'package:descart/nav_scaffold.dart';
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
      home: NavScaffold(), //LoginPage(),
    );
  }
}
