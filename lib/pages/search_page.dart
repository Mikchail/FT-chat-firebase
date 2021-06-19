import 'package:flutter/material.dart';
import 'package:ft_chat/models/contact.dart';
import 'package:ft_chat/pages/conversation_page.dart';
import 'package:ft_chat/providers/auth_provider.dart';
import 'package:ft_chat/services/db_service.dart';
import 'package:ft_chat/services/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchPage extends StatefulWidget {
  final double height;
  final double width;

  SearchPage({required this.height, required this.width});
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late AuthProvider _auth;
  late String _searchName = "";

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: AuthProvider.instance,
      child: _searchPageUI(),
    );
  }

  Widget _searchPageUI() {
    return Builder(builder: (context) {
      _auth = Provider.of<AuthProvider>(context);
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [_userSearchField(), _usersListView()],
      );
    });
  }

  Widget _userSearchField() {
    return Container(
      height: this.widget.height * 0.08,
      width: this.widget.width,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        autocorrect: false,
        style: TextStyle(color: Colors.white),
        onSubmitted: (input) {
          setState(() {
            _searchName = input.toString();
          });
        },
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.white),
            labelStyle: TextStyle(color: Colors.white),
            labelText: "Serach",
            border: OutlineInputBorder(borderSide: BorderSide.none)),
      ),
    );
  }

  Widget _usersListView() {
    return StreamBuilder(
        stream: DBService.instance.getUsersInDB(_searchName),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var usersData = snapshot.data as List<Contact>;
            if (usersData != null) {
              usersData.removeWhere((contact) => contact.id == _auth.user!.uid);
            }
            return Expanded(
              child: Container(
                child: ListView.builder(
                    itemCount: usersData.length,
                    itemBuilder: (context, index) {
                      var recepientID = usersData[index].id;
                      var userIsActive = !usersData[index]
                          .lastSeen
                          .toDate()
                          .isBefore(
                              DateTime.now().subtract(Duration(hours: 1)));
                      return ListTile(
                        onTap: () {
                          DBService.instance.createOrGetConversaion(
                              _auth.user!.uid, recepientID,
                              (String conversationID) {
                            return NavigationService.instance.navigatorToRoute(
                                MaterialPageRoute(builder: (context) {
                              return ConversationPage(
                                  conversationID: conversationID,
                                  receiverID: recepientID,
                                  receiverImage: usersData[index].image,
                                  receiverName: usersData[index].name);
                            }));
                          });
                        },
                        title: Text(usersData[index].name),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(usersData[index].image),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _textUserLastSeen(userIsActive),
                            _userIndicatorIsActive(
                                userIsActive, usersData[index].lastSeen)
                          ],
                        ),
                      );
                    }),
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget _userIndicatorIsActive(bool userIsActive, lastSeen) {
    return userIsActive
        ? Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
                color: Colors.green, borderRadius: BorderRadius.circular(100)),
          )
        : Text(
            timeago.format(lastSeen.toDate()),
          );
  }

  Text _textUserLastSeen(bool userIsActive) {
    return Text(userIsActive ? "Active Now" : "Last seen");
  }
}
