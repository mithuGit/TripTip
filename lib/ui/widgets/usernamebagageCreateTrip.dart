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
  const UsernameBagageCreateTrip(
      {super.key, required this.firestore, required this.auth});

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
      final ref = await widget.firestore
          .collection('users')
          .where('uid', isEqualTo: widget.auth.currentUser!.uid)
          .get();
      if (ref.docs.isNotEmpty) {
        final data = ref.docs.first.data();
        prename = data['prename'];
        lastname = data['lastname'];
        if(data['profilePicture'] != null) pb = Image.network(data['profilePicture']);
      }

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
