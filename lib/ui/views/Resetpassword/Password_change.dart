import 'package:flutter/material.dart';

import '../../widgets/my_button.dart';


class PasswordChange extends StatelessWidget {
  const PasswordChange({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _confirmPasswordController =
        TextEditingController();

    String errorText = ''; // Fehlermeldung für die Anzeige

    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                errorText: errorText,
                errorStyle:
                    const TextStyle(color: Colors.red), // Fehlerstil auf Rot setzen
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                errorText: errorText,
                errorStyle:
                    TextStyle(color: Colors.red), // Fehlerstil auf Rot setzen
              ),
            ),
            SizedBox(height: 24),
            MyButton(
              text: 'Confirm',
              onTap: () {
                String newPassword = _passwordController.text;
                String confirmPassword = _confirmPasswordController.text;

                if (newPassword == confirmPassword) {
                  // Passwörter stimmen überein, hier kannst du die Logik zum Speichern des Passworts hinzufügen
                  showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Congratulations!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              const Text(
                                  'Your password has been successfully changed.'),
                              SizedBox(height: 16),
                              MyButton(
                                text: 'Close',
                                onTap: () {
                                  Navigator.pop(
                                      context); // Schließt das Bottom Sheet
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  // Passwörter stimmen nicht überein, zeige eine Fehlermeldung
                  errorText = 'Passwords do not match';
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Passwords do not match',
                        style: TextStyle(
                            color: Colors.white), // Textfarbe auf Weiß setzen
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor:
                          Colors.red, // Hintergrundfarbe auf Rot setzen
                    ),
                  );
                  print('Passwords do not match');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
