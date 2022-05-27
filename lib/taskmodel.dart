import 'package:firebass_authentication/authenthication.dart';
import 'package:firebass_authentication/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TasksPage extends StatefulWidget {
  final String uid;

  TasksPage({Key key, @required this.uid}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState(uid);
}

class _TasksPageState extends State<TasksPage> {
  final String uid;
  _TasksPageState(this.uid);

  var todocollection = Firestore.instance.collection('vikash');
  String task;
  String details;

  void adddata() {}

  void showdialog(bool isUpdate, DocumentSnapshot ds) {
    GlobalKey<FormState> formkey = GlobalKey<FormState>();
    GlobalKey<FormState> formkey1 = GlobalKey<FormState>();

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: isUpdate ? Text("Update Todo") : Text("Add Todo"),
            content: Column(
              children: [
                Form(
                  key: formkey,
                  
                  child: TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Task",
                    ),
                    validator: (_val) {
                      if (_val.isEmpty) {
                        return "Can't Be Empty";
                      } else {
                        return null;
                      }
                    },
                    onChanged: (_val) {
                      task = _val;
                    },
                  ),
                ),
                Form(
                  key: formkey1,
                  
                  child: TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Task",
                    ),
                    validator: (_val) {
                      if (_val.isEmpty) {
                        return "Can't Be Empty";
                      } else {
                        return null;
                      }
                    },
                    onChanged: (_val) {
                      details = _val;
                    },
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              RaisedButton(
                color: Colors.purple,
                onPressed: () {
                  print(task);
                  if (formkey.currentState.validate()) {
                    formkey.currentState.save();
                    if (isUpdate) {
                      print(uid);
                      print(ds.documentID);
                      todocollection
                          .document(uid)
                          .collection('task')
                          .document(ds.documentID)
                          .updateData({
                        'task': task,
                        'time': DateTime.now(),
                      });
                    } else {
                      //  insert
                      print(task);
                      todocollection.document(uid).collection('task').add({
                        'task': task,
                        'details': details,
                        'time': DateTime.now(),
                      });
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  "Add",
                  style: TextStyle(
                    fontFamily: "tepeno",
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showdialog(false, null),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text(
          "Tasks",
          style: TextStyle(
            fontFamily: "tepeno",
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () => signOutUser().then((value) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false);
            }),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: todocollection
            .document(uid)
            .collection('task')
            .orderBy('time')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print(snapshot.data);
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.documents[index];
                print(ds);
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      ds['task'],
                      style: TextStyle(
                        fontFamily: "tepeno",
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      ds['details'],
                      style: TextStyle(
                        fontFamily: "tepeno",
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                    onLongPress: () {
                      // delete
                      todocollection
                          .document(uid)
                          .collection('task')
                          .document(ds.documentID)
                          .delete();
                    },
                    onTap: () {
                      // == Update
                      showdialog(true, ds);
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return CircularProgressIndicator();
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
