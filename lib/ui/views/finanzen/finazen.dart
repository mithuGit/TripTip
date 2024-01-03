import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/centerText.dart';
import 'package:internet_praktikum/ui/widgets/headerWidgets/topbar.dart';
import '../../widgets/finanzenWidgets/extendablecontainer.dart';

class Finanzen extends StatefulWidget {
  const Finanzen({Key? key}) : super(key: key);

  @override
  State<Finanzen> createState() => _FinanzenState();
}

class _FinanzenState extends State<Finanzen> {
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  DocumentReference? selectedtrip;
  DocumentSnapshot? currentUser;
  Future<List<DocumentSnapshot>> getGroupmembers() async {
    currentUser = await firestore.collection("users").doc(user.uid).get();
    String selecttripString =
        (currentUser!.data() as Map<String, dynamic>)["selectedtrip"];
    selectedtrip = firestore.collection("trips").doc(selecttripString);
    List groupmembers =
        ((await selectedtrip!.get()).data() as Map<String, dynamic>)["members"];
    List<DocumentSnapshot> groupmembersSnaps = [];
    for (int i = 0; i < groupmembers.length; i++) {
      groupmembersSnaps
          .add(await firestore.collection("users").doc(groupmembers[i]).get());
    }
    return groupmembersSnaps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: TopBar(
        isFinanz: true,
        icon: Icons.add,
        onTapForIconWidget: () {
          CustomBottomSheet.show(context,
              title: "Add a receipt and set the other embers dues.",
              content: [
                Builder(
                  builder: (context) {
                    return const Center(
                        // hier kommt noch die Schuldenüsetzung und Beleg hinzufügen über Galerie oder Foto
                        );
                  },
                ),
              ]);
        },
        title: "Payments",
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_city_persona.png'),
                fit: BoxFit.cover, // Maintain width, adjust height
              ),
            ),
          ),
          FutureBuilder(
              future: getGroupmembers(),
              builder: (context, members) {
                if (members.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (members.hasError) {
                  debugPrint(members.error.toString());
                  return const CenterText(
                      text: "Error while fetching Groupmembers");
                }
                return StreamBuilder<QuerySnapshot>(
                    stream: selectedtrip!.collection("payments").snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        debugPrint(snapshot.error.toString());
                        return const CenterText(
                            text: "Error while fetching Payments");
                      }
                      List<DocumentSnapshot> payments = snapshot.data!.docs;
                      Map<String, dynamic> users = {};
                      for (int i = 0; i < members.data!.length; i++) {
                        users[members.data![i].id] = [];
                      }

                      for (int i = 0; i < payments.length; i++) {
                        Map<String, dynamic> payment =
                            payments[i].data()! as Map<String, dynamic>;
                        if (payment["to"] != null) {
                          if ((payment["to"] as List).contains(user.uid)) {
                            users[user.uid].add(payment);
                          }
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: ListView(
                          padding: const EdgeInsets.only(
                              top: 20, left: 20, right: 20, bottom: 20),
                          children: members.data!.map((e) {
                            Map<String, dynamic> userdata =
                                e.data()! as Map<String, dynamic>;
                            return ExpandableContainer(
                              currentUser: e,
                              items: [
                                'Activity 1: 20.00',
                                'Activity 2: 10.00',
                              ],
                              sum: 45,
                            );
                          }).toList(),
                        ),
                      );
                    });
              }),
        ],
      ),
    );
  }
}
