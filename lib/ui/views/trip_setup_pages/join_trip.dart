import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

class JoinTrip extends StatelessWidget {
  JoinTrip({super.key});
  CollectionReference trips = FirebaseFirestore.instance.collection('trips');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final groupController = TextEditingController();

  void join_trip() async {
    final dir = groupController.text;
    final self = [
      FirebaseFirestore.instance.collection("users").doc(_auth.currentUser?.uid)
    ];
    FirebaseFirestore.instance
        .collection("users")
        .doc(_auth.currentUser?.uid)
        .set({"selectedtrip": dir});
    trips.doc(dir).update({"members": FieldValue.arrayUnion(self)!});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFCBEFFF),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Stack(children: [
          Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/BackgroundCity.png'),
                    fit: BoxFit.cover),
              ),
              child: Center(
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 80, left: 14, right: 14, bottom: 45),
                    child:
                        CustomContainer(title: "Join your Friends", children: [
                      InputField(
                          controller: groupController,
                          hintText: "Trip Code",
                          obscureText: false),
                      MyButton(
                          onTap: () {
                            join_trip();
                          },
                          text: "Next")
                    ])),
              )),
        ])));
  }
}
