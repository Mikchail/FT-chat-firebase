import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ft_chat/models/conversation_snipet.dart';
import 'package:ft_chat/models/message.dart';
import 'package:ft_chat/providers/auth_provider.dart';
import 'package:ft_chat/services/cloud_storage_service.dart';
import 'package:ft_chat/services/db_service.dart';
import 'package:ft_chat/services/media_service.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:io';

class ConversationPage extends StatefulWidget {
  String conversationID;
  String receiverID;
  String receiverImage;
  String receiverName;
  ConversationPage({
    required this.conversationID,
    required this.receiverID,
    required this.receiverImage,
    required this.receiverName,
  });

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late AuthProvider _auth;
  String _messageText = "";
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(31, 31, 31, 1.0),
        title: Text(widget.receiverName),
        centerTitle: true,
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _buildMessageUI(),
      ),
    );
  }

  Widget _buildMessageUI() {
    return Builder(builder: (context) {
      _auth = Provider.of<AuthProvider>(context);
      return Stack(
        clipBehavior: Clip.none,
        // TODO overflow
        children: [
          _messageListView(),
          Align(
            alignment: Alignment.bottomCenter,
            child: _messageField(context),
          )
        ],
      );
    });
  }

  Widget _messageListView() {
    return StreamBuilder<Conversation>(
        stream: DBService.instance.getConversation(widget.conversationID),
        builder: (context, snapshot) {
          var conversation = snapshot.data;
          if (snapshot.hasData && conversation != null) {
            var messages = conversation.messages;
            return Container(
              child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool _isOwnMessage = message.senderID == _auth.user!.uid;
                    return _messageListViewChild(_isOwnMessage, message);
                  }),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget _messageListViewChild(bool isOwnMessage, Message message) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            !isOwnMessage ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          !isOwnMessage ? _userImage() : Container(),
          message.type == MessageType.Text
              ? _textMessageBubble(
                  isOwnMessage, message.content, message.timestamp)
              : _imageMessageBubble(
                  isOwnMessage, message.content, message.timestamp),
        ],
      ),
    );
  }

  Widget _userImage() {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(widget.receiverImage),
      ),
    );
  }

  Widget _textMessageBubble(
      bool isOwnMessage, String message, Timestamp timestamp) {
    List<Color> colorScheme = isOwnMessage
        ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
    return Container(
      width: 300,
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
            colors: colorScheme,
            stops: [0.30, 0.70],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            SizedBox(
              height: 15,
            ),
            Text(timeago.format(timestamp.toDate()),
                style: TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _imageMessageBubble(
      bool isOwnMessage, String imageURL, Timestamp timestamp) {
    List<Color> colorScheme = isOwnMessage
        ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
            colors: colorScheme,
            stops: [0.30, 0.70],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 300,
              height: 100,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                      image: NetworkImage(
                        imageURL,
                      ),
                      fit: BoxFit.cover)),
            ),
            SizedBox(
              height: 15,
            ),
            Text(timeago.format(timestamp.toDate()),
                style: TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _messageField(context) {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
          color: Color.fromRGBO(43, 43, 43, 1),
          borderRadius: BorderRadius.circular(100)),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _messageTextField(),
            _senderMessageButton(context),
            _imageMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: SizedBox(
        width: 240,
        child: TextFormField(
          validator: (input) {
            if (input.toString().length == 0) {
              return "Please enter a message";
            }
            return null;
          },
          onChanged: (input) {
            _formKey.currentState?.save();
          },
          onSaved: (input) {
            setState(() {
              _messageText = input.toString();
            });
          },
          autocorrect: false,
          cursorColor: Colors.white,
          decoration: InputDecoration(
              border: InputBorder.none, hintText: "Type a message"),
        ),
      ),
    );
  }

  Widget _senderMessageButton(context) {
    return Container(
      height: 40,
      width: 40,
      child: IconButton(
        icon: Icon(Icons.send, color: Colors.white),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            DBService.instance.sendMessage(
                widget.conversationID,
                Message(
                  content: _messageText,
                  timestamp: Timestamp.now(),
                  senderID: _auth.user!.uid,
                  type: MessageType.Text,
                ));
            _formKey.currentState!.reset();
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }

  Widget _imageMessageButton() {
    return Container(
        height: 40,
        width: 40,
        child: FloatingActionButton(
          onPressed: () async {
            var image = await MediaService.instance.getImageFromLibrary();
            if (image != null) {
              var result = await CloudStorageService.instance
                  .uploadMediaMessage(_auth.user!.uid, File(image.path));
              var imageURL = await result.ref.getDownloadURL();
              DBService.instance.sendMessage(
                  widget.conversationID,
                  Message(
                      content: imageURL,
                      senderID: _auth.user!.uid,
                      timestamp: Timestamp.now(),
                      type: MessageType.Image));
            }
          },
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.camera_enhance,
            color: Colors.white,
          ),
        ));
  }
}
