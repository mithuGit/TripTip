import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    //Get Screen Size
    Size screenSize = MediaQuery.of(context).size;
    double screenHeight = screenSize.height;
    double screenWidth = screenSize.width;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFCBEFFF),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: screenHeight * (34.81 / 100),
            ),
            Expanded(
              child: SvgPicture.asset(
                'assets/background_city.svg',
                //height: double.infinity,
                width: double.infinity,
                //fit: BoxFit.cover,
              ),
            )
          ],
        ),
      ),
    );
  }
}
