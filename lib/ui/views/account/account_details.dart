import 'package:flutter/material.dart';
import '../../widgets/container.dart';
import '../../widgets/inputfield.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
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
                  title: "Account Details:",
                  smallSize: true,
                  children: [InputField(
                    controller: prenameController,
                    hintText: 'Prename',
                    obscureText: false,
                    margin: const EdgeInsets.only(bottom: 25),
                  ),InputField(
                    controller: prenameController,
                    hintText: 'Lastname',
                    obscureText: false,
                    margin: const EdgeInsets.only(bottom: 25),
                  ),],
                ),
              ),
          ),
        ));

  }
}
