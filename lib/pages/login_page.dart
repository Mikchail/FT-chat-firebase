import 'package:flutter/material.dart';
import 'package:ft_chat/providers/auth_provider.dart';
import 'package:ft_chat/services/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:ft_chat/services/snackbar_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  String _email = "";
  String _password = "";
  late AuthProvider _auth;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // _LoginPageState() {
  //   _formKey = GlobalKey<FormState>();
  // }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Align(
          alignment: Alignment.center,
          child: ChangeNotifierProvider<AuthProvider>.value(
            value: AuthProvider.instance,
            child: _loginPageUI(),
          )),
    );
  }

  Widget _loginPageUI() {
    return Builder(builder: (BuildContext context) {
      SnackBarService.instance.buildContext = context;
      _auth = Provider.of<AuthProvider>(context);
      return Container(
        alignment: Alignment.center,
        height: _deviceHeight * 0.60,
        padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headlineWidget(),
            _inputForm(),
            _loginButton(),
            _registerButton()
          ],
        ),
      );
    });
  }

  Widget _headlineWidget() {
    return Container(
      height: _deviceHeight * 0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welocme back!",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700)),
          Text("Please login to your account!",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200))
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
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
            _emailTextField(),
            _passwordTextField(),
          ],
        ),
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

  Widget _loginButton() {
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
                  _auth.loginUserWithEmailAndPassword(_email, _password);
                }
              },
              color: Colors.blue,
              child: Text("LOGIN",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          );
  }

  Widget _registerButton() {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.navigatorTo("register");
      },
      child: Container(
        height: _deviceHeight * 0.06,
        width: _deviceWidth,
        child: Text("REGISTER",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.white60)),
      ),
    );
  }
}
