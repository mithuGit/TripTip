import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/views/weather/weather_page.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void deleteUser() async {
    await FirebaseAuth.instance.currentUser!.delete();
  }

  /*void _onItemTapped(int index) {
    setState(() {
      this.index = index;
    });
  }*/
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        appBar: AppBar(actions: [
          IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout)),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WeatherPage()),
                );
              },
              icon: const Icon(Icons.sunny),
            ),
          ),
        ]),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/BackgroundCity.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Welcome ${user.displayName}'),
                      const SizedBox(height: 20),
                      Text('Your email is ${user.email}'),
                      const SizedBox(height: 20),
                      Text('Your uid is ${user.uid}'),
                      const SizedBox(height: 20),
                      Text('Your profile picture is ${user.photoURL}'),
                      const SizedBox(height: 20),
                      Text('Your profile picture is ${user.photoURL}'),
                      MyButton(
                        onTap: signUserOut,
                        text: "Logout",
                        colors: Colors.red,
                      ),
                      MyButton(
                        onTap: deleteUser,
                        text: "Delete Account",
                        colors: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBarTheme(
            data: const NavigationBarThemeData(
              labelTextStyle: MaterialStatePropertyAll(
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            child: NavigationBar(
              height: 65,
              backgroundColor:
                  Colors.transparent, // const Color.fromARGB(255, 83, 211, 96),
              labelBehavior: NavigationDestinationLabelBehavior
                  .alwaysHide, //=> damit geht Text unter Icon weg
              animationDuration: const Duration(milliseconds: 200),
              selectedIndex: index,
              //onDestinationSelected:_onItemTapped,
              destinations: const [
                NavigationDestination(
                  icon: ImageIcon(
                    AssetImage('assets/navbar_pic/home.256x229.png'),
                    color: Colors.white,
                    size: 40,
                  ),
                  label: "Dashboard",
                  selectedIcon: ImageIcon(
                    AssetImage('assets/navbar_pic/home.256x229.png'),
                    color: Colors.black,
                    size: 40,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    AssetImage('assets/navbar_pic/wallet.256x235.png'),
                    color: Colors.white,
                    size: 40,
                  ),
                  label: "Payment",
                  selectedIcon: ImageIcon(
                    AssetImage('assets/navbar_pic/wallet.256x235.png'),
                    color: Colors.black,
                    size: 40,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    AssetImage('assets/navbar_pic/map.256x256.png'),
                    color: Colors.white,
                    size: 40,
                  ),
                  label: "Map",
                  selectedIcon: ImageIcon(
                    AssetImage('assets/navbar_pic/map.256x256.png'),
                    color: Colors.black,
                    size: 40,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    AssetImage('assets/navbar_pic/train.197x256.png'),
                    color: Colors.white,
                    size: 40,
                  ),
                  label: "Tickets",
                  selectedIcon: ImageIcon(
                    AssetImage('assets/navbar_pic/train.197x256.png'),
                    color: Colors.black,
                    size: 40,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    AssetImage('assets/navbar_pic/user.226x256.png'),
                    color: Colors.white,
                    size: 40,
                  ),
                  label: "Profile",
                  selectedIcon: ImageIcon(
                    AssetImage('assets/navbar_pic/user.226x256.png'),
                    color: Colors.black,
                    size: 40,
                  ),
                ),
              ],
            )));
  }
}
