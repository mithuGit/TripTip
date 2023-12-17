import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:internet_praktikum/blocs/blocs.dart';

class CardFormScreen extends StatelessWidget {
  const CardFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with Credit Card'),
      ),
      body: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          CardFormEditController controller = CardFormEditController(
            initialDetails: state.cardFieldInputDetails,
          );
          if (state.status == PaymentStatus.initial) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Card Form',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Padding(padding: EdgeInsets.only(top: 20, bottom: 20)),
                  CardFormField(
                    controller: controller,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        (controller.details.complete)
                            ? context.read<PaymentBloc>().add(
                                    const PaymentCreateIntent(
                                        billingDetails: BillingDetails(
                                            email: 'felixbauer320@gmail.com'),
                                        items: [
                                      {
                                        'id': 0,
                                      },
                                      {
                                        'id': 1,
                                      },
                                    ]))
                            : ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('The form is not complete')));
                      },
                      child: const Text('Pay')),
                ],
              ),
            );
          } else if (state.status == PaymentStatus.success) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("The payment is successful"),
                const SizedBox(
                  height: 10,
                  width: double.infinity,
                ),
                ElevatedButton(
                    onPressed: () {
                      context.read<PaymentBloc>().add(PaymentStart());
                    },
                    child: const Text('Back to Home'))
              ],
            );
          } else if (state.status == PaymentStatus.failure) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("The payment failed"),
                const SizedBox(
                  height: 10,
                  width: double.infinity,
                ),
                ElevatedButton(
                    onPressed: () {
                      context.read<PaymentBloc>().add(PaymentStart());
                    },
                    child: const Text('Try again'))
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
