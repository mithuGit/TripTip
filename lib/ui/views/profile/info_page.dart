import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/views/profile/character.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 49, 48, 78),
        leading: IconButton(
          onPressed: () {
            context.go("/profile");
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
        ),
        centerTitle: true,
        title: const Text("The Creators", style: Styles.infoTitle),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 49, 48, 78),
          ),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3 -
                    kToolbarHeight / 3,
                child: const Row(
                  children: [
                    CharakterContainer(
                      name: "Mithusan Naguleswaran",
                      description: "Co Founder, CEO",
                      link:
                          "https://www.linkedin.com/in/mithusan-naguleswaran-b046a1292/",
                      linkname: "LinkedIn",
                      image: "assets/character_pic/mithu.png",
                      color: Colors.red,
                    ),
                    CharakterContainer(
                      name: "Thai Binh Nguyen",
                      description: "Co Founder, CEO",
                      link:
                          "https://www.linkedin.com/in/thai-binh-nguyen-454951224/",
                      linkname: "LinkedIn",
                      image: "assets/character_pic/thai.png",
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3 -
                    kToolbarHeight / 3,
                child: const Row(
                  children: [
                    CharakterContainer(
                      name: "Tim Carlo Päpke",
                      description: "Co Founder, CEO",
                      link: "https://www.instagram.com/timcarlo02/",
                      linkname: "Instagram",
                      image: "assets/character_pic/tim.png",
                      color: Colors.orange,
                    ),
                    CharakterContainer(
                      name: "David Henn",
                      description: "Co Founder, CEO",
                      link: "https://www.instagram.com/davidhenn2610/",
                      linkname: "Instagram",
                      image: "assets/character_pic/david.png",
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3 -
                    kToolbarHeight / 3,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CharakterContainer(
                      name: "Felix Bauer",
                      description: "Co Founder, CEO",
                      link:
                          "https://www.instagram.com/xfelix001?igsh=MWcwcW45amNuc3Nycw%3D%3D&utm_source=qr",
                      linkname: "Instagram",
                      image: "assets/character_pic/felix.png",
                      color: Colors.blue,
                      fill: true,
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Colors.white,
                thickness: 2,
              ),
              const SizedBox(height: 10),
              const Text("Credits",
                  style: Styles.endCredits), // vlt was anderes dafür nehmen
              const SizedBox(height: 10),
              const Text(
                  "Thank you for using our App, We hope you enjoy our App",
                  style: Styles.endCredits),
              const Text("We are a group of 5 students of TU Darmstadt",
                  style: Styles.endCredits),
              const Text(
                  "and created this App for our Internet Praktikum project",
                  style: Styles.endCredits),
              const Text(
                  "Feel free to contact us for any suggestions or questions",
                  style: Styles.endCredits)
            ],
          ),
        ),
      ),
    );
  }
}
