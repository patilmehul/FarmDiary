// ignore_for_file: unused_import, prefer_final_fields, prefer_const_constructors, unused_field

import 'package:farm_diary/dashboard.dart';
import 'package:farm_diary/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  FirebaseAuth _auth=FirebaseAuth.instance;
  
  @override
  Widget build(BuildContext context) {
    return (_auth.currentUser!=null) ? Dashboard() : SignIn();
  }
}