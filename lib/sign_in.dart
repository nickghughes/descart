import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final currentUser = _auth.currentUser;
  assert(user.uid == currentUser.uid);

  assert(user.email != null);
  assert(user.displayName != null);
  assert(user.photoURL != null);
  name = user.displayName;
  // Take only first name if there is a space in the full name
  if (name.contains(" ")) {
    name = name.substring(0, name.indexOf(" "));
  }
  email = user.email;
  imageUrl = user.photoURL;
  debugPrint("Name: " + name);
  debugPrint("photoURL: " + imageUrl);
  debugPrint("email: " + email);

  return user;
}

void signOutGoogle() async {
  await googleSignIn.signOut();
  _auth.signOut();

  print("User Sign Out");
}
