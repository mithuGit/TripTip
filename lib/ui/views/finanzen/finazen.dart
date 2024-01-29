// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:internet_praktikum/core/services/paymentsHandeler.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/centerText.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/finanzenWidgets/ExpansionTile.dart';
import 'package:internet_praktikum/ui/widgets/finanzenWidgets/wallet.dart';
import 'package:internet_praktikum/ui/widgets/headerWidgets/topbar.dart';
import 'package:internet_praktikum/ui/widgets/finanzenWidgets/createWidgetPreviewForDebts.dart';
import '../../widgets/finanzenWidgets/extendablecontainer.dart';

/*
This class is for seeing all the payments and requests of the user.
It is also possible to create new requests, via the plus icon in the topbar.

*/
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
      groupmembersSnaps.add(await groupmembers[i].get());
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
          CustomBottomSheet.show(context, title: "Add Request:", content: [
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
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background_beach.png'),
                    fit: BoxFit.cover, // Maintain width, adjust height
                  ),
                ),
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

                      // for every payment check if there is a refund for you
                      for (DocumentSnapshot payment in payments) {
                        Map<String, dynamic> paymentData =
                            payment.data()! as Map<String, dynamic>;
                        if (paymentData["to"] != null) {
                          List<dynamic> to = (paymentData["to"] as List);
                          if (to.isEmpty) {
                            continue;
                          }
                          if (to
                              .where(
                                  (element) => element["user"].id == user.uid)
                              .isEmpty) {
                            continue;
                          }
                          Map<String, dynamic> fundtome = to.firstWhere(
                              (element) => element["user"].id == user.uid);
                          if (fundtome.isEmpty) {
                            continue;
                          }
                          if (fundtome.isNotEmpty &&
                              fundtome["status"] == "open") {
                            int index = to.indexOf(fundtome);
                            openRefundsPerUser[
                                    (payment["createdBy"] as DocumentReference)
                                        .id]!
                                .add({
                              "title": paymentData["title"],
                              "indexInArray": index,
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
                      // List of all Requests that are open for you
                      List<Widget> peopleYouOwe = [];
                      for (String key in openRefundsPerUser.keys) {
                        if (key == user.uid) {
                          continue;
                        }
                        if (openRefundsPerUser[key]!.isEmpty) {
                          continue;
                        }
                        peopleYouOwe.add(ExpandableContainer(
                          margin: const EdgeInsets.only(bottom: 8),
                          me: currentUser!.reference,
                          currentUser: members.data!
                              .firstWhere((element) => element.id == key),
                          openRefunds: openRefundsPerUser[key]!,
                          sum: sumsPerUser[key]!,
                          trip: selectedtrip!,
                        ));
                      }

                      List<Widget> yourRequests = [];
                      List<QueryDocumentSnapshot> myRequests = snapshot
                          .data!.docs
                          .where((el) => el.get("createdBy").id == user.uid)
                          .toList();

                      // add for every Request a Widget
                      for (QueryDocumentSnapshot request in myRequests) {
                        yourRequests.add(Slidable(
                            key: Key(request.id),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  autoClose: false,
                                  onPressed: (_) async {
                                    await PaymentsHandeler.deleteRequest(
                                            request.reference)
                                        .onError((error, stackTrace) =>
                                            ErrorSnackbar.showErrorSnackbar(
                                                context, error.toString()));
                                  },
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.red,
                                  icon: Icons.delete,
                                  label: 'Delete Request',
                                )
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () {
                                CustomBottomSheet.show(context,
                                    title: "Request:",
                                    content: [
                                      Builder(builder: (context) {
                                        return CreateDebts(
                                          selectedTrip: selectedtrip!,
                                          preview: request,
                                        );
                                      })
                                    ]);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xE51E1E1E),
                                  border: Border.all(
                                      color: Colors.transparent, width: 0),
                                  borderRadius: BorderRadius.circular(34.5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 18.0,
                                      left: 25,
                                      right: 25,
                                      bottom: 15.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          request.get("title"),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text("${request.get("amount")} €",
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            )));
                      }

                      // Build the List
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 65),
                        child: CustomScrollView(
                          slivers: [
                            SliverPadding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 15, right: 15, bottom: 10),
                                sliver: SliverToBoxAdapter(
                                  child: Wallet(
                                    user: currentUser!.reference,
                                  ),
                                )),
                            SliverPadding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 15, right: 15, bottom: 10),
                              sliver: SliverToBoxAdapter(
                                child: ExpansionTileWidget(
                                  title: "Your Requests",
                                  children: yourRequests,
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 15, right: 15, bottom: 10),
                              sliver: SliverToBoxAdapter(
                                child: ExpansionTileWidget(
                                  title: "You Owe",
                                  children: peopleYouOwe,
                                ),
                              ),
                            )
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
