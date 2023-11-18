import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import '../../widgets/container.dart';
import '../../widgets/inputfield.dart';

class CreateTrip extends StatefulWidget {
  const CreateTrip({super.key});

  @override
  State<CreateTrip> createState() => _TripCreateState();
}

class _TripCreateState extends State<CreateTrip> {
  //Controller for text
  final prenameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String name = "Päpke";
  final Future<String> _calculation = Future<String>.delayed(
    const Duration(seconds: 2),
    () => 'Data Loaded',
  );
  void connectPhotosAlbum() async {
    setState(() {
      name = "Hallo";
    });
    print(_auth.currentUser);
  }
  @override
  Widget build(BuildContext context) {
    // Get Screen Size
    return Scaffold(
        backgroundColor: const Color(0xFFCBEFFF),
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
                        InputField(
                          controller: prenameController,
                          hintText: 'Destination',
                          obscureText: false,
                          margin: const EdgeInsets.only(bottom: 25),
                        ),
                        MyButton(onTap: connectPhotosAlbum,
                        imagePath: 'assets/googlephotos.png',
                        text: 'Create Photos Album')
                      ],
                    )),
              ),
            ),
            Positioned(
                top: 18,
                left: 14,
                right: 14,
                height: 52,
                child: Row(
                  children: [
                    Image.asset('assets/Personavatar.png'),
                    Container(
                      margin: const EdgeInsets.only(left: 14),
                        child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Tim Carlo\n',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w700,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: name,
                            style: TextStyle(
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
                  ],
                )),
          ]),
        ));
  }
}
