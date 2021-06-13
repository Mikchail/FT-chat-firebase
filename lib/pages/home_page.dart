import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: _homePageUI(),
        appBar: AppBar(
          title: Text(
            "Chat",
            style: TextStyle(fontSize: 16),
          ),
        ));
  }

  Widget _homePageUI() {
    return Container(
      child: Text("Home"),
    );
  }
}
