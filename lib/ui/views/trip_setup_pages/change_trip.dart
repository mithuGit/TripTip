import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_praktikum/ui/widgets/modalButton.dart';

class ChangeTrip extends StatefulWidget {
  const ChangeTrip({super.key});
  @override
  State<ChangeTrip> createState() => _ChangeTrip();
}

class _ChangeTrip extends State<ChangeTrip> {
  final db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;
  var userTrip;

  Future<List> getTrips() async {
    var tripRef = db.collection("trips");
    var trips = [];
    await tripRef
        .where("members",
            arrayContains: FirebaseFirestore.instance.doc("/users/${user.uid}"))
        .get()
        .then((QuerySnapshot doc) {
      trips = doc.docs;
    });
    await db
        .collection("users")
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot doc) {
      userTrip = (doc.data() as Map<String, dynamic>)["selectedtrip"];
    });
    return trips;
  }

  bool isAdmin(Map<String, dynamic> trip) {
    return trip["createdBy"] ==
        FirebaseFirestore.instance.doc("/users/${user.uid}");
  }

  Widget createTripName(Map<String, dynamic> trip) {
    if (isAdmin(trip)) {
      return Row(children: [
        const Icon(FontAwesomeIcons.crown, size: 15, color: Colors.white),
        const SizedBox(width: 10),
        Text(trip["city"] as String, style: Styles.mainDasboardinitializerTitle)
      ]);
    } else {
      return Row(
        children: [
          const SizedBox(width: 30),
          Text(trip["city"] as String,
              style: Styles.mainDasboardinitializerTitle)
        ],
      );
    }
  }

  Future<List> getTripUser(List<dynamic> userref) async {
    var users = [];
    await Future.forEach(
        userref,
        (x) => FirebaseFirestore.instance.doc(x.path).get().then((y) {
              users.add(y.data());
            }));
    return users;
  }

  Future<void> deleteAllWidgets(
      dynamic user, String trip) async {
    var ref = db.collection("trips").doc(trip).collection("days");
    await ref.get().then(
      (QuerySnapshot col) {
        var docs = col.docs;
        for (var i = 0; i < docs.length; i++) {
          Map<String, dynamic> active =
              (docs[i].data() as Map<String, dynamic>)["active"];
          var temp = active;
          if (active.isNotEmpty) {
            for (var entry in active.entries) {
              if (entry.key != "diary") {
                if (entry.value["createdBy"] == user) {
                  temp.remove(entry.key);
                  ref.doc(docs[i].id).update({"active": temp});
                }
              }
              if (active.isEmpty) {
                break;
              }
            }
          }
        }
      },
    );
  }

  FutureBuilder createMemberView(Map<String, dynamic> trip, String tripid) {
    return FutureBuilder(
        future: getTripUser(trip["members"]),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final data = snapshot.data;
            return Column(
                children: data!.map<Widget>((con) {
              return Slidable(
                  key: Key(con.hashCode.toString()),
                  enabled: isAdmin(trip),
                  endActionPane: ActionPane(
                      extentRatio: 0.3,
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                            onPressed: (contextt) {
                              CustomBottomSheet.show(contextt,
                                  title: "${con['prename']} ${con['lastname']}",
                                  content: [
                                    Container(
                                        child: GridView.count(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 10,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            children: [
                                          ModalButton(
                                              icon: Icons.remove_circle_outline,
                                              onTap: () {
                                                var members =
                                                    trip["members"] as List;
                                                members.remove(FirebaseFirestore
                                                    .instance
                                                    .doc(
                                                        "/users/${con['uid']}"));
                                                db
                                                    .collection("trips")
                                                    .doc(tripid)
                                                    .update(
                                                        {"members": members});

                                                setState(() {});
                                                context.goNamed("home");
                                              },
                                              text: "Kick Member"),
                                          ModalButton(
                                              icon: Icons.delete,
                                              onTap: () {
                                                deleteAllWidgets(
                                                    FirebaseFirestore.instance.doc(
                                                        "/users/${con['uid']}"),
                                                    tripid);
                                                context.goNamed("home");
                                              },
                                              text: "Delete Widgets"),
                                          ModalButton(
                                              icon: FontAwesomeIcons.crown,
                                              onTap: () {
                                                db
                                                    .collection("trips")
                                                    .doc(tripid)
                                                    .update({
                                                  "createdBy": FirebaseFirestore
                                                      .instance
                                                      .doc(
                                                          "/users/${con['uid']}")
                                                });
                                                setState(() {});
                                                context.goNamed("home");
                                              },
                                              text: "Give Admin"),
                                        ])),
                                  ]);
                            },
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.grey,
                            icon: Icons.settings,
                            label: "Settings"),
                      ]),
                  child: Container(
                      height: 60,
                      child: Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(34.4)),
                          color: const Color(0xE51E1E1E),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 30),
                                Text(con["prename"] + " " + con["lastname"],
                                    style: Styles.mainDasboardinitializerTitle),
                              ]))));
            }).toList());
          } else {
            return const Text("");
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            onPressed: () {
              context.goNamed('home');
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: const Text("Change Trip"),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
          actions: [
            IconButton(
                padding: const EdgeInsets.only(right: 15, bottom: 10),
                onPressed: () {
                  context.pushNamed('selecttrip',
                      pathParameters: {"noTrip": "false"});
                },
                icon: const Icon(Icons.add, size: 40, color: Color(0xE51E1E1E)))
          ]),
      body: FutureBuilder(
          future: getTrips(),
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final data = snapshot.data;
              return ListView(
                  children: data!
                      .map((con) {
                        return Slidable(
                            key: Key(con.hashCode.toString()),
                            endActionPane: ActionPane(
                              extentRatio: 0.5,
                              motion: const ScrollMotion(),
                              children: [
                                if (userTrip != con.id) ...[
                                  SlidableAction(
                                    onPressed: (sdf) {
                                      var members = con["members"] as List;
                                      members.remove(FirebaseFirestore.instance
                                          .doc("/users/" + user.uid));
                                      if (con["createdBy"] ==
                                          FirebaseFirestore.instance
                                              .doc("/users/${user.uid}")) {
                                        db
                                            .collection("trips")
                                            .doc(con.id)
                                            .update({
                                          "members": members,
                                          "createdBy": members[0]
                                        });
                                      } else {
                                        db
                                            .collection("trips")
                                            .doc(con.id)
                                            .update({"members": members});
                                      }
                                      setState(() {});
                                    },
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.red,
                                    icon: Icons.delete,
                                  )
                                ],
                                SlidableAction(
                                  onPressed: (sdf) {
                                    CustomBottomSheet.show(context,
                                        content: [
                                          createMemberView(con.data(), con.id)
                                        ],
                                        title: "Members");
                                  },
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.black,
                                  icon: Icons.groups_2,
                                ),
                                SlidableAction(
                                  onPressed: (sdf) {
                                    context.pushNamed("sharetrip",
                                        pathParameters: {
                                          "tripId": con.id,
                                          "afterCreate": "f"
                                        });
                                  },
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.blue,
                                  icon: Icons.share,
                                )
                              ],
                            ),
                            child: GestureDetector(
                                onTap: () {
                                  db
                                      .collection("users")
                                      .doc(user.uid)
                                      .update({"selectedtrip": con.id});
                                  context.goNamed('home');
                                },
                                child: Card(
                                  borderOnForeground: true,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  key: Key(con.id.hashCode.toString()),
                                  shape: RoundedRectangleBorder(
                                      side: userTrip == con.id
                                          ? const BorderSide(
                                              color: Colors.blue, width: 2)
                                          : BorderSide.none,
                                      borderRadius:
                                          BorderRadius.circular(34.4)),
                                  color: const Color(0xE51E1E1E),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          padding:
                                              const EdgeInsets.only(left: 20),
                                          child: createTripName(con.data())),
                                      Container(
                                          width: 150,
                                          height: 80,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      bottomRight:
                                                          Radius.circular(34.4),
                                                      topRight: Radius.circular(
                                                          34.4)),
                                              color: Colors.white,
                                              image: DecorationImage(
                                                  fit: BoxFit.fitWidth,
                                                  image: Image.network(
                                                          'https://places.googleapis.com/v1/' +
                                                              con["placedetails"]
                                                                      ["photos"]
                                                                  [0]["name"] +
                                                              "/media?maxHeightPx=500&maxWidthPx=500&key=AIzaSyBUh4YsufaUkM8XQqdO8TSXKpBf_3dJOmA")
                                                      .image)))
                                    ],
                                  ),
                                )));
                      })
                      .toList()
                      .cast());
            }
            return const Text("");
          }),
    );
  }
}
