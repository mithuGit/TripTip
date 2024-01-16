import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class NoPayOutinformation implements Exception {
  String cause;
  NoPayOutinformation(this.cause);
}

class PaymentsHandeler {
  FirebaseFunctions functions = FirebaseFunctions.instance;
  Future<String> createAccoutAndAddPaymentsMethode(
      DocumentReference user) async {
    final result = await FirebaseFunctions.instance
        .httpsCallable('stripeAddPaymentsMethode')
        .call();

    final _response = result.data;

    if (_response["success"]) {
      final _setupIntent = _response["setupIntent"];
      final _ephemeralKey = _response["ephemeralKey"];
      final _customer = _response["customer"];
    } else {
      throw _response["error"];
    }
    return _response["customer"];
  }

  Future<void> refund(DocumentSnapshot user) async {
    String _stripeId = "";
    if ((user.data()! as Map<String, dynamic>)["stripeId"] == null) {
      try {
        _stripeId = await createAccoutAndAddPaymentsMethode(user.reference);
      } catch (e) {
        throw "Error creating Account";
      }
    } else {
      _stripeId = (user.data()! as Map<String, dynamic>)["stripeId"];
    }
    //TODO: CHeck if more than 50Cent

    String? cachedPaymentIntend;
    try {
      final result =
          await FirebaseFunctions.instance.httpsCallable('stripeRefund').call(
        {
          "customer": _stripeId,
          "amount": 23.4,
        },
      );
      final _response = result.data;
      print(_response);
      cachedPaymentIntend = _response["paymentIntentId"];
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: _response["paymentIntent"],
        merchantDisplayName: 'TipTrip',
        customerId: _stripeId,
        customerEphemeralKeySecret: _response["ephemeralKey"],
        style: ThemeMode.dark,
      ));
      // Start Payment
      await Stripe.instance.presentPaymentSheet();
    } on FirebaseFunctionsException catch (error) {
      throw "Error creating refund";
    } on StripeException catch (error) {
      debugPrint("StripeException");
      debugPrint(error.toString());
      if (error.error.code == FailureCode.Canceled) {
        debugPrint("Canceled");
        if (cachedPaymentIntend != null) {
          final cancelResult = await FirebaseFunctions.instance
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
    } catch (error) {}
  }

  Future<void> bookToBankAccount(DocumentSnapshot myAccount) async {
    Map<String, dynamic> data = myAccount.data()! as Map<String, dynamic>;
    if (data["payoutInformation"] == null) {
      throw NoPayOutinformation("No Payout Information");
    }
    final result = await FirebaseFunctions.instance
        .httpsCallable('bookToBankAccount')
        .call();
    final _response = result.data as String;
    print(_response);
  }

  Future<void> payOpenRefundsPerUser(List<Map<String, dynamic>> openRefunds,
      DocumentReference theotherUser, DocumentReference me) async {
    double sumOfRefunds = 0;
    for (final refund in openRefunds) {
      final QueryDocumentSnapshot request = refund["request"];
      List<dynamic> to = (request.data()! as Map<String, dynamic>)["to"];
      to[refund["indexInArray"]] = {
        "amount": refund["amount"],
        "user": me,
        "status": "paid",
      };
      sumOfRefunds += refund["amount"] * 1.0;
      await request.reference.update({
        "to": to,
      });
    }
    await theotherUser.update({
      "balance": FieldValue.increment(sumOfRefunds),
    });
    await me.update({
      "balance": FieldValue.increment(-sumOfRefunds),
    });
  }
}
