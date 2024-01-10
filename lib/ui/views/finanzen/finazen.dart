// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/centerText.dart';
import 'package:internet_praktikum/ui/widgets/finanzenWidgets/CreateDebts.dart';
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
              title: "Add a receipt and send the other members dues.",
              content: [
                Builder(builder: (context) {
                  if (selectedtrip == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return CreateDebts(selectedTrip: selectedtrip!);
                })
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
                      Map<String, List<Map<String, dynamic>>>
                          openRefundsPerUser = {};
                      Map<String, double> sumsPerUser = {};
                      for (int i = 0; i < members.data!.length; i++) {
                        openRefundsPerUser[members.data![i].id] = [];
                        sumsPerUser[members.data![i].id] = 0;
                      }

                      for (DocumentSnapshot payment in payments) {
                        Map<String, dynamic> paymentData =
                            payment.data()! as Map<String, dynamic>;
                        if (paymentData["to"] != null) {
                          List<dynamic> to = (paymentData["to"] as List);
                          Map<String, dynamic> fundtome = to.firstWhere(
                              (element) => element["user"].id == user.uid);
                          if (fundtome.isNotEmpty &&
                              fundtome["status"] == "open") {
                            openRefundsPerUser[
                                    (payment["createdBy"] as DocumentReference)
                                        .id]!
                                .add({
                              "title": paymentData["title"],
                              "request": payment,
                              "amount": fundtome["amount"],
                            });
                            sumsPerUser[(payment["createdBy"]
                                    as DocumentReference)
                                .id] = sumsPerUser[
                                    (payment["createdBy"] as DocumentReference)
                                        .id]! +
                                fundtome["amount"];
                          }
                        }
                      }

                      List<Widget> peopleYouOwe = [];
                      for (String key in openRefundsPerUser.keys) {
                        if (key == user.uid) {
                          continue;
                        }
                        if (openRefundsPerUser[key]!.isEmpty) {
                          continue;
                        }
                        peopleYouOwe.add(Padding(
                            padding: const EdgeInsets.only(bottom: 0, right: 5),
                            child: ExpandableContainer(
                              currentUser: members.data!
                                  .firstWhere((element) => element.id == key),
                              openRefunds: openRefundsPerUser[key]!,
                              sum: sumsPerUser[key]!,
                            )));
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: CustomScrollView(
                          slivers: [
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ExpansionTile(
                                    initiallyExpanded: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    title: Text("You owe "),
                                    children: peopleYouOwe,
                                  ),
                                );
                              }, childCount: peopleYouOwe.length),
                            ),
                          ],
                        ),
                      );
                    });
              }),
        ],
      ),
    );
  }
}
