import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/centerText.dart';
import 'package:internet_praktikum/ui/widgets/headerWidgets/topbar.dart';
import 'package:internet_praktikum/ui/widgets/ticketWidgets/createTicketWidget.dart';
import 'package:internet_praktikum/ui/widgets/ticketWidgets/ticketContainer.dart';

class Ticket extends StatefulWidget {
  const Ticket({super.key});

  @override
  State<Ticket> createState() => _TicketState();
}

class _TicketState extends State<Ticket> {
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  Future<String> getSelectedtrip() async {
    DocumentSnapshot sn =
        await firestore.collection("users").doc(user.uid).get();
    return (sn.data()! as Map<String, dynamic>)["selectedtrip"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: TopBar(
        title: "Tickets",
        icon: Icons.add,
        onTapForIconWidget: () {
          CustomBottomSheet.show(context, title: "Upload a Ticket", content: [
            FutureBuilder(
                future: getSelectedtrip(),
                builder: (context, selectedTrip) {
                  if (selectedTrip.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (selectedTrip.hasError) {
                    return const Center(
                        child: Text("Error while fetching Selectedtrip"));
                  }
                  if (selectedTrip.data == null) {
                    return const CenterText(
                        text: "No Trip selected, please select a trip first");
                  }
                  DocumentReference trip = firestore
                      .collection("trips")
                      .doc(selectedTrip.data as String);
                  return CreateTicketsWidget(selectedTrip: trip);
                })
          ]);
        },
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background_city_persona.png'), // assets/BackgroundCity.png
                fit: BoxFit.cover,
              ),
            ),
            child: FutureBuilder(
              future: getSelectedtrip(),
              builder: (context, currentTrip) {
                if (currentTrip.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (currentTrip.hasError) {
                  return const CenterText(
                      text: "Error while fetching Selectedtrip");
                }
                if (currentTrip.hasData && currentTrip.data!.isEmpty) {
                  return const CenterText(
                      text: "No Trip selected, please select a trip first");
                }

                //Todo: change selected Trio to DocumentReference
                return StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection("trips")
                        .doc(currentTrip.data as String)
                        .collection("tickets")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        debugPrint(snapshot.error.toString());
                        return const CenterText(
                            text: "Error while fetching Tickets");
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return const CenterText(
                            text:
                                "No Tickets found, press the + button to add one");
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ListView(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            return Slidable(
                              key: Key(document.id),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (sdf) async {
                                      Map<String, dynamic> data = (document.data()
                                          as Map<String, dynamic>);
                                      if (data["url"] != null) {
                                        Reference doc = FirebaseStorage.instance
                                            .ref(data["url"]);
                                        await doc.delete();
                                      }
                                      document.reference.delete();
                                    },
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.red,
                                    icon: Icons.delete,
                                    label: 'Delete Ticket',
                                  )
                                ],
                              ),
                              child: TicketContainer(
                                ticket: document,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}
