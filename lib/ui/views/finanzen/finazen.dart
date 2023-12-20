import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/header/topbar.dart';
import '../../widgets/finanzen/extendablecontainer.dart';

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
      appBar: TopBar(
        isDash: false,
        icon: Icons.payment,
        onTapForIconWidget: () {
          CustomBottomSheet
              .show(context, title: "Change your Payment Method", content: [
            Builder(
              builder: (context) {
                return Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      const Text("Currently only Credit Card is supported."),
                      const SizedBox(
                          height:
                              8), // Hier kannst du die gewünschte vertikale Distanz einstellen
                      const Text("We are working on adding more payment methods."),
                      const SizedBox(height: 32),
                      Image.asset("assets/coding.png", height: 150),
                    ],
                  ),
                );
              },
            ), // get the secound element of list since the first is the Userdata
          ]);
        },
        title: "Finanzübersicht",
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/mainpage_pic/finazen.png'),
                fit: BoxFit.cover, // Maintain width, adjust height
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: Padding(
              padding:
                  EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 40),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 25),
                      child: ExpandableContainer(
                        name: 'Test0',
                        items: [
                          'Activity 1: 10.00 ',
                          'Activity 2: 10.00 ',
                        ],
                        sum: 45,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 25),
                      child: ExpandableContainer(
                        name: 'Test1',
                        items: [
                          'Activity 1: 10.00 ',
                          'Activity 2: 20.00 ',
                          'Activity 3: 15.00 ',
                          'Activity 4: 15.00 ',
                          'Activity 5: 15.00 ',
                          'Activity 6: 15.00 ',
                          'Activity 7: 15.00 ',
                          'Activity 8: 15.00 ',
                          'Activity 9: 15.00 ',
                        ],
                        sum: 45,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 25),
                      child: ExpandableContainer(
                        name: 'Test2',
                        items: [
                          'Activity 1: 10.00 ',
                          'Activity 2: 20.00 ',
                          'Activity 3: 15.00 ',
                        ],
                        sum: 45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
