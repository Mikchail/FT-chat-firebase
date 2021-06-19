import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ft_chat/providers/auth_provider.dart';
import 'package:ft_chat/services/cloud_storage_service.dart';
import 'package:ft_chat/services/db_service.dart';
import 'package:ft_chat/services/media_service.dart';
import 'package:ft_chat/services/navigation_service.dart';
import 'package:ft_chat/services/snackbar_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  String _name = "";
  String _email = "";
  String _password = "";
  PickedFile? _pickedFile;
  File? _file;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthProvider _auth = AuthProvider();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: registrationPageUI(),
        ));
  }

  Widget registrationPageUI() {
    return Builder(builder: (BuildContext context) {
      SnackBarService.instance.buildContext = context;
      _auth = Provider.of<AuthProvider>(context);
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _headlineWidget(),
            _inputForm(),
            _registerButton(),
            _backLoginPageButton(),
          ],
        ),
      );
    });
  }

  Widget _headlineWidget() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Let's get going!",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700)),
          Text("Please enter your details!",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200)),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState?.save();
        },
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageSelectorWidget(),
            _nameTextField(),
            _emailTextField(),
            _passwordTextField(),
          ],
        ),
      ),
    );
  }

  Widget _imageSelectorWidget() {
    return GestureDetector(
      onTap: () async {
        PickedFile? _imageFile =
            await MediaService.instance.getImageFromLibrary();
        setState(() {
          // TODO mb get rid of _pickedFile
          _pickedFile = _imageFile;
          _file = File(_imageFile!.path);
        });
      },
      child: Center(
        child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: _file != null
                ? ClipOval(
                    child: Image.file(
                      _file as File,
                      width: 60,
                      height: 60,
                    ),
                  )
                : null,
            decoration: _file != null
                ? null
                : BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(500),
                  )),
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(
        color: Colors.white,
      ),
      validator: (_input) {
        return (_input.toString().length != 0 ||
                _input.toString().contains("@"))
            ? null
            : "Please Enter valid Email";
      },
      onSaved: (_input) {
        setState(() {
          _email = _input.toString();
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: "Email Address",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(
        color: Colors.white,
      ),
      validator: (_input) {
        return _input.toString().length != 0 ? null : "Please Enter your name";
      },
      onSaved: (_input) {
        setState(() {
          _name = _input.toString();
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: "Name",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      style: TextStyle(
        color: Colors.white,
      ),
      validator: (_input) {
        return _input.toString().length != 0 ? null : "Please enter a password";
      },
      onSaved: (_input) {
        setState(() {
          _password = _input.toString();
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: "Password",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return _auth.status == AuthStatus.Authenticating
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            height: _deviceHeight * 0.06,
            width: _deviceWidth,
            child: MaterialButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _auth.registerUserWithEmailAndPassword(_email, _password,
                      (String uid) async {
                    // var _result = await CloudStorageService.instance
                    //     .uploadUserImage(uid, _file as File);
                    // var _imageUrl = await _result.ref.getDownloadURL();
                    await DBService.instance.createUserInDb(uid, _name, _email);
                    // .createUserInDb(uid, _name, _email, _imageUrl);
                  });
                }
              },
              color: Colors.blue,
              child: Text("REGISTER",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white)),
            ),
          );
  }

  Widget _backLoginPageButton() {
    return Center(
      child: IconButton(
        iconSize: 40,
        onPressed: () {
          NavigationService.instance.goBack();
        },
        icon: Icon(Icons.arrow_back),
      ),
    );
  }
}
