import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/profileWidgets/imageContainer.dart';
import 'package:internet_praktikum/ui/widgets/usernamebagageCreateTrip.dart';

class SetInterestsPage extends StatefulWidget {
  final bool isCreate;
  const SetInterestsPage({super.key, required this.isCreate});
  @override
  _SetInterestsPageState createState() => _SetInterestsPageState();
}

class _SetInterestsPageState extends State<SetInterestsPage> {
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    List<String> interests = [
      'assets/interests_pic/transport.png',
      'assets/interests_pic/culture.png',
      'assets/interests_pic/shopping.png',
      'assets/interests_pic/food.png',
      'assets/interests_pic/lodging.png',
      'assets/interests_pic/sports.png',
      'assets/interests_pic/health.png',
      'assets/interests_pic/car.png',
      'assets/interests_pic/education.png',
      'assets/interests_pic/entertainment.png',
      'assets/interests_pic/services.png',
      'assets/interests_pic/religion.png',
    ];

    List<String> selectedInterests = [];
    List<String> uninterestedInterests = [];

    Future<void> updateInterests() async {
      await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'interests': selectedInterests,
        'uninterested': uninterestedInterests
      });
      if (context.mounted) {
        widget.isCreate == true
            ? context.go('/createtrip')
            : context.go('/profile');
      }
    }

    //TODO: Was soll passieren wenn nix angedrückt wird ?
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
                        top: 80, left: 14, right: 14, bottom: 100),
                    child: CustomContainer(
                      title: "Set your Interests",
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              const Text(
                                textAlign: TextAlign.center,
                                "Select your interests by pressing a picture and longpress to make it uninterested",
                                style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              GridView.count(
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                shrinkWrap: true,
                                children: interests
                                    .map((interest) => ImageContainer(
                                          image: interest,
                                          setInterested: (val) {
                                            selectedInterests.addAll(val);
                                          },
                                          unInterestetset: (value) {
                                            uninterestedInterests.addAll(value);
                                          },
                                          unInterestetunset: (val) {
                                            for (final el in val) {
                                              selectedInterests.remove(el);
                                              uninterestedInterests.add(el);
                                            }
                                          },
                                          unsetInterested: (val) {
                                            for (final el in val) {
                                              selectedInterests.remove(el);
                                              uninterestedInterests.add(el);
                                            }
                                          },
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 25),
                              MyButton(onTap: updateInterests, text: "Finish"),
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
            ),
            UsernameBagageCreateTrip(
              firestore: firestore,
              auth: auth,
            )
          ]),
        ));
  }
}
