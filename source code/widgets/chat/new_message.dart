import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  final String? userChatId;
  final String secondUserId;
  bool chatExists;
  NewMessage(this.userChatId, this.secondUserId,this.chatExists);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _enteredMessage = '';
  final _controller = TextEditingController();
  ScrollController textFieldScrollController = ScrollController();

  void _sendMessage() async {
    // FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (widget.chatExists) {
    await FirebaseFirestore.instance
        .collection('indv-chats')
        .doc(widget.userChatId)
        .collection('chats')
        .add({
      'text': _enteredMessage.trim(),
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData['username'],
      'userImage': userData['image_url'],
    });

    }
    else {
      await FirebaseFirestore.instance
          .collection('indv-chats')
          .doc('${user.uid}+${widget.secondUserId}')
          .set({'s': 's'});

      await FirebaseFirestore.instance
          .collection('indv-chats')
          .doc(widget.userChatId)
          .collection('chats')
          .add({
        'text': _enteredMessage.trim(),
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': userData['username'],
        'userImage': userData['image_url'],
      });
      widget.chatExists = true;

    }
    _controller.clear();
    _enteredMessage = '';
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
    textFieldScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 2),
      padding: EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: Scrollbar(
              controller: textFieldScrollController,
              child: TextField(
                scrollController: textFieldScrollController,
                controller: _controller,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.keyboard,size: 25,),
                  filled: true,
                  fillColor: Color(0xFFEEEEEE),
                  isDense: true,
                  contentPadding: EdgeInsets.all(15),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelText: "Send a message...",
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _enteredMessage = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // begin: Alignment.centerLeft,
                // end: Alignment.centerRight,
                  colors: [Colors.indigo, Colors.blue]),
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: _enteredMessage.trim().isEmpty
                    ? Colors.white54
                    : Colors.white,
                size: 25,
              ),
              onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
            ),
          )
        ],
      ),
    );
  }
}
