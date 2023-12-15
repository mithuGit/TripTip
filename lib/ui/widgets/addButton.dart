import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;
  final Color color;

  const AddButton({
    Key? key,
    required this.onPressed,
    this.size = 40.0,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        Icons.add,
        size: size,
        color: Colors.white,
      ),
      color: color,
      iconSize: size,
    );
  }
}
