import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ft_chat/models/conversation_snipet.dart';
import 'package:ft_chat/pages/conversation_page.dart';
import 'package:ft_chat/providers/auth_provider.dart';
import 'package:ft_chat/services/db_service.dart';
import 'package:ft_chat/services/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentConversationsPage extends StatelessWidget {
  final double height;
  final double width;
  late AuthProvider _auth;
  RecentConversationsPage({required this.height, required this.width});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance, child: buildListConversations());
  }

  Widget buildListConversations() {
    return Builder(builder: (context) {
      _auth = Provider.of<AuthProvider>(context);
      return Container(
          height: height,
          width: width,
          child: StreamBuilder<List<ConversationSnipet>>(
            stream: DBService.instance.getUserConversations(_auth.user!.uid),
            builder: (context, snapshot) {
              var data = snapshot.data;
              if (snapshot.hasData && data != null) {
                if (data.length == 0) {
                  return Center(
                    child: Text("Not Conversation Yet",
                        style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return _buildListTile(context, data[index]);
                    });
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ));
    });
  }

  Widget _buildListTile(context, ConversationSnipet data) {
    return ListTile(
      onTap: () {
        NavigationService.instance
            .navigatorToRoute(MaterialPageRoute(builder: (context) {
          return ConversationPage(
              conversationID: data.chatID,
              receiverID: data.id,
              receiverImage: data.image,
              receiverName: data.name);
        }));
      },
      title: Text(data.name),
      subtitle: Text(data.lastMessage),
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(data.image),
      ),
      trailing: _buildTraling(data.timestamp),
    );
  }

  Column _buildTraling(Timestamp lastSeen) {
    // var timeDifference = lastSeen.toDate().difference(DateTime.now());
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "Last Message",
          style: TextStyle(fontSize: 15),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          timeago.format(lastSeen.toDate()),
          style: TextStyle(fontSize: 15),
        ),
        // Container(
        //   height: 12,
        //   width: 12,
        //   decoration: BoxDecoration(
        //       color: timeDifference.inHours > 1 ? Colors.green : Colors.red,
        //       borderRadius: BorderRadius.circular(50)),
        // )
      ],
    );
  }
}
