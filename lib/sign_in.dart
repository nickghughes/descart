import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// based on https://medium.com/flutter-community/flutter-implementing-google-sign-in-71888bca24ed

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

String name;
String email;
String imageUrl;

Future<User> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  if (googleSignInAccount == null) {
    return null;
  }

  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  if (googleSignInAuthentication == null) {
    return null;
  }

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final authResult = await _auth.signInWithCredential(credential);
  final user = authResult.user;

  assert(user.email != null);
  assert(user.displayName != null);
  name = user.displayName;
  email = user.email;
  debugPrint("Name: " + name);
  debugPrint("email: " + email);

  dynamic login = await http.post(
    "http://descart.grumdog.com/api/auth/login",
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json.encode(
      Map<String, String>.from(
        {"username": name, "password": email},
      ),
    ),
  );
  String token = JsonDecoder().convert(login.body)["access_token"];
  debugPrint(token);
  await FlutterSecureStorage().write(key: "token", value: token);

  return user;
}

void signOutGoogle() async {
  await googleSignIn.signOut();
  await FlutterSecureStorage().delete(key: "token");
  _auth.signOut();

  print("User Sign Out");
}
