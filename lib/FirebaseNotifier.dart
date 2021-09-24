import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'PurchaseApi.dart';

enum FirebaseState {
  loading,
  available,
  notAvailable,
}

class FirebaseNotifier extends ChangeNotifier {
  bool loggedIn = false;
  FirebaseState state = FirebaseState.loading;
  bool isLoggingIn = false;

  FirebaseNotifier() {
    load();
  }

  late final Completer<bool> _isInitialized = Completer();

  Future<void> load() async {
    try {
      await Firebase.initializeApp();
      loggedIn = FirebaseAuth.instance.currentUser != null;
      state = FirebaseState.available;
      _isInitialized.complete(true);
      notifyListeners();
    } catch (e) {
      state = FirebaseState.notAvailable;
      _isInitialized.complete(false);
      notifyListeners();
    }
  }

  Future<void> login() async {
    isLoggingIn = true;
    notifyListeners();
    if(loggedIn == true){
      isLoggingIn = false;
      notifyListeners();
      return ;
    }
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isLoggingIn = false;
        notifyListeners();
        return;
      }

      // Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);

      loggedIn = true;
      isLoggingIn = false;
      await PurchaseApi.login(FirebaseAuth.instance.currentUser!.uid);
      notifyListeners();
    } catch (e) {
      isLoggingIn = false;
      notifyListeners();
      throw Future.error("An Error occurred during login: $e");
    }
  }

  Future<void> logOut()async {
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}