// ignore_for_file: file_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

// Class for showing error messages
class ErrorSnackbar {
  static Future<void> showErrorSnackbar(
      BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        errorMessage,
        style: Styles.errorSnackbar,
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      //  margin: const EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    ));
    return Future.delayed(const Duration(seconds: 1), () {});
  }

  static void showMessage(String message, BuildContext context, int counter,
      {bool forDeleteButton = false}) {
    Completer<bool> dialogCompleter = Completer<bool>();

    showDialog(
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Colors.black,
            title: Center(
              child: Text(
                message,
                style: Styles.textfieldHintStyle,
              ),
            ),
          ),
        );
      },
    ).then((_) {
      if (!dialogCompleter.isCompleted) {
        dialogCompleter.complete(true);
      }
    });

    // If the counter is 3, the user is redirected to the login page or the profile page
    if (counter == 3) {
      counter = 0;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                  body: WebViewPlus(
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (controller) {
                      controller.loadUrl("assets/capcha.html");
                    },
                    javascriptChannels: {
                      JavascriptChannel(
                          name: 'Captcha',
                          onMessageReceived: (JavascriptMessage message) {
                            if (forDeleteButton) {
                              context.pushReplacement('/profile');
                            } else {
                              context.pushReplacement('/loginOrRegister');
                            }
                          })
                    },
                  ),
                )),
      );
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (!dialogCompleter.isCompleted) {
          context.pop(); 
          dialogCompleter.complete(true);
        }
      });
    }
  }
}
