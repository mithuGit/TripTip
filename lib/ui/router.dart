//import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'Pages/HomeView.dart';
import 'Pages/LoginView.dart';
import 'Pages/PostView.dart';
class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeView());
      case 'login':
        return MaterialPageRoute(builder: (_) => const LoginView());
      case 'post':
        return MaterialPageRoute(builder: (_) => const PostView());
      default:
        return MaterialPageRoute(builder: (_) {
          return Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          );
        });
    }
  }
}
