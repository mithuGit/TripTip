import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/bottom_sheet.dart';
import 'package:internet_praktikum/calendar.dart';
import 'package:internet_praktikum/ui/views/navigation/app_navigation.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/topbar.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      GoRouter.of(context).go('/loginorregister');
    }
  }

  void deleteUser() async {
    await FirebaseAuth.instance.currentUser!.delete();
    if (context.mounted) {
      GoRouter.of(context).go('/loginorregister');
    }
  }

  late String prename; // Variable für den Vornamen

  @override
  void initState() {
    super.initState();
    // Bei der Initialisierung den Vornamen aus der Datenbank laden
    //loadPrename();
  }

  void loadPrename() async {
    try {
      // Benutzer-ID (uid) aus dem aktuellen Benutzer abrufen
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      // Den Vornamen aus der Firestore-Datenbank laden
      final String prenameResult = await getPrename(uid);

      // Wenn die Komponente noch im Widget-Baum ist, das State aktualisieren
      if (context.mounted) {
        setState(() {
          prename = prenameResult;
        });
      }
    } catch (error) {
      print("Fehler beim Laden des Vornamens: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
          isDash: true,
          icon: Icons.add,
          onTapForIconWidget: () {
            CustomBottomSheet.show(context);
          }),
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/mainpage_pic/dashboard.png'), // assets/BackgroundCity.png
                  fit: BoxFit.fill,
                ),
              ),
              child: Center(
                  child: Center(
                      child: FutureBuilder<DocumentReference>(
                          future: getCurrentDay(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(); // Show loading indicator while waiting for the Future
                            } else if (snapshot.hasError) {
                              return Text('EEEEE: ${snapshot.error}');
                            } else {
                              return ScrollViewWidget(day: snapshot.data!);
                            }
                })))),
        ],
      ),
    );
  }
}

Future<String> getPrename(String uid) async {
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final String prename = documentSnapshot.data()!['prename'].toString();
  print(prename);
  return prename;
}
