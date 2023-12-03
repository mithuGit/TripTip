
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class User {
  String prename;
  String lastname;
  Image profileImage;
  User(this.prename, this.lastname, this.profileImage);
}

class UsernameBagageCreateTrip extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  UsernameBagageCreateTrip({super.key, required this.firestore, required this.auth});

  @override
  State<UsernameBagageCreateTrip> createState() =>
      _UsernameBagageCreateTripState();
}

class _UsernameBagageCreateTripState extends State<UsernameBagageCreateTrip> {
  Future<User> _getNames() async {
    Image pb = Image.asset('assets/Personavatar.png');
    String prename = 'Not';
    String lastname = 'Registered';

    if (widget.auth.currentUser != null) {
      widget.firestore.collection('users').where('uid', isEqualTo: widget.auth.currentUser!.uid).get().then((value) {
        if (value.docs.isNotEmpty) {
          // is needed to load the data from the collection wiche is linked to firebaseAuth uid
          // for every field in the collection we need to check if it is null
          if (value.docs[0].data()['profilepicture'] != null) {
            pb = Image.network(value.docs[0].data()['profileImage']);
          }
          if (value.docs[0].data()['prename'] != null) {
            prename = value.docs[0].data()['prename'];
          }
          if (value.docs[0].data()['lastname'] != null) {
            lastname = value.docs[0].data()['lastname'];
          }
        }
      });

      return User(prename, lastname, pb);
      
    } else {
      return User('Not', 'Registered', pb);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 18,
        left: 14,
        right: 14,
        height: 52,
        child: FutureBuilder<User>(
            future: _getNames(),
            builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
              User user = User(
                  "Maximilian", "Laue", Image.asset('assets/Personavatar.png'));
              if (snapshot.hasData) {
                user = snapshot.data!;
              }

              List<Widget> children = [
                Image.asset('assets/Personavatar.png'),
                Container(
                    margin: const EdgeInsets.only(left: 14),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${user.prename}\n',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w700,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: user.lastname,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ))
              ];
              return Row(children: children);
            }));
  }
}
