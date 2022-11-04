import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart';

class Messages extends StatefulWidget {
  final String? userChatId;

  Messages(this.userChatId);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  // final user = FirebaseAuth.instance.currentUser;
  // String chatId = '';
  //
  //
  // Future<String> getChatId() async{
  //   final refId = await FirebaseFirestore.instance.collection('indv-chats').get();
  //
  //   for (var docData in refId.docs) {
  //     List separated_id = docData.id.split('+');
  //
  //     if (separated_id.contains(user!.uid) && separated_id.contains(widget.userChatId)) {
  //         chatId = docData.id;
  //         break;
  //     }
  //   }
  //   return chatId;
  //
  // }

  // @override
  // initState(){
  //   super.initState();
  //   getChatId();
  // }

  @override
  Widget build(BuildContext context) {
    return widget.userChatId == null
        ? Center(
            child: Text("No Chats"),
          )
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('indv-chats')
                .doc(widget.userChatId)
                .collection('chats')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (ctx, AsyncSnapshot chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final chatDocs = chatSnapshot.data.docs;
              final user = FirebaseAuth.instance.currentUser;

              return ListView.builder(
                reverse: true,
                itemCount: chatDocs.length,
                itemBuilder: (ctx, index) => MessageBubble(
                  chatDocs[index]['text'],
                  chatDocs[index]['userId'] == user!.uid,
                  chatDocs[index]['username'],
                  chatDocs[index]['userImage'],
                  chatDocs[index]['createdAt'],
                  key: ValueKey(chatDocs[index].id),
                ),
              );
            });
  }
}
