import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/centerText.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/headerWidgets/topbar.dart';
import 'package:internet_praktikum/ui/widgets/listSlidAble.dart';
import 'package:internet_praktikum/ui/widgets/ticketWidgets/createTicketWidget.dart';
import 'package:internet_praktikum/ui/widgets/ticketWidgets/ticketContainer.dart';

/*
  This class is the widget for the ticket page
  It contains a list of all tickets
  The user can add a new ticket by pressing the + button
*/
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

  // This function checks if the member of the trip have already uploaded 100 tickets
  // If so, the user can't upload a new ticket
  Future<void> checkIfTicketsMaxReached() async {
    try {
      String selectedTrip = await getSelectedtrip();
      QuerySnapshot<Map<String, dynamic>> tickets = await firestore
          .collection("trips")
          .doc(selectedTrip)
          .collection("tickets")
          .get();

      int maxTickets = tickets.docs.length;

      if (maxTickets >= 100) {
        if (context.mounted) {
          ErrorSnackbar.showErrorSnackbar(
              context, "You can't upload more than 100 tickets");
          return;
        }
      }
      if (context.mounted) {
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
      }
    } catch (e) {
      if (context.mounted) {
        ErrorSnackbar.showErrorSnackbar(context,
            "Error while checking if to max tickets count has reached");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      /*
        The TopBar is a custom widget
        It contains the title and the + button
        The + button opens a bottom sheet where the user can add a new ticket
      */
      appBar: TopBar(
        title: "Tickets",
        icon: Icons.add,
        onTapForIconWidget: () {
          checkIfTicketsMaxReached();
        },
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background_airport.png'), // assets/BackgroundCity.png
                fit: BoxFit.cover,
              ),
            ),
            // The FutureBuilder fetches the selected trip from the database
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
                // The StreamBuilder fetches all tickets from the selected trip, and updates them in realtime
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
                      // The ListView contains all tickets
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 65, top: 10),
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            return ListSlidAble(
                              key: Key(document.id),
                              margin: const EdgeInsets.only(bottom: 10),
                              onDelete: (_) async {
                                Map<String, dynamic> data =
                                    (document.data() as Map<String, dynamic>);
                                if (data["url"] != null) {
                                  Reference doc =
                                      FirebaseStorage.instance.ref(data["url"]);
                                  await doc.delete();
                                }
                                document.reference.delete();
                              },
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
