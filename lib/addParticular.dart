// ignore_for_file: file_names, use_key_in_widget_constructors, must_be_immutable, prefer_const_constructors, unnecessary_string_interpolations, avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class AddParticular extends StatefulWidget {
  //const AddParticular({ Key? key }) : super(key: key);

  String seasonName;
  DateTime startDate;
  AddParticular(this.seasonName, this.startDate);

  @override
  _AddParticularState createState() => _AddParticularState();
}

class _AddParticularState extends State<AddParticular> {



  bool isDone=true;

  @override
  void initState(){
    super.initState();
    isDone=true;
  }

  setIsDone(bool val){
    setState(() {
      isDone=val;
    });
  }

  final key = GlobalKey<FormState>();

  late String action;
  late String description;

  DateTime date = DateTime.now();

  final _auth = FirebaseAuth.instance;

  late File imageFile;
  bool isEmpty = true;
  ImagePicker picker = ImagePicker();

  String imageUrl = "";

  Widget buildImage() => Container(
        height: 150,
        width: 150,
        child: !isEmpty
            ? Image.file(imageFile)
            : Icon(Icons.photo, size:80,color: Colors.blueGrey),
      );

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
      body: Form(
        key: key,
        child: ListView(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              Padding(
                padding: EdgeInsets.all(18.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter the action name",
                  ),
                  onChanged: (val) {
                    setState(() {
                      action = val;
                    });
                  },
                  validator: (val) {
                    if (val == "") {
                      return "This Field cannot be empty";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(18.0),
                child: TextFormField(
                  decoration: InputDecoration(
                      hintText: "Enter the description of the action"),
                  onChanged: (val) {
                    setState(() {
                      description = val;
                    });
                  },
                  validator: (val) {
                    if (val == "") {
                      return "This Field cannot be empty";
                    }
                    return null;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(date.day.toString() +
                      "/" +
                      date.month.toString() +
                      "/" +
                      date.year.toString()),
                  ElevatedButton.icon(
                    label: Text("Change the date"),
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      _selectDate(context).whenComplete(
                          () => Fluttertoast.showToast(msg: "Date Changed"));
                    },
                    //child: Text(""),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildImage(),
                  ElevatedButton(
                      onPressed: () async {
                        var image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            imageFile = File(image.path);
                            isEmpty = false;
                          });
                          Fluttertoast.showToast(msg: "Image Selected");
                        }
                      },
                      child: Text('Select Image')),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          isEmpty = true;
                        });
                        Fluttertoast.showToast(msg: "Image removed");
                      },
                      icon: Icon(Icons.undo_sharp)),
                ],
              ),

              ButtonBar(
                alignment: MainAxisAlignment.start,
                children: [
                  Text("Is Action Done? - "),
                  Text("Yes"),
                  Radio(
                    value: true, 
                    groupValue: isDone, 
                    onChanged: (val){
                      setIsDone(true);
                    }
                  ),
                  Text("No"),
                  Radio(
                    value: false, 
                    groupValue: isDone, 
                    onChanged: (val){
                      setIsDone(false);
                    }
                  ),
                ],
              ),

              Center(
                child: ElevatedButton.icon(
                  label: Text("Add the action"),
                  icon: Icon(Icons.check_sharp),
                  onPressed: () async {
                    if (key.currentState!.validate()) {
                      Fluttertoast.showToast(msg: "Adding the action...");
                      try {

                        if(!isEmpty){
                            String fileName = basename(imageFile.path);
                            Reference reference = FirebaseStorage.instance
                                .ref()
                                .child(_auth.currentUser!.displayName!+"/${widget.seasonName}"+'/$fileName');
                            UploadTask uploadTask = reference.putFile(imageFile);
                            TaskSnapshot snapshot = await uploadTask;
                            imageUrl = await snapshot.ref.getDownloadURL();
                            print(imageUrl);
                        }

                        dynamic d = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(_auth.currentUser!.uid)
                            .collection('seasons')
                            .doc(widget.seasonName)
                            .get();

                        List particulars = d['particulars'];

                        particulars.add({
                          'date': date,
                          'action': action,
                          'description': description,
                          'isImg':!isEmpty,
                          'imageUrl':imageUrl,
                          'isDone':isDone,
                        });

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(_auth.currentUser!.uid)
                            .collection('seasons')
                            .doc(widget.seasonName)
                            .update({'particulars': particulars}).then((value) {
                          Fluttertoast.showToast(msg: "Action Added");
                          Navigator.pop(context);
                        });
                      } catch (e) {
                        Fluttertoast.showToast(msg: "Oops! An Error Occurred");
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              )
            ]),
      ),
    );
  }
}
