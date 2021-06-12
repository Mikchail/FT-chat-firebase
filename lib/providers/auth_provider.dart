import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  late User _user = null;

  // FirebaseAuth _auth = FirebaseAuth.instance;
  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth = FirebaseAuth.instance;
  }

  void loginUserWithEmailAndPassword(String email, String password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _user = _result.user as User;
      status = AuthStatus.Authenticated;
      SnackBarService.instance.showSnackBarSuccess("Welcome ${_user.email}");
      // navigate
    } catch (e) {
      status = AuthStatus.Error;
      SnackBarService.instance.showSnackBarError("Error Not Login");
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
      _user = _result.user as User;
      status = AuthStatus.Authenticated;
      await onSuccess(_user.uid);
      SnackBarService.instance.showSnackBarSuccess("Welcome ${_user.email}");
      NavigationService.instance.goBack();
    } catch (e) {
      status = AuthStatus.Error;
      _user = null;
      SnackBarService.instance.showSnackBarError("Error Not register");
    }
  }
}
