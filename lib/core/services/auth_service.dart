import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_praktikum/core/services/init_pushnotifications.dart';

/*
  AuthService is a class that contains all the methods for authentication
  like signInWithGoogle, signInWithFacebook and some extra methods to get the
  user's prename and lastname
*/
String getPrename() {
  if(FirebaseAuth.instance.currentUser!.displayName == null) {
    return '';
  }
  String displayName = FirebaseAuth.instance.currentUser!.displayName!;
  return displayName.split(' ')[0];
}
String getLastname() {
  if(FirebaseAuth.instance.currentUser!.displayName == null) {
    return '';
  }
  String displayName = FirebaseAuth.instance.currentUser!.displayName!;
  List<String> name = displayName.split(' ');
  name.removeAt(0);
  return name.join(' ');
}

// Google Sign In
Future<UserCredential> signInWithGoogle() async {
  // beginn interactive sign in process
  final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
  // obtain auth details from the request
  final GoogleSignInAuthentication gAuth = await gUser!.authentication;
  // create a new credential for user
  final credential = GoogleAuthProvider.credential(
    accessToken: gAuth.accessToken,
    idToken: gAuth.idToken,
  );

  UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

  if (userCredential.user != null) {
    if (userCredential.additionalUserInfo!.isNewUser) {
      // add user to firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': userCredential.user!.email,
        'prename': getPrename(),
        'lastname': getLastname(),
        'uid': userCredential.user!.uid,
        'profilePicture': userCredential.user!.photoURL,
        'dateOfBirth': null
      });
    }
    
  }
  if(FirebaseAuth.instance.currentUser != null) {
    await FirebaseAuth.instance.currentUser!.reload();
  }
 
  await PushNotificationService().gantPushNotifications();
  // finally, lets sign in the user
  return userCredential;
}

Future<void> signInWithFacebook() async {
  final LoginResult loginResult = await FacebookAuth.instance.login();

  final credential =
      FacebookAuthProvider.credential(loginResult.accessToken!.token);


  UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

  if (userCredential.user != null) {
    if (userCredential.additionalUserInfo!.isNewUser) {
      // add user to firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'prename': getPrename(),
        'lastname': getLastname(),
        'email': userCredential.user!.email,
        'profilePicture': userCredential.user!.photoURL,
        'uid': userCredential.user!.uid,
        'dateOfBirth': null
      });
    }
    await PushNotificationService().gantPushNotifications();
  }

  await FirebaseAuth.instance.signInWithCredential(credential);
}
