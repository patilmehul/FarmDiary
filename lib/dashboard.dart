// ignore_for_file: unused_import, prefer_const_constructors, prefer_final_fields, unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_diary/authentication.dart';
import 'package:farm_diary/home.dart';
import 'package:farm_diary/season.dart';
import 'package:farm_diary/seasonDashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Authentication _authentication = Authentication();
  FirebaseAuth _auth = FirebaseAuth.instance;

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
        title: Text(_auth.currentUser!.displayName! + "'s Farm Diary"),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(_auth.currentUser!.photoURL!),
              child: GestureDetector(
                onTap: () async {
                  showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          content: Text("Are you sure you want to Logout?"),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                },
                                child: Text("NO"),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.blueGrey)),
                            ElevatedButton(
                                onPressed: () async {
                                  await _authentication
                                      .signOutFromGoogle()
                                      .then((value) {
                                    Fluttertoast.showToast(
                                        msg: "Signing out...");
                                    Navigator.pop(ctx);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) => Home()));
                                  });
                                },
                                child: Text("YES"),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.blueGrey)),
                          ],
                        );
                      });
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Fluttertoast.showToast(msg: "New Season Creation Screen");
          Navigator.push(
              context, MaterialPageRoute(builder: (ctx) => CreateSeason()));
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Oops! An Error Occurred.\nPlease Try Again"),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            try {
              dynamic data = snapshot.data;
              List seasons = data['seasons'];

              if (seasons.isEmpty) {
                return Center(
                  child: Text("You have not created any seasons yet :)"),
                );
              }

              return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemCount: seasons.length,
                  itemBuilder: (ctx, int index) {
                    return Padding(
                      padding: EdgeInsets.all(5),
                      child: GestureDetector(
                        onTap: () {
                          Timestamp ts = seasons[index]['startDate'];
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (ctx) => SeasonDashboard(
                                      seasons[index]['seasonName'],
                                      ts.toDate())));
                        },
                        onLongPress: () {
                          showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  content: Text(
                                      "Modify " + seasons[index]['seasonName']),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Fluttertoast.showToast(
                                            msg: "Edit the season start date");
                                        showDialog(
                                            context: ctx,
                                            builder: (c) {
                                              return AlertDialog(
                                                content: Text(seasons[index]
                                                    ['seasonName']),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        _selectDate(ctx)
                                                            .whenComplete(() =>
                                                                Fluttertoast
                                                                    .showToast(
                                                                        msg:
                                                                            "Date Selected"));
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        // ignore: prefer_const_literals_to_create_immutables
                                                        children: [
                                                          Text(
                                                              "Select New Start Date of Season"),
                                                          Icon(Icons
                                                              .calendar_today),
                                                        ],
                                                      )),
                                                  ElevatedButton(
                                                      onPressed: () async {
                                                        try {
                                                          print(seasons);
                                                          seasons[index][
                                                                  'startDate'] =
                                                              startDate;
                                                          print(seasons);
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .doc(_auth
                                                                  .currentUser!
                                                                  .uid)
                                                              .update({
                                                            'seasons': seasons,
                                                          });
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Season Start Date Updated");
                                                          Navigator.pop(ctx);
                                                        } catch (e) {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Failed to update the date!\nPlease try again");
                                                        }
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        // ignore: prefer_const_literals_to_create_immutables
                                                        children: [
                                                          Text(
                                                              "Save the change"),
                                                          Icon(Icons.save),
                                                        ],
                                                      )),
                                                ],
                                              );
                                            });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        // ignore: prefer_const_literals_to_create_immutables
                                        children: [
                                          Text(
                                              "Edit the \nstart date of season"),
                                          Icon(Icons.calendar_today),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          Fluttertoast.showToast(
                                              msg: "Delete the season");
                                          showDialog(
                                              context: ctx,
                                              builder: (c) {
                                                return AlertDialog(
                                                  content: Text(
                                                      "Are you sure you want to delete the season - " +
                                                          seasons[index]
                                                              ['seasonName'] +
                                                          " ?\n\n(You will not be able to undo this action)"),
                                                  actions: [
                                                    ElevatedButton(
                                                        onPressed: () async {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Deleting the season");
                                                          try {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(_auth
                                                                    .currentUser!
                                                                    .uid)
                                                                .collection(
                                                                    'seasons')
                                                                .doc(seasons[
                                                                        index][
                                                                    'seasonName'])
                                                                .delete();
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Season Deleted");
                                                            seasons.removeAt(
                                                                index);
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(_auth
                                                                    .currentUser!
                                                                    .uid)
                                                                .update({
                                                              'seasons': seasons
                                                            });
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Season Deleted");
                                                            Navigator.pop(ctx);
                                                            Navigator.pop(
                                                                context);
                                                          } catch (e) {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Failed to delete the season");
                                                            Navigator.pop(ctx);
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        },
                                                        child: Text(
                                                            "Yes, Delete")),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(ctx);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                            Text("No, Go Back"))
                                                  ],
                                                );
                                              });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          // ignore: prefer_const_literals_to_create_immutables
                                          children: [
                                            Text("Delete the season"),
                                            Icon(Icons.delete)
                                          ],
                                        )),
                                  ],
                                  actionsAlignment: MainAxisAlignment.start,
                                );
                              });
                        },
                        child: Card(
                          child: Center(
                              child: Text(
                            seasons[index]['seasonName'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                        ),
                      ),
                    );
                  });
            } catch (e) {
              return Center(
                child: Text("Oops! An Error occurred :("),
              );
            }
          }),
    );
  }
}
