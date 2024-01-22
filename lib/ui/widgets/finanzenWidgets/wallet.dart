import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/paymentsHandeler.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/finanzenWidgets/collectPayoutInformation.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

class Wallet extends StatefulWidget {
  final DocumentReference user;
  const Wallet({required this.user, super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  bool loading = false;
  Future<void> recharge(DocumentSnapshot user, BuildContext context) async {
    try {
      await PaymentsHandeler.refund(user);
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.showErrorSnackbar(context, e.toString());
      }
    }
  }

  Future<void> bookToBankAccount(
      DocumentSnapshot user, BuildContext context) async {
    try {
      await PaymentsHandeler.bookToBankAccount(user);
    } on NoPayOutinformation {
      if (mounted) {
        CustomBottomSheet.show(context,
            title: "Fill in your Back-Account",
            content: [CollectPayoutInformation(user: user, bookToBankAccount: true)]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34.5),
          color: const Color(0xE51E1E1E)),
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<DocumentSnapshot>(
          stream: widget.user.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error while collecting Wallet Data"),
              );
            }
            double balance = 0.0;
            try {
              balance =
                  (snapshot.data!.data() as Map<String, dynamic>)["balance"] *
                      1.0;
            } catch (e) {
              if (kDebugMode) {
                print(e);
              }
            }
            return Column(
              //    crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Balance",
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontFamily: "Ubuntu"),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(
                  height: 5,
                ),
                if (balance == 0.0) ...[
                  const Text(
                    "0 €",
                    style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Ubuntu"),
                    textAlign: TextAlign.left,
                  ),
                  const Text(
                    "nothing to do here!",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontFamily: "Ubuntu"),
                  ),
                ] else
                  Text(
                    "${(balance * 100).ceil() / 100} €",
                    style: TextStyle(
                        fontSize: 40,
                        color: balance < 0 ? Colors.red : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Ubuntu"),
                    textAlign: TextAlign.left,
                  ),
                const SizedBox(
                  height: 30,
                ),
                if (loading) ...[
                  const Center(
                    child: LinearProgressIndicator(
                      color: Colors.blue,
                    ),
                  )
                ] else ...[
                  if (balance < 0) ...[
                    MyButton(
                        onTap: () async {
                          setState(() {
                            loading = true;
                          });
                          await recharge(snapshot.data!, context);
                          setState(() {
                            loading = false;
                          });
                        },
                        text: "Recharge"),
                  ] else if (balance > 0) ...[
                    MyButton(
                        onTap: () async {
                          setState(() {
                            loading = true;
                          });
                          await bookToBankAccount(snapshot.data!, context);
                          setState(() {
                            loading = false;
                          });
                        },
                        text: "Book to my Bank-Account"),
                  ]
                ],
              ],
            );
          }),
    );
  }
}
