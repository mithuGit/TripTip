import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class DashboardWidget extends StatefulWidget {
  double elevation = 0;
  final String title;
  DashboardWidget({super.key, double? elevation, required this.title});
  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() {});
      },
      child: Card(
        elevation: widget.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(34.4),
        ),
        color: const Color(0xE51E1E1E),
        child: Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                super.widget.title,
                style: Styles.dashboardWidgetTitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
