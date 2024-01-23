import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/views/account/account_details.dart';
import 'package:internet_praktikum/ui/views/account/setInterestsPage.dart';
import 'package:internet_praktikum/ui/views/dashboard/archive.dart';
import 'package:internet_praktikum/ui/views/dashboard/readDiary.dart';
import 'package:internet_praktikum/ui/views/dashboard/writeDiary.dart';
import 'package:internet_praktikum/ui/views/finanzen/finazen.dart';
import 'package:internet_praktikum/ui/views/dashboard/dashboard.dart';
import 'package:internet_praktikum/ui/views/map/map.dart';
import 'package:internet_praktikum/ui/views/profile/info_page.dart';
import 'package:internet_praktikum/ui/views/profile/profile.dart';
import 'package:internet_praktikum/ui/views/ticket/ticket.dart';
import 'package:internet_praktikum/ui/views/navigation/app_navigation.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/login_or_register_page.dart';
import 'package:internet_praktikum/ui/views/trip_setup_pages/change_trip.dart';
import 'package:internet_praktikum/ui/views/trip_setup_pages/create_trip.dart';
import 'package:internet_praktikum/ui/views/trip_setup_pages/join_trip.dart';
import 'package:internet_praktikum/ui/views/trip_setup_pages/share_trip.dart';
import 'package:internet_praktikum/ui/views/trip_setup_pages/select_trip.dart';
import 'package:internet_praktikum/ui/views/verification/OTP_form.dart';
import 'package:internet_praktikum/ui/views/weather/weather.dart';
import 'package:internet_praktikum/ui/views/weather/weather_page.dart';
import 'package:internet_praktikum/ui/widgets/game/gameChooser.dart';

class MyRouter {
  MyRouter._();

  // Private NavigatorKey
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _rootNavigatorDashboard =
      GlobalKey<NavigatorState>(debugLabel: 'shellDashboard');
  static final _rootNavigatorFinazen =
      GlobalKey<NavigatorState>(debugLabel: 'shellFinazen');
  static final _rootNavigatorMap =
      GlobalKey<NavigatorState>(debugLabel: 'shellMap');
  static final _rootNavigatorTicket =
      GlobalKey<NavigatorState>(debugLabel: 'shellTicket');
  static final _rootNavigatorProfile =
      GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  static final router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: <RouteBase>[
      // HomePage Route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppNavigation(
            navigationShell: navigationShell,
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: _rootNavigatorDashboard,
            routes: [
              GoRoute(
                name: 'home',
                path: '/',
                builder: (context, state) => DashBoard(
                  key: state.pageKey,
                ),
                redirect: (BuildContext context, GoRouterState state) {
                  FirebaseAuth auth = FirebaseAuth.instance;
                  if (auth.currentUser == null) {
                    return '/loginorregister';
                  } else if (auth.currentUser != null &&
                      !auth.currentUser!.emailVerified) {
                    print(!auth.currentUser!.emailVerified);
                    return '/otp';
                  } else {
                    return null; // return "null" to display the intended route without redirecting
                  }
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _rootNavigatorFinazen,
            routes: [
              GoRoute(
                name: 'finazen',
                path: '/finazen',
                builder: (context, state) => Finanzen(
                  key: state.pageKey,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _rootNavigatorMap,
            routes: [
              GoRoute(
                name: 'map',
                path: '/map',
                builder: (context, state) => MapPage(
                  key: state.pageKey,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _rootNavigatorTicket,
            routes: [
              GoRoute(
                name: 'ticket',
                path: '/ticket',
                builder: (context, state) => Ticket(
                  key: state.pageKey,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _rootNavigatorProfile,
            routes: [
              GoRoute(
                name: 'profile',
                path: '/profile',
                builder: (context, state) => ProfilePage(
                  key: state.pageKey,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        name: 'loginOrRegister',
        path: '/loginorregister',
        builder: (context, state) => LoginOrRegisterPage(
          key: state.pageKey,
        ),
      ),
      GoRoute(
          name: 'otp',
          path: '/otp',
          builder: (context, state) => OTPForm(
                key: state.pageKey,
              )),
      GoRoute(
        name: 'accountdetails',
        path: '/accountdetails/:isEditProfile',
        builder: (context, state) {
          final isEditProfile = state.pathParameters['isEditProfile'];
          return Account(
            key: state.pageKey,
            isEditProfile: isEditProfile == "true",
          );
        },
      ),
      GoRoute(
        name: 'createtrip',
        path: '/createtrip',
        builder: (context, state) => CreateTrip(
          auth: FirebaseAuth.instance,
          firestore: FirebaseFirestore.instance,
          key: state.pageKey,
        ),
      ),
      GoRoute(
        name: 'selecttrip',
        path: '/selecttrip/:noTrip',
        builder: (context, state) => SelectTrip(
          noTrip: state.pathParameters["noTrip"] == "true",
          key: state.pageKey,
        ),
      ),
      GoRoute(
        name: 'jointrip',
        path: '/jointrip',
        builder: (context, state) => JoinTrip(
          key: state.pageKey,
        ),
      ),
      GoRoute(
        name: 'sharetrip',
        path: '/sharetrip/:tripId/:afterCreate',
        builder: (context, state) {
          if (state.pathParameters.isEmpty) {
            return ShareTrip(
              key: state.pageKey,
              tripId: "Something went Wrong!",
              afterCreate: "f",
            );
          } else {
            return ShareTrip(
              key: state.pageKey,
              tripId: state.pathParameters["tripId"]!,
              afterCreate: state.pathParameters["afterCreate"]!,
            );
          }
        },
      ),
      GoRoute(
          name: 'weatherpage',
          path: '/weatherpage',
          builder: (context, state) {
            return WeatherPage(
              key: state.pageKey,
              actualWeather: state.extra! as Weather,
            );
          }),
      GoRoute(
        name: 'changetrip',
        path: '/changetrip',
        builder: (context, state) => ChangeTrip(
          key: state.pageKey,
        ),
      ),

      GoRoute(
        name: 'archive',
        path: '/archive',
        builder: (context, state) => Archive(
          key: state.pageKey,
        ),
      ),
      GoRoute(
        name: 'setInterests',
        path: '/setinterests/:isCreate',
        builder: (context, state) {
          final isCreate = state.pathParameters['isCreate'];
          return SetInterestsPage(
            key: state.pageKey,
            isCreate: isCreate == "true",
          );
        },
      ),
      GoRoute(
        name: 'info',
        path: '/info',
        builder: (context, state) => InfoPage(
          key: state.pageKey,
        ),
      ),
      GoRoute(
          name: 'diary',
          path: '/diary/:writeOrRead',
          builder: (context, state) {
            final day = state.extra as DocumentReference?;
            final writeOrRead = state.pathParameters['writeOrRead'];
            if (writeOrRead == "write") {
              return WriteDiary(day: day!);
            } else {
              return ReadDiary(day: day!);
            }
          }),
      GoRoute(
        name: 'gameChooser',
        path: '/gameChooser',
        builder: (context, state) => GameWidgetReturn(
          key: state.pageKey,
        ),
      ),
    ],
  );
}
