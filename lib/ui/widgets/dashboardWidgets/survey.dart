import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/widgetContainer.dart';

class SurveyWidget extends StatefulWidget {
  final String title;
  final List<Widget>? children;

  const SurveyWidget(
      {super.key,
      required this.title,
      this.children});

  @override
  State<SurveyWidget> createState() => _SurveyWidgetState();
}

class _SurveyWidgetState extends State<SurveyWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 18,
        right: 18,
      ),
      child: WidgetContainer(
        title: widget.title,
        isSurvey: true,
        children: [
          for (var child in widget.children!) 
            child,
            const SizedBox(height: 2,),  
        ],
      ),
    );
  }
}
