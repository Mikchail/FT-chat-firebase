import 'package:flutter/material.dart';
import 'package:ft_chat/models/contact.dart';
import 'package:ft_chat/providers/auth_provider.dart';
import 'package:ft_chat/services/db_service.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  final double height;
  final double width;
  late AuthProvider _auth;
  ProfilePage({required this.height, required this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance, child: _profilePageUI()),
    );
  }

  Widget _profilePageUI() {
    return Builder(builder: (context) {
      _auth = Provider.of<AuthProvider>(context);
      return StreamBuilder<Contact>(
          stream: DBService.instance.getUserData(_auth.user!.uid),
          builder: (context, snapshot) {
            var user = snapshot.data;
            if (!snapshot.hasData || user == null) {
              return Center(child: CircularProgressIndicator());
            }
            return Center(
              child: SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _circleAvatar(user.image),
                    const SizedBox(
                      height: 10,
                    ),
                    _userName(user.name),
                    const SizedBox(
                      height: 10,
                    ),
                    _userEmail(user.email),
                    const SizedBox(
                      height: 10,
                    ),
                    _logout()
                  ],
                ),
              ),
            );
          });
    });
  }

  Widget _logout() {
    return Container(
      height: 50,
      width: width * 0.8,
      child: Container(
        child: MaterialButton(
          onPressed: () async {
            _auth.logoutUser(() async {});
          },
          color: Colors.red,
          child: Text(
            "LOGOUT",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Container _userEmail(String email) {
    return Container(
      width: width,
      child: Text(email,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white24, fontSize: 15)),
    );
  }

  Container _userName(String userName) {
    return Container(
      width: width,
      child: Text(userName,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 30)),
    );
  }

  Widget _circleAvatar(image) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        radius: 60,
        backgroundImage: image == "" ? null : NetworkImage(image),
      ),
    );
  }
}
