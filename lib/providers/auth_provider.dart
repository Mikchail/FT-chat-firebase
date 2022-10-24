import 'dart:convert';
import 'dart:developer';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ft_chat/models/User.dart';
import 'package:ft_chat/services/navigation_service.dart';
import 'package:ft_chat/services/snackbar_service.dart';

import '../services/api_service.dart';

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
  static const String userKey = "user";
  // ignore: avoid_init_to_null
  late AuthData? authData = null;

  // FirebaseAuth _auth = FirebaseAuth.instance;
  static AuthProvider instance = AuthProvider();
  final EncryptedSharedPreferences encryptSP = EncryptedSharedPreferences();
  AuthProvider() {
    _checkCurrentUserIsAuthenticated();
  }

  void _autoLogin() async {
    if (authData != null) {
      // await DBService.instance.updateUserLastSeenTime(user!.uid);
      return NavigationService.instance.navigatorTo("home");
    }
  }

  void _checkCurrentUserIsAuthenticated() async {
    var data = await encryptSP.getString(userKey);
    if (data.isNotEmpty) {
      authData = AuthData.fromJson(json.decode(data));
    }

    if (authData != null) {
      log(authData!.user.email);
      log("authData.toString()");
      // notifyListeners();
      _autoLogin();
    }
  }

  void loginUserWithEmailAndPassword(String email, String password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      // UserCredential _result = await _auth.signInWithEmailAndPassword(
      //     email: email, password: password);
      // user = _result.user as User;
      var res = await ApiService.instance.login(email, password);
      if (res != null) {
        authData = res as AuthData;
        await encryptSP.setString(userKey, json.encode(res));
      }

      if (authData != null) {
        status = AuthStatus.Authenticated;
        SnackBarService.instance
            .showSnackBarSuccess("Welcome ${res.user.email}");
      }
      // DBService.instance.updateUserLastSeenTime(user!.uid);

      NavigationService.instance.navigatorToReplacement("home");
    } catch (e) {
      status = AuthStatus.Error;
      authData = null;
      SnackBarService.instance.showSnackBarError(e.toString());
      // Display Error
    }
    notifyListeners();
  }

  void registerUserWithEmailAndPassword(String email, String password,
      String name, Future<void> onSuccess(String uid)) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      // UserCredential _result = await _auth.createUserWithEmailAndPassword(
      //     email: email, password: password);
      var res = await ApiService.instance.registeration(email, password, name);
      if (res != null) {
        authData = res as AuthData;
        await encryptSP.setString(userKey, json.encode(res));
      }
      if (authData != null) {
        status = AuthStatus.Authenticated;
        await onSuccess(authData!.user.id);
        SnackBarService.instance
            .showSnackBarSuccess("Welcome ${authData!.user.email}");
        NavigationService.instance.goBack();
        NavigationService.instance.navigatorToReplacement("home");
      }
    } catch (e) {
      log(e.toString());
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
      authData = null;
    }
    notifyListeners();
  }

  void logoutUser(Future<void> onSuccess()) async {
    try {
      // await _auth.signOut();
      encryptSP.remove(userKey);
      authData = null;
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
