import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

class JoinTrip extends StatelessWidget {
  JoinTrip({super.key});
  final CollectionReference trips =
      FirebaseFirestore.instance.collection('trips');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final groupController = TextEditingController();

  void joinTrip() async {
    final self = _auth.currentUser?.uid;

    final dir = groupController.text;
    trips.doc(dir).update({
      "members": FieldValue.arrayUnion(
          [FirebaseFirestore.instance.doc("/users/" + self.toString())])
    });
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
                        top: 200, left: 14, right: 14, bottom: 230),
                    child:
                        CustomContainer(title: "Join your Friends", children: [
                      InputField(
                          margin: const EdgeInsets.only(top: 15, bottom: 10),
                          controller: groupController,
                          hintText: "Trip Code",
                          obscureText: false),
                      MyButton(
                          margin: const EdgeInsets.only(bottom: 10),
                          onTap: () {
                            joinTrip();
                            context.go("/");
                          },
                          text: "Next"),
                      MyButton(
                          margin: const EdgeInsets.only(bottom: 10),
                          onTap: () {
                            context.pop();
                          },
                          text: "Cancel")
                    ])),
              )),
        ])));
  }
}
