// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Member {
  String? name;
  DocumentReference? reference;
  get isSet => name != null && reference != null;
  Member({
    required this.name,
    required this.reference,
  });
}

class GetMemberButton extends StatefulWidget {
  final ValueChanged<Member> notifier;

  const GetMemberButton({
    super.key,
    required this.notifier,
  });
  @override
  State<GetMemberButton> createState() => _GetMemberButtonState();
}

class _GetMemberButtonState extends State<GetMemberButton> {
  List<String> list = [];
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;
  DocumentReference? selectedtrip;
  DocumentSnapshot? currentUser;

  var members = [];
  String name = "Select a member";
  String? currentUserName;
  List<DocumentReference> memberDocu = [];

  @override
  void initState() {
    super.initState();
    getMembers();
  }

  getMembers() async {
    currentUser = await firestore.collection("users").doc(user.uid).get();
    String selectedTripID =
        (currentUser!.data() as Map<String, dynamic>)["selectedtrip"];
    selectedtrip = firestore.collection("trips").doc(selectedTripID);
    members =
        ((await selectedtrip!.get()).data() as Map<String, dynamic>)["members"];
    var memberIDList = [];
    setState(() {
      for (var i = 0; i < members.length; i++) {
        if ((members[i] as DocumentReference).id != user.uid) {
          memberDocu.add((members[i] as DocumentReference));
          memberIDList.add((members[i] as DocumentReference).id);
        } else {
          currentUserName =
              (currentUser!.data() as Map<String, dynamic>)["prename"] +
                  " " +
                  (currentUser!.data() as Map<String, dynamic>)["lastname"];
        }
      }
    });

    for (var i = 0; i < memberIDList.length; i++) {
      var userData =
          await firestore.collection("users").doc(memberIDList[i]).get();
      setState(() {
        String prename = userData['prename'];
        String lastname = userData['lastname'];
        list.add("$prename $lastname");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: CupertinoButton.filled(
          borderRadius: BorderRadius.circular(11),
          child: Text(name), // hier muss dann value hin (name)
          onPressed: () => showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) =>
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16))),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            SizedBox(
                                width: double.infinity,
                                height: 250,
                                child: CupertinoPicker(
                                  backgroundColor: Colors.white,
                                  itemExtent: 50,
                                  scrollController: FixedExtentScrollController(
                                      initialItem: list.indexOf(name)),
                                  children: [
                                    for (int i = 0; i < list.length; i++)
                                      Center(
                                        child: Text(list[i],
                                            style:
                                                const TextStyle(fontSize: 20)),
                                      )
                                  ],
                                  onSelectedItemChanged: (int value) {
                                    setState(() {
                                      name = list[value];
                                      widget.notifier(Member(
                                        name: list[value],
                                        reference: memberDocu[value],
                                      ));
                                    });
                                  },
                                )),
                          ],
                        )),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                          borderRadius: null,
                          color: const Color.fromRGBO(103, 80, 164, 1.0),
                          child: const Text("Done"),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    )
                  ]))),
    );
  }
}
