import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    // Get Screen Size
    return Scaffold(
        backgroundColor: const Color(0xFFCBEFFF),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/BackgroundCity.png'),
                fit: BoxFit.cover,
              ),
            ),
             child: Center(
                child: CustomContainer(
                  title: "Start your next Adventure:",
                  fontSize: 35,
                  children: [InputField(
                    controller: prenameController,
                    hintText: 'Destination',
                    obscureText: false,
                    margin: const EdgeInsets.only(bottom: 25),
                  )],
                ),
              ),
          ),
        ));

  }
}
