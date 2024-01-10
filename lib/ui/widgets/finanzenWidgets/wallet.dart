import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/paymentsHandeler.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

class Wallet extends StatefulWidget {
  final DocumentReference user;
  const Wallet({required this.user, super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  bool loading = false;
  Future<void> recharge(DocumentSnapshot user) async {
    await PaymentsHandeler().refund(user);
  }

  Future<void> bookToBankAccount() async {}
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
                child: Text("Error"),
              );
            }
            double balance = 0.0;
            try {
              balance =
                  (snapshot.data!.data() as Map<String, dynamic>)["balance"] *
                      1.0;
            } catch (e) {
              print(e);
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
                Text(
                  "${balance} €",
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
                          await recharge(snapshot.data!);
                          setState(() {
                            loading = false;
                          });
                        },
                        text: "Recharge"),
                  ] else ...[
                    MyButton(
                        onTap: () async {
                          setState(() {
                            loading = true;
                          });
                          await recharge(snapshot.data!);
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
