// ignore_for_file: prefer_const_constructors

import 'package:farm_diary/authentication.dart';
import 'package:farm_diary/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Colors.grey,
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Farm\nDiary",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: size.height * 0.07),
                    ),
                    // ignore: prefer_const_literals_to_create_immutables
                    Image(
                      image: AssetImage('images/grapes_diary.png'),
                      //height: size.height,
                    ),
                    Padding(
                      padding: EdgeInsets.all(18.0),
                      child: SignInButton(
                        Buttons.GoogleDark,
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          Authentication _authentication = Authentication();
                          try {
                            await _authentication
                                .signInwithGoogle()
                                .whenComplete(() {
                              Fluttertoast.showToast(msg: "Signed In!");
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (ctx) => Dashboard()));
                            });
                          } catch (e) {
                            if (e is FirebaseAuthException) {
                              Fluttertoast.showToast(
                                  msg: "Error occurred while signing in...!");
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ));
  }
}
