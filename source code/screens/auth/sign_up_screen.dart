import 'dart:io';

import 'package:chat_app/screens/all_contact.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/sign-up';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userEmail = '';
  String _userName = '';
  String _userPassword = '';
  var _isLoading = false;
  File? _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _submit() async {
    setState(() {
      _isLoading = true;
    });
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_userImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please pick amn Image"),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      if (isValid) {
        _formKey.currentState!.save();
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${userCredential.user!.uid}.jpg');

        await ref.putFile(_userImageFile!);
        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': _userName,
          'email': _userEmail,
          'image_url': url,
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  // Color(0xffffd3db)
                  margin: EdgeInsets.only(top: 30,bottom: 40),
                  height: 50,
                  width: size.width * 0.6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "SIGN UP",
                    style: TextStyle(
                        fontSize: 23,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: UserImagePicker(_pickedImage),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Please enter valid email address. eg. abc@xvz.com';
                          }
                          return null;
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          hintText: 'Email (eg. abc@xyz.com)',
                          hintStyle: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                          fillColor: Color(0xFFEEEEEE),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onSaved: (value) {
                          _userEmail = value!;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty || value.length < 4) {
                            return 'Username too short';
                          }
                          return null;
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.account_circle,size: 25,),
                          hintText: 'Username (eg. Alex)',
                          hintStyle: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                          fillColor: Color(0xFFEEEEEE),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onSaved: (value) {
                          _userName = value!;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty || value.length < 7) {
                            return 'Password too short';
                          }
                          return null;
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock,size: 25,),
                          hintText: 'Password',
                          hintStyle: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                          fillColor: Color(0xFFEEEEEE),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onSaved: (value) {
                          _userPassword = value!;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    if (_isLoading)
                      Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ),
                    if (!_isLoading)
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: size.width * 0.9,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: Text(
                              'SIGN UP',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              // primary: Color.fromARGB(255,224, 176, 255).withOpacity(0.8),
                              onPrimary: Colors.white,
                              // shadowColor: Colors.deepPurple,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(32.0)), ////// HERE
                            ),
                          ),
                        ),
                      ),
                    if (!_isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already a user?",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          TextButton(
                            child: Text(
                              "LOGIN",
                              style: TextStyle(fontSize: 16, color: Colors.black,decoration: TextDecoration.underline),
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(LoginScreen.routeName);
                            },
                          ),
                        ],
                      ),
                  ],
                ))
          ]),
        ),
      ),
    );
  }
}
