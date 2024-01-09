import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:internet_praktikum/core/services/paymentsHandeler.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

class Wallet extends StatefulWidget {
  final DocumentSnapshot user;
  final double balance;
  const Wallet({required this.user, required this.balance, super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  Future<void> recharge() async {
    await PaymentsHandeler().refund(widget.user);
  }

  Future<void> bookToBankAccount() async {}
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34.5),
          color: const Color(0xE51E1E1E)),
      padding: const EdgeInsets.all(20),
      child: Column(
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
          Text(
            "${widget.balance} €",
            style: TextStyle(
                fontSize: 40,
                color: widget.balance < 0 ? Colors.red : Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: "Ubuntu"),
            textAlign: TextAlign.left,
          ),
          const SizedBox(
            height: 30,
          ),
          if (widget.balance < 0) ...[
            MyButton(
                onTap: () => recharge().onError((error, stackTrace) =>
                debugPrint(error.toString())),
                text: "Recharge"),
          ] else ...[
            MyButton(onTap: recharge, text: "Book to my Bank-Account"),
          ]
        ],
      ),
    );
  }
}
