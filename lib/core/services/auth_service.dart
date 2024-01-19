import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_praktikum/core/services/init_pushnotifications.dart';

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

  // hier muss noch eingebaut werden, wegen OTP Verifizierung
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
        'prename': userCredential.user!.displayName,
        'lastname': userCredential.user!.displayName,
        'uid': userCredential.user!.uid,
        'profilePicture': userCredential.user!.photoURL,
        'dateOfBirth': null
      });
    }
    await PushNotificationService().initialise();
  }
  // finally, lets sign in the user
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

Future<void> signInWithFacebook() async {
  final LoginResult loginResult = await FacebookAuth.instance.login();

  final credential =
      FacebookAuthProvider.credential(loginResult.accessToken!.token);

  // hier muss noch eingebaut werden, wegen OTP Verifizierung
  UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

  if (userCredential.user != null) {
    if (userCredential.additionalUserInfo!.isNewUser) {
      // add user to firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'prename': userCredential.user!.displayName,
        'lastname': 'LastNameTest',
        'email': userCredential.user!.email,
        'profilePicture': userCredential.user!.photoURL,
        'uid': userCredential.user!.uid,
        'dateOfBirth': null
      });
    }
    await PushNotificationService().initialise();
  }

  await FirebaseAuth.instance.signInWithCredential(credential);
}
