import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static String routeName = '/chat-screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final messageTextController = TextEditingController();
  User? loggedInUser;
  String messageText = '';
  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
      print('Error in chat_screen file on line 19');
    }
  }

  void messagesStream() async {
    await _firestore.collection('messages').snapshots().listen(
      (snapshot) {
        for (var message in snapshot.docs) {
          print(message.data());
        }
      },
      onError: (error) {
        print('Error in messagesStream: $error');
        // Handle the error as needed
      },
      cancelOnError:
          false, // Set to true if you want to cancel the subscription on error
    );
  }

  @override
  void initState() {
    super.initState();
    print('Inside chat screen');
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                // _auth.signOut();
                // Navigator.pop(context);
                messagesStream();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // The data is still loading
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // An error occurred
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // No data available
                  return Text('No messages available.');
                } else {
                  // Data is available
                  final messages = snapshot.data!.docs.reversed;
                  List<Widget> textWidgets = [];

                  for (var message in messages) {
                    final messageText = message['text'];
                    final messageSender = message['sender'];
                    final messageWidget = MessageBubble(
                      messageText: messageText,
                      messageSender: messageSender,
                      isCurrentUser: true,
                      currentUser: loggedInUser,
                    );
                    textWidgets.add(messageWidget);
                  }

                  return Expanded(
                    child: ListView(
                      reverse: true,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      children: textWidgets,
                    ),
                  );
                }
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      messageTextController.clear();
                      try {
                        await _firestore.collection('messages').add({
                          'text': messageText,
                          'sender': loggedInUser?.email,
                        }).then((documentSnapshot) => print(
                            "Added Data with ID: ${documentSnapshot.id}"));
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.messageText,
    required this.messageSender,
    required this.isCurrentUser,
    required this.currentUser,
  }) : super(key: key);

  final String messageText;
  final String messageSender;
  final bool isCurrentUser;
  final User? currentUser;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: currentUser?.email == messageSender
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            messageSender,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12.0,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            decoration: BoxDecoration(
              color: currentUser?.email != messageSender
                  ? Colors.lightBlue
                  : Colors.lightGreen,
              borderRadius: currentUser?.email == messageSender
                  ? BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15))
                  : BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)),
            ),
            child: Text(
              '$messageText',
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
