import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:intl/intl.dart';

class UsernameBagageDashboardWidget extends StatelessWidget {
  final Map<String, dynamic>? data;
  UsernameBagageDashboardWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    Future<Map<String, dynamic>> getUserData() async {
      DocumentSnapshot userdata =
          await FirebaseFirestore.instance.doc(data?["createdBy"].path).get();

      if (!userdata.exists)
        throw Exception("Document does not exist on the database");

      print('Document data: ${userdata.data()}');
      Map<String, dynamic> _userData = userdata.data()! as Map<String, dynamic>;
      _userData["createdAt"] =
          DateFormat('hh:mm').format(data?["createdAt"].toDate());    

      return _userData;
    }

    return FutureBuilder(
        future: getUserData(),
        builder: (builder, snapshot) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red));
          }
          if (snapshot.hasData) {
            return Container(
              margin: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipOval(
                  
                    child: Image.network(
                      snapshot.data!["profilePicture"],
                      width: 22,
                      height: 22,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 7),
                    child: Text(
                        'created by ' +
                            snapshot.data!["prename"] +
                            ' ' +
                            snapshot.data!["lastname"] +
                            ' at ' +
                            snapshot.data!["createdAt"],
                        style: Styles.usernameBagageWidget),
                  ),
                ],
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
