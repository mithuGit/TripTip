import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

class ChangeTrip extends StatefulWidget {
  const ChangeTrip({super.key});
  @override
  State<ChangeTrip> createState() => _ChangeTrip();
}

class _ChangeTrip extends State<ChangeTrip> {
  final db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!.uid;
  List trips = [];
  List items = [];

  Future<List> getList() async {
    var docRef = db.collection("users").doc(user);

    var tripRef = db.collection("trips");

    await docRef.get().then((DocumentSnapshot doc) {
      items = (doc.data() as Map)["trips"] as List;
    });
    for (var i = 0; i < items.length; i++) {
      await tripRef.doc(items[i]).get().then((DocumentSnapshot doc) {
        var fr = doc.data() as Map;
        fr["name"] = items[i];
        trips.add(fr);
      });
    }
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
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: FutureBuilder(
          future: getList(),
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final data = snapshot.data;
              return ListView.builder(
                  itemCount: data!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {},
                      key: Key(data[index]["city"].hashCode.toString()),
                      child: MyButton(
                          text: data[index]["city"],
                          onTap: () {
                            db
                                .collection("users")
                                .doc(user)
                                .update({"selectedtrip": data[index]["name"]});
                            context.goNamed('home');
                          },
                          colors: const Color.fromARGB(190, 0, 0, 0),
                          margin: const EdgeInsets.only(
                              top: 10, left: 20, right: 20, bottom: 0)),
                    );
                  });
            }
            return Text("");
          }),
    );
  }
}
