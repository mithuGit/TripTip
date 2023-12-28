import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

class ChangeTrip extends StatefulWidget {
  const ChangeTrip({super.key});
  @override
  State<ChangeTrip> createState() => _ChangeTrip();
}

class _ChangeTrip extends State<ChangeTrip> {
  final db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!.uid;

  Future<List> getList() async {
    var tripRef = db.collection("trips");
    var trips = [];
    await tripRef
        .where("members", arrayContains: user)
        .get()
        .then((QuerySnapshot doc) {
      trips = doc.docs;
    });
    return trips;
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
              padding: EdgeInsets.only(right:15, bottom:10),
              onPressed: () {
              context.push('/selecttrip');
            },
            icon: const Icon(Icons.add, size: 40, color: const Color(0xE51E1E1E)))
          ]),
      body: FutureBuilder(
          future: getList(),
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final data = snapshot.data;
              return ListView(
                  children: data!
                      .map((con) {
                        return Slidable(
                            key: Key(con.hashCode.toString()),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (sdf) {
                                    var members = con["members"] as List;
                                    members.remove(user);
                                    db
                                        .collection("trips")
                                        .doc(con.id)
                                        .update({"members": members});
                                    setState(() {});
                                  },
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.red,
                                  icon: Icons.delete,
                                  label: 'Delete',
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
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  key: Key(con.id.hashCode.toString()),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(34.4)),
                                  //imagePath:'https:' + con["placedetails"]["photos"][3]["authorAttributions"][0]["photoUri"],
                                  color: const Color(0xE51E1E1E),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                          padding: EdgeInsets.only(left: 30),
                                          child: Text(con["city"],
                                              style: Styles
                                                  .mainDasboardinitializerTitle)),
                                      Card(
                                          shape: CircleBorder(),
                                          clipBehavior: Clip.antiAlias,
                                          child: Image.network(
                                              'https:' +
                                                  con["placedetails"]["photos"]
                                                              [0]
                                                          ["authorAttributions"]
                                                      [0]["photoUri"],
                                              width: 80,
                                              height: 80))
                                    ],
                                  ),
                                )));
                      })
                      .toList()
                      .cast());

              /**
                    return GestureDetector(
                      onTap: () {},
                      key: Key(data[index]["city"].hashCode.toString()),
                      child: MyButton(
                          text: data[index]["city"],
                          onTap: () {
                            db
                                .collection("users")
                                .doc(user)
                                .update({"selectedtrip": data[index].id});
                            context.goNamed('home');
                          },
                          colors: const Color.fromARGB(190, 0, 0, 0),
                          margin: const EdgeInsets.only(
                              top: 10, left: 20, right: 20, bottom: 0)),
                    );
                    */
            }
            return Text("");
          }),
    );
  }
}
