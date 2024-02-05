import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

/*
  This is the AppNavigation class which is used to navigate between the different pages of the app
*/

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    // Hier den Initialwert für den ausgewählten Index setzen
    index = widget.navigationShell.currentIndex;
  }

  void _gotoBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isIndex2 = index == 2;

    return Scaffold(
        extendBody: true,
        body: SizedBox(
          child: widget.navigationShell,
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
              backgroundColor: isIndex2
                  ? Colors.white.withOpacity(0.6)
                  : Colors
                      .transparent, // const Color.fromARGB(255, 83, 211, 96),
              labelBehavior: NavigationDestinationLabelBehavior
                  .alwaysHide, //=> damit geht Text unter Icon weg
              animationDuration: const Duration(milliseconds: 200),
              selectedIndex: index,
              onDestinationSelected: (index) {
                setState(() {
                  this.index = index;
                });
                _gotoBranch(this.index);
              },
              destinations: [
                NavigationDestination(
                  icon: ImageIcon(
                    const AssetImage('assets/navbar_pic/home.256x229.png'),
                    color: isIndex2 ? Colors.black : Colors.white,
                    size: 35,
                  ),
                  label: "Dashboard",
                  selectedIcon: const ImageIcon(
                    AssetImage('assets/navbar_pic/home.256x229.png'),
                    color: Colors.black,
                    size: 35,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    const AssetImage('assets/navbar_pic/wallet.256x235.png'),
                    color: isIndex2 ? Colors.black : Colors.white,
                    size: 35,
                  ),
                  label: "Payment",
                  selectedIcon: const ImageIcon(
                    AssetImage('assets/navbar_pic/wallet.256x235.png'),
                    color: Colors.black,
                    size: 35,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    const AssetImage('assets/navbar_pic/map.256x256.png'),
                    color: isIndex2 ? Colors.black : Colors.white,
                    size: 35,
                  ),
                  label: "Map",
                  selectedIcon: const ImageIcon(
                    AssetImage('assets/navbar_pic/map.256x256.png'),
                    color: Colors.black,
                    size: 35,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    const AssetImage('assets/navbar_pic/train.197x256.png'),
                    color: isIndex2 ? Colors.black : Colors.white,
                    size: 35,
                  ),
                  label: "Tickets",
                  selectedIcon: const ImageIcon(
                    AssetImage('assets/navbar_pic/train.197x256.png'),
                    color: Colors.black,
                    size: 35,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    const AssetImage('assets/navbar_pic/user.226x256.png'),
                    color: isIndex2 ? Colors.black : Colors.white,
                    size: 35,
                  ),
                  label: "Profile",
                  selectedIcon: const ImageIcon(
                    AssetImage('assets/navbar_pic/user.226x256.png'),
                    color: Colors.black,
                    size: 35,
                  ),
                ),
              ],
            )));
  }
}
