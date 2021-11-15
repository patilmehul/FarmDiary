// ignore_for_file: unused_import, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_diary/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateSeason extends StatefulWidget {
  const CreateSeason({Key? key}) : super(key: key);

  @override
  _CreateSeasonState createState() => _CreateSeasonState();
}

class _CreateSeasonState extends State<CreateSeason> {
  final key = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  late String seasonName;

  DateTime startDate = DateTime.now();

  Future _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(1900, 1),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != startDate) {
      setState(() {
        startDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a new season"),
        centerTitle: true,
      ),
      body: Form(
        key: key,
        child: ListView(
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Enter the Season Name: ",
                ),
                onChanged: (val) {
                  setState(() {
                    seasonName = val;
                  });
                },
                validator: (val) {
                  if (val == "") {
                    return "This Field Cannot be Empty";
                  }
                  return null;
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    _selectDate(context).whenComplete(
                        () => Fluttertoast.showToast(msg: "Date Selected"));
                  },
                  child: Text("Select Start Date of Season")),
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () async {
                    if (key.currentState!.validate()) {
                      Fluttertoast.showToast(msg: "Creating New Season");
                      try {
                        dynamic d = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(_auth.currentUser!.uid)
                            .get();

                        List seasons = d['seasons'];
                        seasons.add({
                          'seasonName': seasonName,
                          'startDate': startDate,
                        });

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(_auth.currentUser!.uid)
                            .update({
                          'seasons': seasons,
                        });

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(_auth.currentUser!.uid)
                            .collection('seasons')
                            .doc(seasonName)
                            .set({
                          "particulars": [],
                        });

                        Fluttertoast.showToast(
                            msg: "Season Created Successfully");
                        Navigator.pop(context);
                      } catch (e) {
                        Fluttertoast.showToast(msg: "Oops! An Error Occurred");
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text("Create New Season")),
            ),
          ],
        ),
      ),
    );
  }
}
