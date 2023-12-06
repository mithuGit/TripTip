import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/topbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted)  {
      GoRouter.of(context).go('/loginorregister');
    }  
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
        appBar: const TopBar(
          isDash: true,
          icon: Icons.add,
          onTapForIconWidget: null,
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/mainpage_pic/dashboard.png'), // assets/BackgroundCity.png
                  fit: BoxFit.fill,
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
                    //Uri.file(user.photoURL!).isAbsolute
                    //    ? Image.network(user.photoURL!)
                    //    : Image.asset(user.photoURL!),
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
        bottomNavigationBar: NavigationBarTheme(
            data: const NavigationBarThemeData(
              labelTextStyle: MaterialStatePropertyAll(
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            child: NavigationBar(
              surfaceTintColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              height: 65,
              backgroundColor:
                  Colors.transparent, // const Color.fromARGB(255, 83, 211, 96),
              labelBehavior: NavigationDestinationLabelBehavior
                  .alwaysHide, //=> damit geht Text unter Icon weg
              animationDuration: const Duration(milliseconds: 200),
              selectedIndex: index,
              // onDestinationSelected:_onItemTapped,
              destinations: const [
                NavigationDestination(
                  icon: ImageIcon(
                    AssetImage('assets/navbar_pic/home.256x229.png'),
                    color: Colors.white,
                    size: 35,
                  ),
                  label: "Dashboard",
                  selectedIcon: ImageIcon(
                    AssetImage('assets/navbar_pic/home.256x229.png'),
                    color: Colors.black,
                    size: 35,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    AssetImage('assets/navbar_pic/wallet.256x235.png'),
                    color: Colors.white,
                    size: 35,
                  ),
                  label: "Payment",
                  selectedIcon: ImageIcon(
                    AssetImage('assets/navbar_pic/wallet.256x235.png'),
                    color: Colors.black,
                    size: 35,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    AssetImage('assets/navbar_pic/map.256x256.png'),
                    color: Colors.white,
                    size: 35,
                  ),
                  label: "Map",
                  selectedIcon: ImageIcon(
                    AssetImage('assets/navbar_pic/map.256x256.png'),
                    color: Colors.black,
                    size: 35,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    AssetImage('assets/navbar_pic/train.197x256.png'),
                    color: Colors.white,
                    size: 35,
                  ),
                  label: "Tickets",
                  selectedIcon: ImageIcon(
                    AssetImage('assets/navbar_pic/train.197x256.png'),
                    color: Colors.black,
                    size: 35,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    AssetImage('assets/navbar_pic/user.226x256.png'),
                    color: Colors.white,
                    size: 35,
                  ),
                  label: "Profile",
                  selectedIcon: ImageIcon(
                    AssetImage('assets/navbar_pic/user.226x256.png'),
                    color: Colors.black,
                    size: 35,
                  ),
                ),
              ],
            )));
  }
}
