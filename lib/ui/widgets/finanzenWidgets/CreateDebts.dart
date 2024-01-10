// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/centerText.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';

class CreateDebts extends StatefulWidget {
  final DocumentReference selectedTrip;
  const CreateDebts({
    super.key,
    required this.selectedTrip,
  });

  @override
  State<CreateDebts> createState() => _CreateDebtsState();
}

class _CreateDebtsState extends State<CreateDebts> {
  final title = TextEditingController();
  final description = TextEditingController();
  final amount = TextEditingController();

  var members = [];

  bool allowmultipleAnswers = false;

  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;
  DocumentReference? selectedtrip;
  DocumentSnapshot? currentUser;

  Future<void> getGroupmembers() async {
    currentUser = await firestore.collection("users").doc(user.uid).get();
    String selecttripString =
        (currentUser!.data() as Map<String, dynamic>)["selectedtrip"];
    selectedtrip = firestore.collection("trips").doc(selecttripString);
    members =
        ((await selectedtrip!.get()).data() as Map<String, dynamic>)["members"];
  }

  String membersName = "";

  Future<String> getMembersName(DocumentReference members) async {
    String prename = "";
    String lastname = "";
    // Hole den Namen des Users aus der Datenbank
    var user = FirebaseFirestore.instance.collection('users');
    var collection = user.doc(members.id);
    DocumentSnapshot userData = await collection.get();

    if (userData['prename'] != null) {
      setState(() {
        prename = userData['prename'];
      });
    }
    if (userData['lastname'] != null) {
      setState(() {
        prename = userData['lastname'];
      });
    }
    membersName = "$prename $lastname";
    return membersName;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGroupmembers();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          /* InputField(
              controller: title,
              hintText: "Title of Payment",
              focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
              borderColor: Colors.grey.shade400,
              obscureText: false),
          //      const SizedBox(height: 10),
          const SizedBox(height: 10),
          InputField(
              controller: description,
              hintText: "Description of Payment",
              focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
              borderColor: Colors.grey.shade400,
              multiline: true,
              obscureText: false),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: 150,
                  child: InputField(
                    controller: amount,
                    hintText: "Enter the amount",
                    obscureText: false,
                    numberField: true,
                    focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
                    borderColor: Colors.grey.shade400,
                  )),
              Row(
                children: [
                  const Text(
                    "Share Equally",
                    style: Styles.inputField,
                  ),
                  Checkbox(
                      value: allowmultipleAnswers,
                      onChanged: (value) {
                        setState(() {
                          allowmultipleAnswers = value!;
                        });
                      }),
                ],
              ),
            ],
          ), */
          const SizedBox(height: 10),
          for (int i = 0; i < members.length; i++)
            FutureBuilder(
                future: getMembersName(members[i]),
                builder: (context, members) {
                  if (members.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (members.hasError) {
                    debugPrint(members.error.toString());
                    return const CenterText(
                        text: "Error while fetching Payments");
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        members.toString(),
                        style: Styles.inputField,
                      ),
                      SizedBox(
                        width: 150,
                        child: InputField(
                          controller: TextEditingController(),
                          hintText: "Enter the amount",
                          obscureText: false,
                          numberField: true,
                          focusedBorderColor:
                              const Color.fromARGB(255, 84, 113, 255),
                          borderColor: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  );
                }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
