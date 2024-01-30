// ignore: file_names
import 'package:flutter/material.dart';

class ExpansionTileWidget extends StatelessWidget {
  final List<Widget> children;
  final String title;
  const ExpansionTileWidget(
      {super.key, required this.children, required this.title});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      collapsedBackgroundColor: const Color(0xE51E1E1E),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(34.5),
      ),
      backgroundColor: const Color(0xE51E1E1E),
      initiallyExpanded: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(34.5),
      ),
      iconColor: Colors.white,
      childrenPadding: const EdgeInsets.only(left: 10, right: 10, bottom: 8),
      collapsedIconColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(
            fontFamily: 'Ubuntu',
            color: Colors.white,
            fontWeight: FontWeight.normal),
      ),
      children: [...children],
    );
  }
}
