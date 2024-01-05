import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChangeTrip extends StatefulWidget {
  const ChangeTrip({super.key});
  @override
  State<ChangeTrip> createState() => _ChangeTrip();
}

class _ChangeTrip extends State<ChangeTrip> {
  final db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!.uid;
  var userTrip = null;

  Future<List> getTrips() async {
    var tripRef = db.collection("trips");
    var trips = [];
    await tripRef
        .where("members", arrayContains: user)
        .get()
        .then((QuerySnapshot doc) {
      trips = doc.docs;
    });
    await db.collection("users").doc(user).get().then((DocumentSnapshot doc) {
      userTrip = (doc.data() as Map<String, dynamic>)["selectedtrip"];
    });
    return trips;
  }

  bool isAdmin(Map<String, dynamic> trip) {
    return trip["createdBy"] == user;
  }

  Widget createTripName(Map<String, dynamic> trip) {
    if (isAdmin(trip)) {
      return Row(children: [
        const Icon(FontAwesomeIcons.crown, size: 15, color: Colors.white),
        SizedBox(width: 10),
        Text(trip["city"] as String, style: Styles.mainDasboardinitializerTitle)
      ]);
    } else {
      return Row(
        children: [
          SizedBox(width: 30),
          Text(trip["city"] as String,
              style: Styles.mainDasboardinitializerTitle)
        ],
      );
    }
  }

  Future<List> getTripUser(List<dynamic> userids) async {
    var userRef = db.collection("users");
    var users = [];
    await userRef
        .where("uid", whereIn: userids)
        .get()
        .then((QuerySnapshot doc) {
      users = doc.docs;
    });
    return users;
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
                  enabled: isAdmin(trip) && user != con.id,
                  endActionPane: ActionPane(
                      extentRatio: 0.7,
                      motion: ScrollMotion(),
                      children: [
                        SlidableAction(
                            onPressed: (context) {
                              var members = trip["members"] as List;
                              members.remove(con.id);
                              db
                                  .collection("trips")
                                  .doc(tripid)
                                  .update({"members": members});
                              setState(() {});
                            },
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.red,
                            icon: Icons.delete,
                            label: "Remove"),
                        SlidableAction(
                            onPressed: (context) {
                              db
                                  .collection("trips")
                                  .doc(tripid)
                                  .update({"createdBy": con.id});
                              Navigator.pop(context);
                              setState(() {});
                            },
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.black,
                            icon: FontAwesomeIcons.crown,
                            label: "Give Admin")
                      ]),
                  child: Container(
                      height: 60,
                      child: Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          key: Key(con.id.hashCode.toString()),
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
            return Text("");
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
                padding: EdgeInsets.only(right: 15, bottom: 10),
                onPressed: () {
                  context.push('/selecttrip');
                },
                icon: const Icon(Icons.add,
                    size: 40, color: const Color(0xE51E1E1E)))
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
                                      members.remove(user);
                                      if (con["createdBy"] == user) {
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
                                    context.pushNamed("sharetrip", pathParameters: {"tripId": con.id, "afterCreate": "f"});
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
                                      .doc(user)
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
                                          ? BorderSide(
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
            return Text("");
          }),
    );
  }
}
