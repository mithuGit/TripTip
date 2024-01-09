import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

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
      try {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: _setupIntent,
          merchantDisplayName: 'TipTrip',
          customerId: _customer,
          customerEphemeralKeySecret: _ephemeralKey,
        ));
        await Stripe.instance.presentPaymentSheet();
      } catch (e) {
        print(e);
      }
    } else {
      throw _response["error"];
    }
    print(_response);
    return _response["customer"];
  }

  Future<void> refund(DocumentSnapshot user) async {
    String _stripeId = "";
    if ((user.data()! as Map<String, dynamic>)["stripeId"] == null) {
      _stripeId = await createAccoutAndAddPaymentsMethode(user.reference);
    } else {
      _stripeId = (user.data()! as Map<String, dynamic>)["stripeId"];
    }
    //TDOD: CHeck if more than 50Cent
    try {
      final result =
          await FirebaseFunctions.instance.httpsCallable('stripeRefund').call(
        {
          "customer": _stripeId,
          "amount": 100,
        },
      );
      final _response = result.data;
      print(_response);
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

    } on StripeException catch (error) {
      debugPrint("StripeException");
      
    } catch (error) {
    }
  }

  Future<void> bookToBankAccount() async {
    final result = await FirebaseFunctions.instanceFor(region: 'us-central1')
        .httpsCallable('stripeCheckcostumerOrCreate')
        .call(
      {
        "text": "text",
        "push": true,
      },
    );
    final _response = result.data as String;
    print(_response);
  }

  Future<void> payOpenRefundsPerUser(
      List<Map<String, dynamic>> openRefunds, DocumentReference theotherUser, DocumentReference me) async {
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
