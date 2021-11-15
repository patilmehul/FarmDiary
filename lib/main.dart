// ignore_for_file: prefer_const_constructors

// ignore_for_file: unused_import

import 'package:farm_diary/root.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: Root(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
