// ignore_for_file: file_names, unused_import, use_key_in_widget_constructors, must_be_immutable, prefer_const_constructors, unused_local_variable, avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_diary/addParticular.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class SeasonDashboard extends StatefulWidget {
  //const SeasonDashboard({ Key? key }) : super(key: key);
  String seasonName;
  DateTime startDate;
  SeasonDashboard(this.seasonName, this.startDate);

  @override
  _SeasonDashboardState createState() => _SeasonDashboardState();
}

class _SeasonDashboardState extends State<SeasonDashboard> {
  final _auth = FirebaseAuth.instance;

  late String action;
  late String description;
  late DateTime date;

  late File imageFile;

  ImagePicker picker = ImagePicker();

  String imageUrl = "";


  Future _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900, 1),
        lastDate: DateTime(2101));
    if (pickedDate != null && pickedDate != date) {
      setState(() {
        date = pickedDate;
      });
    }
  }

  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.seasonName +
            "\n" +
            widget.startDate.day.toString() +
            "/" +
            widget.startDate.month.toString() +
            "/" +
            widget.startDate.year.toString()),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Fluttertoast.showToast(msg: "Add new particulars");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) =>
                      AddParticular(widget.seasonName, widget.startDate)));
        },
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('seasons')
            .doc(widget.seasonName)
            .snapshots(),
        builder: (context, snapshots) {
          if (!snapshots.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            try {
              dynamic d = snapshots.data;
              List particulars = d['particulars'];
              if (particulars.isEmpty) {
                return Center(
                  child: Text("You have not added any particulars yet :)"),
                );
              } else {

                
                particulars.sort((a,b)=>a['date'].compareTo(b['date']));
                print(particulars);

                return ListView.builder(
                    itemCount: particulars.length,
                    itemBuilder: (context, int index) {
                      Timestamp t = particulars[index]['date'];
                      DateTime Date = t.toDate();
                      int day =
                          Date.difference(widget.startDate).inDays.toInt();
                      bool isDone = particulars[index]['isDone'];
                      //print(isDone);
                      return Padding(
                        padding: EdgeInsets.all(3.0),
                        child: ExpansionTile(
                          title: Text(
                            particulars[index]['action'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          leading: Text(
                            "Day " + day.toString(),
                            style: TextStyle(
                              color: isDone ? Colors.green : Colors.white,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () async {
                              date = Date;
                              action = particulars[index]['action'];
                              description = particulars[index]['description'];
                              imageUrl = particulars[index]['imageUrl'];
                              
                              showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    bool isEmpty = true;
                                    bool is_done = isDone;
                                    return AlertDialog(
                                      content: Form(
                                        child: ListView(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(18.0),
                                              child: TextFormField(
                                                decoration: InputDecoration(
                                                  hintText: action,
                                                ),
                                                onChanged: (val) {
                                                  setState(() {
                                                    action = val;
                                                  });
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(18.0),
                                              child: TextFormField(
                                                decoration: InputDecoration(
                                                    hintText: description),
                                                onChanged: (val) {
                                                  setState(() {
                                                    description = val;
                                                  });
                                                },
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(date.day.toString() +
                                                    "/" +
                                                    date.month.toString() +
                                                    "/" +
                                                    date.year.toString()),
                                                ElevatedButton.icon(
                                                  label: Text(""),
                                                  icon: Icon(
                                                      Icons.calendar_today),
                                                  onPressed: () {
                                                    _selectDate(context)
                                                        .whenComplete(() =>
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Date Changed"));
                                                  },
                                                  //child: Text(""),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () async {
                                                      var image = await picker
                                                          .pickImage(
                                                              source:
                                                                  ImageSource
                                                                      .gallery);
                                                      if (image != null) {
                                                        setState(() {
                                                          imageFile =
                                                              File(image.path);
                                                          isEmpty = false;
                                                        });
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Image Selected");
                                                      }
                                                    },
                                                    child:
                                                        Text('Select Image')),
                                                IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        isEmpty = true;
                                                        imageUrl = "";
                                                      });
                                                      Fluttertoast.showToast(
                                                          msg: "Image removed");
                                                    },
                                                    icon:
                                                        Icon(Icons.undo_sharp)),
                                              ],
                                            ),
                                            Row(
                                              // ignore: prefer_const_literals_to_create_immutables
                                              children: [
                                                Text("Is Done? - "),
                                                Text(isDone ? "Yes" : "No"),
                                                IconButton(
                                                  onPressed: (){
                                                    setState(() {
                                                      isDone=!isDone;
                                                    });
                                                    Fluttertoast.showToast(msg: isDone ? "Action Done?-Yes" : "Action Done?- No");
                                                  }, 
                                                  icon: Icon(Icons.undo_sharp)
                                                ),
                                              ],
                                            ),
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  Fluttertoast.showToast(
                                                      msg: "Updating");
                                                  try {
                                                    if (!isEmpty) {
                                                      String fileName =
                                                          basename(
                                                              imageFile.path);
                                                      Reference reference = FirebaseStorage
                                                          .instance
                                                          .ref()
                                                          .child(_auth
                                                                  .currentUser!
                                                                  .displayName! +
                                                              "/${widget.seasonName}" +
                                                              '/$fileName');
                                                      UploadTask uploadTask =
                                                          reference.putFile(
                                                              imageFile);
                                                      TaskSnapshot snapshot =
                                                          await uploadTask;
                                                      imageUrl = await snapshot
                                                          .ref
                                                          .getDownloadURL();
                                                      print(imageUrl);
                                                    }

                                                    particulars[index]
                                                        ['action'] = action;
                                                    particulars[index]
                                                            ['description'] =
                                                        description;
                                                    particulars[index]['date'] =
                                                        date;
                                                    particulars[index]
                                                        ['isImg'] = !isEmpty;
                                                    particulars[index]
                                                        ['imageUrl'] = imageUrl;
                                                    particulars[index]
                                                        ['isDone'] = isDone;
                                                    
                                                    

                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(_auth
                                                            .currentUser!.uid)
                                                        .collection('seasons')
                                                        .doc(widget.seasonName)
                                                        .update({
                                                      'particulars': particulars
                                                    });
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Action Data Updated");
                                                    Navigator.pop(context);
                                                  } catch (e) {
                                                    Fluttertoast.showToast(
                                                        msg: "Update Failed");
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: Text("Update"),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            icon: Icon(Icons.edit),
                          ),
                          childrenPadding: EdgeInsets.all(18),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            Text(particulars[index]['description']),
                            particulars[index]['imageUrl'] != ""
                                ? Image(
                                    image: NetworkImage(
                                        particulars[index]['imageUrl']))
                                : Text(""),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                  onPressed: () async {
                                    showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          return AlertDialog(
                                            content: Text(
                                                "Are you sure you want to delete this?\n\n(You won't be able to undo this)"),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    try {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Deleting action...");
                                                      particulars
                                                          .removeAt(index);
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .doc(_auth
                                                              .currentUser!.uid)
                                                          .collection('seasons')
                                                          .doc(
                                                              widget.seasonName)
                                                          .update({
                                                        'particulars':
                                                            particulars
                                                      });
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Action Deleted");
                                                      Navigator.pop(context);
                                                    } catch (e) {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Failed to Delete");
                                                    }
                                                  },
                                                  child: Text("Yes, Delete")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("No, Go Back"))
                                            ],
                                          );
                                        });
                                  },
                                  icon: Icon(Icons.delete)),
                            ),
                          ],
                        ),
                      );
                    });
              }
            } catch (e) {
              return Center(
                child: Text("Oops! An Error Occurred.\nPlease Try Again"),
              );
            }
          }
        },
      ),
    );
  }
}
