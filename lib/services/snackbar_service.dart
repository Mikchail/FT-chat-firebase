import 'package:flutter/material.dart';

class SnackBarService {
  late BuildContext _buildContext;
  static SnackBarService instance = SnackBarService();

  set buildContext(BuildContext _context) {
    _buildContext = _context;
  }

  void showSnackBarError(String _message) {
    ScaffoldMessenger.of(_buildContext).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      duration: Duration(seconds: 2),
      content:
          Text(_message, style: TextStyle(color: Colors.white, fontSize: 15)),
    ));
  }

  void showSnackBarSuccess(String _message) {
    ScaffoldMessenger.of(_buildContext).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      content:
          Text(_message, style: TextStyle(color: Colors.white, fontSize: 15)),
    ));
  }
}
