import 'package:chat_app/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllContact extends StatelessWidget {
  static const routeName = 'all-contact';
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      // appBar: AppBar(
      //   title: const Text("Chat Application"),
      //   elevation: 0,
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 170,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        // begin: Alignment.centerLeft,
                        // end: Alignment.centerRight,
                        colors: [Colors.indigo, Colors.blue]),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          child: Text("Chat Application",style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.white
                          ),),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: IconButton(onPressed: (){
                              FirebaseAuth.instance.signOut();
                            }, icon: Icon(
                              Icons.exit_to_app,
                              size: 30,
                              color: Colors.white,
                            )),
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('users').snapshots(),
                        builder: (ctx, AsyncSnapshot chatSnapshot) {
                          if (chatSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final userDocs = chatSnapshot.data!.docs;
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                              itemCount: userDocs.length,
                              itemBuilder: (ctx, index) {
                                if (user!.uid != chatSnapshot.data.docs[index].reference.id) {
                                  return Padding(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    child: InkWell(
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
                                      },
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage: NetworkImage(userDocs[index]['image_url']),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            userDocs[index]['username'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: 15, left: 20),
                child: Text("Recent Chats",style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.indigo
                ),),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (ctx, AsyncSnapshot chatSnapshot) {
                  if (chatSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final userDocs = chatSnapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
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
            ],
          ),
        ),
      ),
    );
  }
}
