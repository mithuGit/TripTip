import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../styles/Styles.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final dynamic controller;
  final bool obscureText;
  final EdgeInsets? margin;
  final FocusNode? focusNode;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final bool? multiline;
  final bool? numberField;
  final String? Function(String?)? validator;

  const InputField(
      {super.key,
      required this.hintText,
      this.controller,
      required this.obscureText,
      this.margin,
      this.multiline,
      this.focusNode,
      this.borderColor,
      this.focusedBorderColor,
      this.numberField,
      this.validator});

  bool isValidEmail(String email) {
    String emailRegex =
        r'^[\w-]+(\.[\w-]+)*@([a-z\d-]+(\.[a-z\d-]+)*?\.[a-z]{2,6}|(\d{1,3}\.){3}\d{1,3})$';
    RegExp regex = RegExp(emailRegex);
    return regex.hasMatch(email);
  }

  bool isIban(String iban) {
    String ibanRegex = r'^[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}$';
    RegExp regex = RegExp(ibanRegex);
    return regex.hasMatch(iban);
  }

  /*
    function isValidIBANNumber(input) {
    var CODE_LENGTHS = {
        AD: 24, AE: 23, AT: 20, AZ: 28, BA: 20, BE: 16, BG: 22, BH: 22, BR: 29,
        CH: 21, CR: 21, CY: 28, CZ: 24, DE: 22, DK: 18, DO: 28, EE: 20, ES: 24,
        FI: 18, FO: 18, FR: 27, GB: 22, GI: 23, GL: 18, GR: 27, GT: 28, HR: 21,
        HU: 28, IE: 22, IL: 23, IS: 26, IT: 27, JO: 30, KW: 30, KZ: 20, LB: 28,
        LI: 21, LT: 20, LU: 20, LV: 21, MC: 27, MD: 24, ME: 22, MK: 19, MR: 27,
        MT: 31, MU: 30, NL: 18, NO: 15, PK: 24, PL: 28, PS: 29, PT: 25, QA: 29,
        RO: 24, RS: 22, SA: 24, SE: 24, SI: 19, SK: 24, SM: 27, TN: 24, TR: 26,   
        AL: 28, BY: 28, CR: 22, EG: 29, GE: 22, IQ: 23, LC: 32, SC: 31, ST: 25,
        SV: 28, TL: 23, UA: 29, VA: 22, VG: 24, XK: 20
    };
    var iban = String(input).toUpperCase().replace(/[^A-Z0-9]/g, ''), // keep only alphanumeric characters
            code = iban.match(/^([A-Z]{2})(\d{2})([A-Z\d]+)$/), // match and capture (1) the country code, (2) the check digits, and (3) the rest
            digits;
    // check syntax and length
    if (!code || iban.length !== CODE_LENGTHS[code[1]]) {
        return false;
    }
    // rearrange country code and check digits, and convert chars to ints
    digits = (code[3] + code[1] + code[2]).replace(/[A-Z]/g, function (letter) {
        return letter.charCodeAt(0) - 55;
    });
    // final check
    return mod97(digits) === 1;
}

function mod97(string) {
    var checksum = string.slice(0, 2), fragment;
    for (var offset = 2; offset < string.length; offset += 7) {
        fragment = String(checksum) + string.substring(offset, offset + 7);
        checksum = parseInt(fragment, 10) % 97;
    }
    return checksum;
}

  */

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (hintText == 'Email') {
            // Validierung für die E-Mail-Adresse
            if (value == null || value.isEmpty) {
              return 'Please enter a email adress';
            } else if (!isValidEmail(value)) {
              return 'Please enter an valid email adress';
            }
          }
          return null;
        },
        style: Styles.inputField,
        focusNode: focusNode,
        cursorColor: Colors.grey.shade400,
        cursorWidth: 1.5,
        maxLines: multiline == true ? 5 : 1,
        keyboardType: multiline == true
            ? TextInputType.multiline
            : numberField == true
                ? TextInputType.number
                : TextInputType.text,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: borderColor != null
                  ? BorderSide(color: borderColor!)
                  : const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(11.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: focusedBorderColor != null
                  ? BorderSide(color: focusedBorderColor!)
                  : BorderSide(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(11.0),
            ),
            fillColor: Colors.white,
            filled: true,
            contentPadding:
                const EdgeInsets.only(top: 16, bottom: 16, left: 14, right: 14),
            hintText: hintText,
            hintStyle: Styles.textfieldHintStyle),
      ),
    );
  }
}
