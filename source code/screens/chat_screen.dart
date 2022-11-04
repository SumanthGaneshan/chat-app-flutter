import 'package:chat_app/widgets/chat/messages.dart';
import 'package:chat_app/widgets/chat/new_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String? userChatId;
  final String secondUserId;
  final String userName;
  final String userImageUrl;

  ChatScreen(
      this.userChatId, this.secondUserId, this.userName, this.userImageUrl);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // @override
  // void initState() {
  //   final fbm = FirebaseMessaging.instance;
  //   FirebaseMessaging.onMessage.listen((message) {
  //     print(message);
  //     return;
  //   });
  //   FirebaseMessaging.onMessageOpenedApp.listen((message) {
  //     print(message);
  //     return;
  //   });
  //   super.initState();
  // }


  bool isChatExists = false;

  Future<String> getChatId() async {
    final user = FirebaseAuth.instance.currentUser;
    final docRef =
        await FirebaseFirestore.instance.collection('indv-chats').get();
    for (var docData in docRef.docs) {
      List separatedId = docData.id.split('+');

      if (separatedId.contains(user!.uid) &&
          separatedId.contains(widget.secondUserId)) {
        isChatExists = true;

        return docData.id;
      }
    }
    return '${user!.uid}+${widget.secondUserId}';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Color(0xfff5f5f5),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.userImageUrl),
              radius: 18,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              widget.userName,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        elevation: 3,
      ),
      body: FutureBuilder(
          future: getChatId(),
          builder: (ctx, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(
                child: CircularProgressIndicator(),
              );
            return Column(
              children: [
                Expanded(
                  child: Messages(snapshot.data),
                ),
                NewMessage(snapshot.data, widget.secondUserId, isChatExists),
              ],
            );
          }),
    );
  }
}
