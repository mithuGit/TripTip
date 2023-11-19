
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/usernamebagageCreateTrip.dart';
import '../../widgets/container.dart';
import '../../widgets/inputfield.dart';

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
  //Controller for text
  final prenameController = TextEditingController();
  

  void connectPhotosAlbum() async {
    setState(() {
    //  name = "Hallo";
    });
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
                        MyButton(
                            onTap: connectPhotosAlbum,
                            imagePath: 'assets/googlephotos.png',
                            text: 'Create Photos Album')
                      ],
                    )),
              ),
            ),
            UsernameBagageCreateTrip()
          ]),
        ));
  }
}
