import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ft_chat/pages/home_page.dart';
import 'package:ft_chat/services/navigation_service.dart';
import 'package:ft_chat/pages/login_page.dart';
import 'package:ft_chat/pages/registration_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData(
          brightness: Brightness.dark,
          backgroundColor: Color.fromRGBO(28, 27, 27, 1)),

      // initialRoute: "login",
      routes: {
        "login": (BuildContext _context) => LoginPage(),
        "home": (BuildContext _context) => HomePage(),
        "register": (BuildContext _context) => RegistrationPage(),
      },
      home: AppWithFirebase(),
    );
  }
}

class AppWithFirebase extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<AppWithFirebase> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Scaffold(
            body: Text("Ooops Error..."),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return LoginPage();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
