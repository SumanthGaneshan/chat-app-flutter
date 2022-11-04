import 'package:chat_app/screens/all_contact.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class RecentChats extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');

  bool isChatExists = false;

  // Future<String> getChatId() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   final docRef =
  //   await FirebaseFirestore.instance.collection('indv-chats').get();
  //   for (var docData in docRef.docs) {
  //     List separatedId = docData.id.split('+');
  //
  //     if (separatedId.contains(user!.uid)) {
  //       isChatExists = true;
  //
  //       return docData.id;
  //     }
  //   }
  //   return '${user!.uid}+${widget.secondUserId}';
  // }


  @override
  Widget build(BuildContext context) {
    print(alphanumeric.pattern);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Chat Application'),
        actions: [
          DropdownButton(
              underline: Container(),
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              items: [
                DropdownMenuItem(
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app),
                        Text("Logout"),
                      ],
                    ),
                  ),
                  value: 'logout',
                )
              ],
              onChanged: (value) {
                if (value == 'logout') {
                  FirebaseAuth.instance.signOut();
                }
              }),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('indv-chats')
            .doc("${user!.uid}+${alphanumeric.pattern}")
            .collection('chats')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, AsyncSnapshot chatSnapshot) {
          print(chatSnapshot.data.docs);
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final userDocs = chatSnapshot.data!.docs;
          return ListView.builder(
              itemCount: userDocs.length,
              itemBuilder: (ctx, index) {
                if (user!.uid != chatSnapshot.data.docs[index].reference.id) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: ListTile(
                        title: Text(
                          userDocs[index]['username'],
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text('Subtitle'),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundImage:
                              NetworkImage(userDocs[index]['image_url']),
                        ),
                        onTap: () async {
                          final String an_user_id =
                              chatSnapshot.data.docs[index].reference.id;
                          final user = FirebaseAuth.instance.currentUser;

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => ChatScreen(
                                  '${user!.uid}+$an_user_id',
                                  an_user_id,
                                  userDocs[index]['username'],
                                  userDocs[index]['image_url'])));
                        }),
                  );
                } else {
                  return Container();
                }
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xffFF4567),
        onPressed: () {
          Navigator.of(context).pushNamed(AllContact.routeName);
        },
        child: Icon(
          Icons.phone,
          color: Colors.white,
        ),
      ),
    );
  }
}
