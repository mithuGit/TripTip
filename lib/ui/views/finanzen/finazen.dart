import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/header/topbar.dart';
import '../../widgets/finanzen/extendablecontainer.dart';
import '../../widgets/finanzen/slidablebutton.dart';

class Finanzen extends StatefulWidget {
  const Finanzen({Key? key}) : super(key: key);

  @override
  State<Finanzen> createState() => _FinanzenState();
}

class _FinanzenState extends State<Finanzen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const TopBar(
          isDash: false,
          icon: Icons.payment,
          onTapForIconWidget: null,
          title: "Finanzübersicht",
        ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 1.0, // Take the whole width of the screen
              heightFactor: 0.66, // 65% of the screen height
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/mainpage_pic/finazen.png'),
                    fit: BoxFit.fill, // Maintain width, adjust height
                  ),
                ),
                //child: ExpandableContainer(),
                /*const Center(
                  child: //ExpandableContainer(),
                      SlideButton(
                    buttonText: 'Slide to Pay',
                    margin: EdgeInsets.only(bottom: 25),
                  ),
                ),*/
              ),
            ),
          ),
          const Padding(
            padding:
                EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 45),
            child: ExpandableContainer(
              name: "Felix",
            ),
          ),
        ],
      ),
    );
  }
}
