// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/core/services/Interests.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/profileWidgets/imageContainer.dart';
import 'package:internet_praktikum/ui/widgets/usernamebagageCreateTrip.dart';

// This is the page where the user can set his interests
class SetInterestsPage extends StatefulWidget {
  // This bool is needed to redirect the user to the right page
  final bool isCreate;
  const SetInterestsPage({super.key, required this.isCreate});
  @override
  SetInterestsPageState createState() => SetInterestsPageState();
}

class SetInterestsPageState extends State<SetInterestsPage> {
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    List<String> selectedInterests = [];

    Future<void> updateInterests() async {
      if (selectedInterests.isEmpty) {
        ErrorSnackbar.showErrorSnackbar(
            context, "Please select at least 1 interest");
        return;
      }
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .update({'interests': selectedInterests});
      // here you go back    
      if (context.mounted) {
        widget.isCreate == true
            ? context.push('/selecttrip/false')
            : context.go('/profile');
      }
    }
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
                                "Select your interests by pressing a picture",
                                style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              // here we build the gridview with the interests
                              FutureBuilder<DocumentSnapshot>(
                                  future: firestore
                                      .collection('users')
                                      .doc(auth.currentUser!.uid)
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return const Center(
                                        child: Text("Error Fetiching Userdata"),
                                      );
                                    }
                                    if ((snapshot.data!.data() as Map<String,
                                            dynamic>)["interests"] !=
                                        null) {
                                      selectedInterests = (snapshot.data!.data()
                                                  as Map<String, dynamic>)[
                                              "interests"]
                                          .map<String>((e) => e.toString())
                                          .toList();
                                    }

                                    List<String> selectedCategories = [];
                                    List<String> uninterestedCategories = [];
                                    selectedCategories =
                                        Interests.evaluateCategories(
                                            selectedInterests);
                                    //Here the Gridview is beeing built      
                                    return GridView.count(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                      shrinkWrap: true,
                                      children: Interests.available.keys
                                          .map((interest) => ImageContainerToSetInterest(
                                                image: interest,
                                                isSelected: selectedCategories
                                                    .contains(interest),
                                                isNotinterested:
                                                    uninterestedCategories
                                                        .contains(interest),
                                                setInterested: (val) {
                                                  selectedInterests.addAll(val);
                                                },
                                                unsetInterested: (val) {
                                                  for (final el in val) {
                                                    selectedInterests
                                                        .remove(el);
                                                  }
                                                },
                                              ))
                                          .toList(),
                                    );
                                  }),
                              const SizedBox(height: 25),
                              MyButton(onTap: updateInterests, text: "Finish"),
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
            ),
            // This is the widget that contains the username and a ProfilePicture
            UsernameBagageCreateTrip(
              firestore: firestore,
              auth: auth,
            )
          ]),
        ));
  }
}
