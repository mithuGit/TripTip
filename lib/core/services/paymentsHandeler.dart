import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class NoPayOutinformation implements Exception {
  String cause;
  NoPayOutinformation(this.cause);
}

class PaymentsHandeler {
  
  static FirebaseFunctions functions = FirebaseFunctions.instanceFor(region: "europe-west3");
  static Future<String> createAccoutAndAddPaymentsMethode(
      DocumentReference user) async {
    final result = await functions
        .httpsCallable('stripeAddPaymentsMethode', )
        .call();

    final response = result.data;

    if (response["success"]) {
      return response["customer"];
    } else {
      throw response["error"];
    }
  }

  static Future<void> refund(DocumentSnapshot user) async {
    String _stripeId = "";
    if ((user.data()! as Map<String, dynamic>)["stripeId"] == null) {
      try {
        _stripeId = await createAccoutAndAddPaymentsMethode(user.reference);
      } catch (e) {
        throw "Error creating Account$e";
      }
    } else {
      _stripeId = (user.data()! as Map<String, dynamic>)["stripeId"];
    }
    //TODO: CHeck if more than 50Cent

    String? cachedPaymentIntend;
    try {
      final result =
          await functions.httpsCallable('stripeRefund').call(
        {
          "customer": _stripeId,
        },
      );
      if (result.data["success"] == false) {
        throw result.data["error"];
      }
      cachedPaymentIntend = result.data["paymentIntentId"];
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: result.data["paymentIntent"],
        merchantDisplayName: 'TripTip',
        customerId: _stripeId,
        customerEphemeralKeySecret: result.data["ephemeralKey"],
        style: ThemeMode.dark,
      ));
      // Start Payment
      await Stripe.instance.presentPaymentSheet();
    } on FirebaseFunctionsException catch (error) {
      throw "Error creating refund: ${error.message}";
    } on StripeException catch (error) {
      debugPrint("StripeException");
      debugPrint(error.toString());
      if (error.error.code == FailureCode.Canceled) {
        debugPrint("Canceled");
        if (cachedPaymentIntend != null) {
          final cancelResult = await functions
              .httpsCallable("stripeCancelRefund")
              .call(
            {
              "paymentIntentId": cachedPaymentIntend,
              "customer": _stripeId,
            },
          );
          debugPrint(cancelResult.data.toString());
          if (cancelResult.data["success"]) {
            debugPrint("success");
          } else {
            debugPrint("error");
            throw "Error canceling refund";
          }
        }
      }
    } catch (error) {
      throw "Error creating refund: ${error.toString()}";
    }
  }

  static Future<void> bookToBankAccount(DocumentSnapshot myAccount) async {
    Map<String, dynamic> data = myAccount.data()! as Map<String, dynamic>;
    if (data["payoutInformation"] == null) {
      throw NoPayOutinformation("No Payout Information");
    }
    final result = await functions
        .httpsCallable('bookToBankAccount')
        .call();
    final response = result.data as Map<String, dynamic>;
    if (!response["success"]) {
      throw response["error"];
    }
  }

  static Future<void> payOpenRefundsPerUser(
      DocumentReference userToPayFor, DocumentReference trip) async {
    final result = await functions
        .httpsCallable('payOpenRefundsPerUser')
        .call({
      "destinationUser": userToPayFor.id,
      "trip": trip.id,
    });
    final response = result.data as Map<String, dynamic>;
    if (!response["success"]) {
      throw response["error"];
    }
  }
  static Future<void> deleteRequest(DocumentReference request) async {
    debugPrint(request.path);
    final result = await functions
        .httpsCallable('deleteRequest')
        .call({
      "request": request.path,
    });
    final response = result.data as Map<String, dynamic>;
    if (!response["success"]) {
      throw response["error"];
    }
  }
}
