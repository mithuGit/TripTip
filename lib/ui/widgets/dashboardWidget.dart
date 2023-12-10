import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class DashboardWidget extends StatefulWidget {
  double elevation = 0;
  final String title;
  DashboardWidget({super.key, double? elevation, required this.title});
  

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool wiggel = false;

  /* @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _animation = Tween(begin: -0.1, end: 0.1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  } */

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(34.4),
      ),
      color: const Color(0xE51E1E1E),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  super.widget.title,
                  textAlign: TextAlign.left,
                  style: Styles.dashboardWidgetTitle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
