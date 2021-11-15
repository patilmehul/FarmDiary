// ignore_for_file: unused_import, prefer_const_constructors

import 'package:farm_diary/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Root extends StatefulWidget {
  const Root({ Key? key }) : super(key: key);

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> firebase=Firebase.initializeApp();

    return FutureBuilder(
      future: firebase,
      builder: (BuildContext ctx,snapshot){

        if(snapshot.hasError){
          return Scaffold(
            appBar: AppBar(
              title: Text("Farm Diary"),
              centerTitle: true,
            ),
            body: Center(
              child: Text("Oops! An Error Occurred\nPlease Try Again..."),
            ),
          );
        }

        if(snapshot.connectionState==ConnectionState.done){
          return Home();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Farm Diary"),
            centerTitle: true,
          ),
          body: Center(child: CircularProgressIndicator(),),
        );
      }
    );
  }
}