import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

import '../../widgets/finanzenWidgets/requestcontainer.dart';
import '../../widgets/inputfield.dart';

class RequestMoney extends StatefulWidget {
  const RequestMoney({super.key});

  @override
  State<RequestMoney> createState() => _RequestMoneyState();
}

class _RequestMoneyState extends State<RequestMoney> {
  final name = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('Request Money', style: Styles.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Image.asset('assets/ icon _credit card_.png'),
          )
        ],
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
                ),
              ),
            ),
            const Padding(
              padding:
                  EdgeInsets.only(top: 80, left: 15, right: 15, bottom: 245),
              child: RequestContainer(
                name: 'Title',
                items: [
                  InputField(
                      hintText: 'Name',
                      obscureText: false,
                      margin: EdgeInsets.only(bottom: 25, left: 15, right: 15)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: InputField(
                              hintText: 'Aktivität',
                              obscureText: false,
                              margin: EdgeInsets.only(
                                  bottom: 25, right: 5, left: 15))),
                      Expanded(
                          child: InputField(
                        hintText: 'Preis',
                        obscureText: false,
                        margin: EdgeInsets.only(bottom: 25, left: 5, right: 15),
                      ))
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
