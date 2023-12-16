import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChangeTrip extends StatefulWidget {
  const ChangeTrip({super.key});

  @override
  State<ChangeTrip> createState() => _ChangeTripState();
}

class _ChangeTripState extends State<ChangeTrip> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pushReplacement("/");
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Change Trip"),
      ),
      body: const Center(
        child: Text("Change Trip"),
      ),
    );
  }
}
