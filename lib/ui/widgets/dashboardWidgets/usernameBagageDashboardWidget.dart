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
          DateFormat('HH:mm').format(data?["createdAt"].toDate());

      return _userData;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          data!["profilePicture"] != null ? ClipOval(
            child: Image.network(
              data!["profilePicture"],
              width: 22,
              height: 22,
            ),
          ) : ClipOval(
            child: Image.asset(
              "assets/Personavatar.png",
              width: 22,
              height: 22,
            ),
          ),
          if(data!["prename"] != null && data!["lastname"] != null)
          Container(
            margin: const EdgeInsets.only(left: 7),
            child: Text(
                // ignore: prefer_interpolation_to_compose_strings
                'created by ' +
                    data!["prename"] +
                    ' ' +
                    data!["lastname"] +
                    ' at ' +
                    DateFormat('HH:mm').format((data!["createdAt"] as Timestamp).toDate()),
                style: Styles.usernameBagageWidget),
          ),
        ],
      ),
    );
  }
}
