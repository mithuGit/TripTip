import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

import '../../widgets/finanzen/extendablecontainer.dart';

class Finanzen extends StatefulWidget {
  const Finanzen({Key? key}) : super(key: key);

  @override
  State<Finanzen> createState() => _FinanzenState();
}

class _FinanzenState extends State<Finanzen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('Finanzübersicht', style: Styles.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                widthFactor: 1.0, // Take the whole width of the screen
                heightFactor: 0.66, // 65% of the screen height
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/bg_finanzen.png'),
                      fit: BoxFit.fill, // Maintain width, adjust height
                    ),
                  ),
                  child: Center(
                    child: ExpandableContainer(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
