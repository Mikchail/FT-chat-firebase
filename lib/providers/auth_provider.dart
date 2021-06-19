import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ft_chat/services/db_service.dart';
import 'package:ft_chat/services/navigation_service.dart';
import 'package:ft_chat/services/snackbar_service.dart';

enum AuthStatus {
  Empty,
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error
}

class AuthProvider extends ChangeNotifier {
  AuthStatus status = AuthStatus.Empty;
  late FirebaseAuth _auth;
  // ignore: avoid_init_to_null
  late User? user = null;

  // FirebaseAuth _auth = FirebaseAuth.instance;
  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _checkCurrentUserIsAuthenticated();
  }

  void _autoLogin() async {
    if (user != null) {
      await DBService.instance.updateUserLastSeenTime(user!.uid);
      return NavigationService.instance.navigatorTo("home");
    }
  }

  void _checkCurrentUserIsAuthenticated() async {
    user = await _auth.currentUser;
    if (user != null) {
      notifyListeners();
      _autoLogin();
    }
  }

  void loginUserWithEmailAndPassword(String email, String password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = _result.user as User;
      status = AuthStatus.Authenticated;
      SnackBarService.instance.showSnackBarSuccess("Welcome ${user!.email}");

      DBService.instance.updateUserLastSeenTime(user!.uid);

      NavigationService.instance.navigatorToReplacement("home");
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance.showSnackBarError(e.toString());
      // Display Error
    }
    notifyListeners();
  }

  void registerUserWithEmailAndPassword(
      String email, String password, Future<void> onSuccess(String uid)) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = _result.user;
      if (user != null) {
        status = AuthStatus.Authenticated;
        await onSuccess(user!.uid);
        SnackBarService.instance.showSnackBarSuccess("Welcome ${user!.email}");
        DBService.instance.updateUserLastSeenTime(user!.uid);
        NavigationService.instance.goBack();
        NavigationService.instance.navigatorToReplacement("home");
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == "invalid-email") {
          SnackBarService.instance.showSnackBarError(e.message!);
        }
        if (e.code == "weak-password") {
          SnackBarService.instance.showSnackBarError(e.message!);
        }
        if (e.code == "email-already-in-use") {
          SnackBarService.instance.showSnackBarError(e.message!);
        }
      } else {
        SnackBarService.instance.showSnackBarError("Error Not register");
      }

      status = AuthStatus.Error;
      user = null;
    }
    notifyListeners();
  }

  void logoutUser(Future<void> onSuccess()) async {
    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
      await NavigationService.instance.navigatorToReplacement("login");
      SnackBarService.instance.showSnackBarSuccess("Logged out Successfully");
    } catch (e) {
      SnackBarService.instance.showSnackBarError("Error Loggin out");
    }
    notifyListeners();
  }
}
