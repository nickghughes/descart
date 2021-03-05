import 'package:descart/descart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

void main() async {
  final storage = FlutterSecureStorage();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  String token = await storage.read(key: "token");
  debugPrint(token);
  bool isLoggedIn = await isValidToken(token);
  if (!isLoggedIn) await storage.delete(key: "token");
  runApp(DesCart(isLoggedIn));
}

Future<bool> isValidToken(String token) async {
  if (token == null) return false;
  return await http
      .get("http://192.168.1.189:3333/api/auth/profile",
          headers: {"Authorization": "Bearer $token"})
      .then((res) => true)
      .catchError((err) => false);
}
