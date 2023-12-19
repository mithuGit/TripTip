import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class CardFormScreen extends StatelessWidget {
  const CardFormScreen({super.key});

  Future<void> initPayment(
      {required String email,
      required double amount,
      required BuildContext context}) async {
    try {
      // 1. Create a payment intent on the server
      final response = await http.post(
          Uri.parse(
              'https://us-central1-internetpraktikum.cloudfunctions.net/stripePaymentIntentRequest'),
          body: {
            'email': email,
            'amount': amount.toString(),
          });
      final jsonResponse = jsonDecode(response.body);
      log(jsonResponse.toString());
      // 2. Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: jsonResponse['paymentIntent'],
        merchantDisplayName: 'TipTrip',
        customerId: jsonResponse['customer'],
        customerEphemeralKeySecret: jsonResponse['ephermeralKey'],
      ));
      // Start Payment
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Payment successfull'),
      ));
    } catch (e) {
      if (e is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('An error occured ${e.error.localizedMessage}'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('An error occured $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with Credit Card'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Pay 20\$'),
          onPressed: () async {
            await initPayment(
                email: 'email@test.com', amount: 100.0, context: context);
          },
        ),
      ),
    );
  }
}
