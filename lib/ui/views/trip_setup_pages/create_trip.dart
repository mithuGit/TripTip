import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/core/services/placeApiProvider.dart';
import 'package:internet_praktikum/ui/widgets/datepicker.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield_search_lookahead.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/usernamebagageCreateTrip.dart';
import 'package:intl/intl.dart';
import '../../widgets/container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTrip extends StatefulWidget {
  // beacuse of Testing we need to pass the firestore and auth object
  // but this is not required in the final app
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const CreateTrip({super.key, required this.firestore, required this.auth});
  @override
  State<CreateTrip> createState() => _TripCreateState();
}

// This class is used to store the data of the user
// thogeter with the profile image
class User {
  String prename;
  String lastname;
  Image profileImage;
  User(this.prename, this.lastname, this.profileImage);
}

class _TripCreateState extends State<CreateTrip> {
  CollectionReference trips = FirebaseFirestore.instance.collection('trips');
  final destinationText = TextEditingController();
  final starttime = TextEditingController();
  final endtime = TextEditingController();
  PlaceDetails? destination;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  // Simple function to create a trip
  Future<void> create_trip() async {
    try {
      final members = [];
      if (destination == null) throw Exception("Destination is empty");
      if (selectedStartDate == null) {
        throw Exception("You need to select a start date!");
      }
      if (selectedEndDate == null) {
        throw Exception("You need to select a end date!");
      }
      if (selectedEndDate!.millisecondsSinceEpoch <
          selectedStartDate!.millisecondsSinceEpoch) {
        throw Exception("End date must be after start date!");
      }

      final duration = selectedEndDate!.difference(selectedStartDate!);
      if (duration.inDays > 100) {
        throw Exception("Trip can't be longer than 100 days!");
      }
      // Here no cloud Function is required, beacuse the user is already logged in and is owner of the trip
      var self = FirebaseFirestore.instance
          .doc("/users/${widget.auth.currentUser!.uid}");
      members.add(self);

      // By now the Trip has no dates, they are created whem the user goes to the dashboard
      DocumentReference trip = await trips.add({
        'city': destination?.cityName,
        'placedetails': destination?.placeDetails,
        'startdate': selectedStartDate,
        'enddate': selectedEndDate,
        'createdBy': self,
        'members': members
      });
      FirebaseFirestore.instance
          .collection("users")
          .doc(widget.auth.currentUser?.uid)
          .update({"selectedtrip": trip.id});

      if (context.mounted) {
        context.goNamed("sharetrip",
            pathParameters: {"tripId": trip.id, "afterCreate": "true"});
      }
    } catch (e) {
      if (context.mounted) {
        ErrorSnackbar.showErrorSnackbar(context, e.toString());
      }
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
                        top: 80, left: 14, right: 14, bottom: 100),
                    child: CustomContainer(
                      title: "Create Trip",
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 25),
                          child: AsyncAutocomplete(
                            onDestinationPick: (PlaceDetails details) {
                              setState(() {
                                destination = details;
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
                          showFuture: true,
                          boundingDate: DateTime.now(),
                          presetDate: selectedStartDate != null
                              ? DateFormat('dd/MM/yyyy')
                                  .format(selectedStartDate ?? DateTime.now())
                              : 'select start Date',
                          onDateSelected: (DateStringTupel formattedDate) {
                            setState(() {
                              selectedStartDate = formattedDate.date;
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
                          showFuture: true,
                           boundingDate: DateTime.now(),
                          presetDate: selectedEndDate != null
                              ? DateFormat('dd/MM/yyyy')
                                  .format(selectedEndDate ?? DateTime.now())
                              : 'select end Date',
                          onDateSelected: (DateStringTupel formattedDate) {
                            setState(() {
                              selectedEndDate = formattedDate.date;
                            });
                          },
                        ),
                        /*  MyButton(
                            onTap: connectPhotosAlbum,
                            imagePath: 'assets/googlephotos.png',
                            text: 'Create Photos Album'), */

                        MyButton(
                            margin: const EdgeInsets.only(top: 20),
                            onTap: create_trip,
                            text: 'Create Trip'),
                        MyButton(
                            margin: const EdgeInsets.only(top: 10),
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              }
                            },
                            text: 'Cancel')
                      ],
                    )),
              ),
            ),
            UsernameBagageCreateTrip(
              firestore: widget.firestore,
              auth: widget.auth,
            )
          ]),
        ));
  }
}
