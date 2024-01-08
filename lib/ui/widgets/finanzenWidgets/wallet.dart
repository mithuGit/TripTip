import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Wallet extends StatelessWidget {
  final DocumentReference user;
  final double balance;
  const Wallet({required this.user, required this.balance, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text("Kontostand: $balance"),
          ElevatedButton(
            onPressed: () {
              user.update({"balance": balance + 100});
            },
            child: Text("100€ aufladen"),
          ),
        ],
      ),
    );
  }
}