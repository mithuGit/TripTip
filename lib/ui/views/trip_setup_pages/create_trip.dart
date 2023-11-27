import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/inputfield_search_lookahead.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/usernamebagageCreateTrip.dart';
import '../../styles/Styles.dart';
import '../../widgets/container.dart';
import '../../widgets/inputfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTrip extends StatefulWidget {
  const CreateTrip({super.key});

  @override
  State<CreateTrip> createState() => _TripCreateState();
}

class User {
  String prename;
  String lastname;
  Image profileImage;
  User(this.prename, this.lastname, this.profileImage);
}

class _TripCreateState extends State<CreateTrip> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference trips = FirebaseFirestore.instance.collection('trips');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final destinationText = TextEditingController();
  final starttime = TextEditingController();
  final endtime = TextEditingController();

  void connectPhotosAlbum() async {
    setState(() {
      //  name = "Hallo";
    });
  }

  void create_trip() async {
    try {
      final String dest = destinationText.value.text;
      final String start = starttime.value.text;
      final String end = endtime.value.text;
      print("Create Ttrip: " + dest + " " + start + " " + end);
      await trips.add({
        'destination': dest, 
        'starttime': start,
        'endtime': end,
        'createdBy' : _auth.currentUser?.uid
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.red,
            title: Center(
              child: Text(
                e.toString(),
                style: Styles.textfieldHintStyle,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get Screen Size
    return Scaffold(
        backgroundColor: const Color(0xFFCBEFFF),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/BackgroundCity.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 80, left: 14, right: 14, bottom: 45),
                    child: CustomContainer(
                      title: "Start your next Adventure:",
                      children: [
                        AsyncAutocomplete(),
                        InputField(
                          controller: starttime,
                          hintText: 'Start Time',
                          obscureText: false,
                          margin: const EdgeInsets.only(bottom: 25),
                        ),
                        InputField(
                          controller: endtime,
                          hintText: 'End Time',
                          obscureText: false,
                          margin: const EdgeInsets.only(bottom: 25),
                        ),
                        
                        MyButton(
                            onTap: connectPhotosAlbum,
                            imagePath: 'assets/googlephotos.png',
                            text: 'Create Photos Album'),
                        MyButton(
                            margin: const EdgeInsets.only(top: 30),
                            onTap: create_trip,
                            text: 'Create Trip')
                      ],
                    )),
              ),
            ),
            const UsernameBagageCreateTrip()
          ]),
        ));
  }
}