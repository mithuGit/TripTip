import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/datepicker.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
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
  late String destination;
  late String selectedStartDate;
  late String selectedEndDate;

  void connectPhotosAlbum() async {
    setState(() {
      //  name = "Hallo";
    });
  }

  Future<void> create_trip() async {
    try {
      final members = [];
      if (destination == '') throw Exception("Destination is empty");
      if (selectedStartDate == '') throw Exception("Destination is empty");
      if (selectedEndDate == '') throw Exception("Destination is empty");
      members.add(_auth.currentUser?.uid);
      print("Create Trip: $destination $selectedStartDate $selectedEndDate");
      await trips.add({
        'city': destination,
        'country': destination,
        'starttime': selectedStartDate,
        'endtime': selectedEndDate,
        'createdBy': _auth.currentUser?.uid,
        'members': members
      });
    } catch (e) {
      if (context.mounted)
        ErrorSnackbar.showErrorSnackbar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get Screen Size
    return Scaffold(
        backgroundColor: const Color(0xFFCBEFFF),
        resizeToAvoidBottomInset: true,
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
                        Padding(
                          padding: const EdgeInsets.only(bottom: 25),
                          child: AsyncAutocomplete(
                            onDestinationPick: (String formattedDate) {
                              setState(() {
                                destination = formattedDate;
                              });
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 148,
                          height: 18,
                          child: Text(
                            'Start Date',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.5),
                        CupertinoDatePickerButton(
                          margin: const EdgeInsets.only(bottom: 25),
                          onDateSelected: (String formattedDate) {
                            setState(() {
                              selectedStartDate = formattedDate;
                            });
                          },
                        ),
                        const SizedBox(
                          width: 148,
                          height: 18,
                          child: Text(
                            'End Date',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.5),
                        CupertinoDatePickerButton(
                          margin: const EdgeInsets.only(bottom: 25),
                          onDateSelected: (String formattedDate) {
                            setState(() {
                              selectedEndDate = formattedDate;
                            });
                          },
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
