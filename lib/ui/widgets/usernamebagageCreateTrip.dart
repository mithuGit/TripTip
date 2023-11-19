import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  String prename;
  String lastname;
  Image profileImage;
  User(this.prename, this.lastname, this.profileImage);
}

class UsernameBagageCreateTrip extends StatefulWidget {
  const UsernameBagageCreateTrip({super.key});

  @override
  State<UsernameBagageCreateTrip> createState() =>
      _UsernameBagageCreateTripState();
}

class _UsernameBagageCreateTripState extends State<UsernameBagageCreateTrip> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<User> _getNames() async {
    String? name =  _auth.currentUser!.displayName;
    Image pb = Image.asset('assets/Personavatar.png');
    if (name != null) {
      if(RegExp(r'.\ .').hasMatch(name)) {
        List<String> names = name.split(' ');
        List<String> firsts = names.sublist(0, names.length-1);

        return User(firsts.join(' '), names[names.length - 1], pb);
      } else { 
        return User(name, '', pb);
      }
    } else {
      return User('Not', 'Registerd', pb);
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
                            text: user.prename + '\n',
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
