import 'package:flutter/material.dart';
import '../../widgets/container.dart';
import '../../widgets/inputfield.dart';
import '../../widgets/datepicker.dart';

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
    Size screenSize = MediaQuery.of(context).size;
    double screenHeight = screenSize.height;
    double screenWidth = screenSize.width;

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
              fontSize: 35,
              children: [
                InputField(
                  controller: prenameController,
                  hintText: 'Prename',
                  obscureText: false,
                  margin: const EdgeInsets.only(bottom: 25),
                ),
                InputField(
                  controller: prenameController,
                  hintText: 'Lastname',
                  obscureText: false,
                  margin: const EdgeInsets.only(bottom: 12.5),
                ),
                SizedBox(
                  width: 148,
                  height: 18,
                  child: Text(
                    'Date of Birth',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
                SizedBox(height: 12.5),
                DatePicker(
                  margin: const EdgeInsets.only(bottom: 25),
                ),
                InputField(
                  controller: prenameController,
                  hintText: 'Email',
                  obscureText: false,
                  margin: const EdgeInsets.only(bottom: 25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
