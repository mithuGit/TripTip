// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/paymentsHandeler.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

/*
 This Class is used to collect the payout information from the user
*/
// ignore: non_constant_identifier_names
Map<String, int> CODE_LENGTHS = {
  'AD': 24,
  'AE': 23,
  'AT': 20,
  'AZ': 28,
  'BA': 20,
  'BE': 16,
  'BG': 22,
  'BH': 22,
  'BR': 29,
  'CH': 21,
  'CR': 21,
  'CY': 28,
  'CZ': 24,
  'DE': 22,
  'DK': 18,
  'DO': 28,
  'EE': 20,
  'ES': 24,
  'FI': 18,
  'FO': 18,
  'FR': 27,
  'GB': 22,
  'GI': 23,
  'GL': 18,
  'GR': 27,
  'GT': 28,
  'HR': 21,
  'HU': 28,
  'IE': 22,
  'IL': 23,
  'IS': 26,
  'IT': 27,
  'JO': 30,
  'KW': 30,
  'KZ': 20,
  'LB': 28,
  'LI': 21,
  'LT': 20,
  'LU': 20,
  'LV': 21,
  'MC': 27,
  'MD': 24,
  'ME': 22,
  'MK': 19,
  'MR': 27,
  'MT': 31,
  'MU': 30,
  'NL': 18,
  'NO': 15,
  'PK': 24,
  'PL': 28,
  'PS': 29,
  'PT': 25,
  'QA': 29,
  'RO': 24,
  'RS': 22,
  'SA': 24,
  'SE': 24,
  'SI': 19,
  'SK': 24,
  'SM': 27,
  'TN': 24,
  'TR': 26,
  'AL': 28,
  'BY': 28,
  'EG': 29,
  'GE': 22,
  'IQ': 23,
  'LC': 32,
  'SC': 31,
  'ST': 25,
  'SV': 28,
  'TL': 23,
  'UA': 29,
  'VA': 22,
  'VG': 24,
  'XK': 20
};

bool isValidIBANNumber(String input) {
  String iban = input.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'), ''); // keep only alphanumeric characters
  RegExpMatch? code = RegExp(r'^([A-Z]{2})(\d{2})([A-Z\d]+)$').firstMatch(
      iban); // match and capture (1) the country code, (2) the check digits, and (3) the rest
  String digits;
  // check syntax and length
  if (code == null || iban.length != CODE_LENGTHS[code[1]!]) {
    return false;
  }
  digits = (code[3]! + code[1]! + code[2]!).replaceAllMapped(RegExp(r'[A-Z]'),
      (match) {
    return (match.group(0)!.codeUnitAt(0) - 55).toString();
  });
  return checkChecksum(digits, CODE_LENGTHS[code[1]!]!);
}

bool checkChecksum(String string, int lenght) {
  BigInt withNullen = BigInt.parse('${string.substring(0, lenght)}00');
  BigInt checksum = BigInt.from(98) - (withNullen % BigInt.from(97));
  return checksum ==
      BigInt.parse(string.substring(string.length - 2, string.length));
}

class CollectPayoutInformation extends StatefulWidget {
  final DocumentSnapshot user;
  final bool bookToBankAccount;
  const CollectPayoutInformation(
      {super.key, required this.user, this.bookToBankAccount = false});
  @override
  CollectPayoutInformationState createState() =>
      CollectPayoutInformationState();
}

class CollectPayoutInformationState extends State<CollectPayoutInformation> {
  TextEditingController ibanController = TextEditingController();
  TextEditingController bicController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> data = widget.user.data() as Map<String, dynamic>;
    if (data["payoutInformation"] != null) {
      if (data["payoutInformation"]["iban"] != null) {
        ibanController.text = data["payoutInformation"]["iban"];
      }
      if (data["payoutInformation"]["bic"] != null) {
        bicController.text = data["payoutInformation"]["bic"];
      }
      if (data["payoutInformation"]["accountHolderName"] != null) {
        nameController.text = data["payoutInformation"]["accountHolderName"];
      }
    }
  }

  Future<void> savePayoutInformation() async {
    setState(() {
      loading = true;
    });
    if (ibanController.text.isEmpty ||
        bicController.text.isEmpty ||
        nameController.text.isEmpty) {
      throw "Please fill in all fields";
    }
    if(!isValidIBANNumber(ibanController.text)){
      throw "Please enter a valid IBAN";
    }

    await widget.user.reference.update({
      "payoutInformation": {
        "iban": ibanController.text,
        "bic": bicController.text,
        "accountHolderName": nameController.text,
      }
    });
    
    if (widget.bookToBankAccount) {
      DocumentSnapshot user = await widget.user.reference.get();
      await PaymentsHandeler.bookToBankAccount(user);
    }
    if (context.mounted) Navigator.pop(context);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputField(
          hintText: "Name of Account Holder",
          controller: nameController,
          borderColor: Colors.grey,
          obscureText: false,
        ),
        const SizedBox(height: 10),
        InputField(
          hintText: "IBAN",
          controller: ibanController,
          borderColor: Colors.grey,
          obscureText: false,
          validator: (p0) {
            if (p0!.isEmpty) {
              return "Please enter your IBAN";
            }
            if (!isValidIBANNumber(p0)) {
              return "Please enter a valid IBAN";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        InputField(
          hintText: "BIC",
          controller: bicController,
          borderColor: Colors.grey,
          obscureText: false,
        ),
        const SizedBox(height: 20),
        loading
            ? const CircularProgressIndicator(color: Colors.black,)
            :
        MyButton(
          onTap: () => savePayoutInformation().onError((error, stackTrace) =>
              ErrorSnackbar.showErrorSnackbar(context, error.toString())),
          text: "Save",
          borderColor: Colors.black,
          textStyle: Styles.buttonFontStyleModal,
        )
      ],
    );
  }
}
