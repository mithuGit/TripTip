import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/views/finanzen/request.dart';
import 'package:internet_praktikum/ui/widgets/topbar.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../widgets/finanzen/extendablecontainer.dart';
import '../../widgets/finanzen/slidablebutton.dart';

class Finanzen extends StatefulWidget {
  const Finanzen({Key? key}) : super(key: key);

  @override
  State<Finanzen> createState() => _FinanzenState();
}

class _FinanzenState extends State<Finanzen> {
  /* Future<void> initPaymentSheet() async {
    try {
      // 1. create payment intent on the server
      // final data = await _createTestPaymentSheet();

      // create some billingdetails
      final billingDetails = BillingDetails(
        name: 'Flutter Stripe',
        email: 'email@stripe.com',
        phone: '+48888000888',
        address: Address(
          city: 'Houston',
          country: 'US',
          line1: '1459  Circle Drive',
          line2: '',
          state: 'Texas',
          postalCode: '77063',
        ),
      ); // mocked data for tests

      // 2. initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Main params
          paymentIntentClientSecret: "testSecret",
          merchantDisplayName: 'Flutter Stripe Store Demo',
          // Customer params
          customerId: "testCustomerId",
          customerEphemeralKeySecret: "testSecret",

          // Extra params
          primaryButtonLabel: 'Pay now',
          // applePay: PaymentSheetApplePay(
          //   merchantCountryCode: 'DE',
          // ),
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: 'DE',
            testEnv: true,
          ),
          style: ThemeMode.dark,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              background: Colors.lightBlue,
              primary: Colors.blue,
              componentBorder: Colors.red,
            ),
            shapes: PaymentSheetShape(
              borderWidth: 4,
              shadow: PaymentSheetShadowParams(color: Colors.red),
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              shapes: PaymentSheetPrimaryButtonShape(blurRadius: 8),
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color.fromARGB(255, 231, 235, 30),
                  text: Color.fromARGB(255, 235, 92, 30),
                  border: Color.fromARGB(255, 235, 92, 30),
                ),
              ),
            ),
          ),
          billingDetails: billingDetails,
        ),
      );
      // setState(() {
      //   step = 1;
      // });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: const TopBar(
          isDash: false,
          icon: Icons.payment,
          onTapForIconWidget: null,
          title: "Finanzübersicht",
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                widthFactor: 1.0, // Take the whole width of the screen
                heightFactor: 0.66, // 65% of the screen height
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/mainpage_pic/finazen.png'),
                      fit: BoxFit.fill, // Maintain width, adjust height
                    ),
                  ),
                  //child: ExpandableContainer(),
                  /*const Center(
                  child: //ExpandableContainer(),
                      SlideButton(
                    buttonText: 'Slide to Pay',
                    margin: EdgeInsets.only(bottom: 25),
                  ),
                ),*/
                ),
              ),
            ),
            const Padding(
              padding:
                  EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 45),
              child: ExpandableContainer(
                name: "Felix",
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // initPaymentSheet();
          },
          child: const Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
        ));
  }
}
