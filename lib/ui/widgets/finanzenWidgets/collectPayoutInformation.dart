import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';

/*
 This Class is used to collect the payout information from the user
*/

class CollectPayoutInformation extends StatefulWidget {
  final DocumentSnapshot user;
  const CollectPayoutInformation({super.key, required this.user});
  @override
  CollectPayoutInformationState createState() =>
      CollectPayoutInformationState();
}

class CollectPayoutInformationState extends State<CollectPayoutInformation> {
  TextEditingController ibanController = TextEditingController();
  String iban = "";
  String bic = "";
  String name = "";
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> data = widget.user.data() as Map<String, dynamic>;
    if (data["payoutInformation"] != null) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputField(
          hintText: "IBAN",
          controller: ibanController,
          obscureText: false, 
        ),
      ],
    );
  }
}
