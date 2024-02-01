import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/paymentsHandeler.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/paymentsWidgets/collectPayoutInformation.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

// class to display the wallet of the user
class Wallet extends StatefulWidget {
  final DocumentSnapshot userdata;
  const Wallet({required this.userdata, super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  bool loading = false;
  // Recharge the wallet of the user
  Future<void> recharge(DocumentSnapshot user, BuildContext context) async {
    try {
      await PaymentsHandeler.refund(user);
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.showErrorSnackbar(context, e.toString());
      }
    }
  }

// Book the money from the wallet to the bank account of the user
  Future<void> bookToBankAccount(
      DocumentSnapshot user, BuildContext context) async {
    try {
      await PaymentsHandeler.bookToBankAccount(user);
    } on NoPayOutinformation {
      if (mounted) {
        CustomBottomSheet.show(context,
            title: "Fill in your Back-Account",
            content: [
              CollectPayoutInformation(user: user, bookToBankAccount: true)
            ]);
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
      child: LayoutBuilder(builder: (context, snapshot) {
        double balance = 0.0;
        Map<String, dynamic> userObj =
            widget.userdata.data() as Map<String, dynamic>;
        if (userObj.containsKey("balance")) {
          balance = userObj["balance"] * 1.0;
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
              )
            ] else
              Text(
                //    "${(balance).toStringAsFixed(2)} €",
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
                      await recharge(widget.userdata, context);
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
                      await bookToBankAccount(widget.userdata, context);
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
