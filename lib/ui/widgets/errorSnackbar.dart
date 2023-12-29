import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/login_or_register_page.dart';
import 'package:internet_praktikum/ui/views/profile/profile.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

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
      // Dialog wurde geschlossen, entweder durch Zurück-Taste oder automatisch nach 3 Sekunden
      if (!dialogCompleter.isCompleted) {
        dialogCompleter.complete(true);
      }
    });

    // Wenn Counter gleich 3 ist, wird eigentlich hier Capcha aufgerufen
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
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => forDeleteButton
                                        ? ProfilePage()
                                        : const LoginOrRegisterPage()));
                          })
                    },
                  ),
                )),
      );
    } else {
      // Verzögere das Ausblenden der Fehlermeldung nach 2 Sekunden
      Future.delayed(const Duration(seconds: 2), () {
        if (!dialogCompleter.isCompleted) {
          context.pop(); // Schließt den Dialog nach 2 Sekunden
          dialogCompleter.complete(true);
        }
      });
    }
  }
}
