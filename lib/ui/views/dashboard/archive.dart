import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/core/services/dashboardData.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/mainDasboardinitializer.dart';
import 'package:intl/intl.dart';

class Archive extends StatefulWidget {
  Archive({super.key});

  @override
  State<Archive> createState() => _Archive();
}

class _Archive extends State<Archive> {
  final userCollection = FirebaseFirestore.instance.collection('users');
  static final user = FirebaseAuth.instance.currentUser!;
  var userdata;
  CollectionReference currentTrip =
      FirebaseFirestore.instance.collection('trips');

  Future<List> getArchives() async {
    userdata = await DashBoardData.getUserData();
    final userDoc = await userCollection.doc(user.uid).get();
    if (userDoc.data()?['selectedtrip'] == null) {
      throw Exception('No trip selected');
    }

    currentTrip = FirebaseFirestore.instance
        .collection('trips')
        .doc(userDoc.data()?['selectedtrip'])
        .collection("days");

    List archiveList = [];

    await currentTrip.where("archive", isNotEqualTo: {}).get().then(
          (doc) {
            doc.docs.forEach((element) {
              var temp = {
                "day": element.id,
                "daytime": element["starttime"],
                "archive": element["archive"]
              };
              archiveList.add(temp);
            });
          },
        );

    archiveList.sort((a, b) => a["daytime"].compareTo(b["daytime"]));

    return archiveList;
  }

  Future returnNode(Map arch, String doc, String k) async {
    currentTrip.doc(doc).set({
      "active": {k: arch[k]},
    }, SetOptions(merge: true));
    arch.remove(k);
    currentTrip.doc(doc).update({"archive": arch});
  }

  List<Widget> getDayWidgets(List data) {
    List<Widget> returnList = [];

    data.forEach((con) {
      returnList.add(Row(children: [
        Expanded(
            child: Container(
                padding: const EdgeInsets.only(left: 30, right: 10),
                child: const Divider(
                  thickness: 3,
                  color: Color.fromARGB(0, 255, 255, 255),
                ))),
        Text(
            DateFormat.yMMMd()
                .format(DateTime.fromMillisecondsSinceEpoch(
                    con["daytime"].millisecondsSinceEpoch + 3600000))
                .toString(),
            style: Styles.archiveDiv),
        Expanded(
            child: Container(
                padding: const EdgeInsets.only(left: 10, right: 30),
                child: const Divider(
                  thickness: 3,
                  color: Color.fromARGB(0, 255, 255, 255),
                )))
      ]));
      con["archive"].forEach((key, item) {
        returnList.add(Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Slidable(
                endActionPane: ActionPane(
                    extentRatio: 0.3,
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                          onPressed: (context) {
                            returnNode(con["archive"], con["day"], key);
                            context.goNamed("home");
                          },
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.green,
                          icon: Icons.arrow_back,
                          label: "Add back"),
                    ]),
                child: MainDasboardinitializer(
                    title: item["title"], data: item, userdata: userdata))));
      });
    });
    return returnList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text("Archive"),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.black,
            onPressed: () {
              context.go('/');
            },
          ),
        ),
        body: FutureBuilder(
            future: getArchives(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final data = snapshot.data;
                return ListView(children: getDayWidgets(data!));
              } else {
                return const Text("");
              }
            }));
  }
}
