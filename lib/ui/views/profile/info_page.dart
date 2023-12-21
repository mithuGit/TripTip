import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/views/profile/character.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        title: const Text(
            "The Creators "),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.yellow
          //background color für später selber entscheiden schwierig bei 5 versch Farben 
        ),
        child: const Column(
          children: [
            Row(
              children: [
                CharakterContainer(
                  name: "Mithusan Naguleswaran",
                  description: "Co Founder, CEO",
                  link: "bla bla bla",
                  image: "assets/character_pic/mithu.png",
                  color: Colors.red,
                ),
                CharakterContainer(
                  name: "Thai Binh Nguyen",
                  description: "Co Founder, CEO",
                  link: "bla bla bla",
                  image: "assets/character_pic/thai.png",
                  color: Colors.purple,
                ),
              ],
            ),
            Row(
              children: [
                CharakterContainer(
                  name: "Tim Carlo Päpke",
                  description: "Co Founder, CEO",
                  link: "bla bla bla",
                  image: "assets/character_pic/mithu.png",
                  color: Colors.orange,
                ),
                CharakterContainer(
                  name: "Felix Bauer",
                  description: "Co Founder, CEO",
                  link: "bla bla bla",
                  image: "assets/character_pic/mithu.png",
                  color: Colors.green,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CharakterContainer(
                  name: "David Henn",
                  description: "Co Founder, CEO",
                  link: "bla bla bla",
                  image: "assets/character_pic/mithu.png",
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
