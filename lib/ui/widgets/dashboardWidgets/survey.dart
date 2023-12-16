import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/voting_poll.dart';

class SurveyWidget extends StatefulWidget {
  final Map<String, dynamic>? data;

  const SurveyWidget({super.key, this.data});

  @override
  State<SurveyWidget> createState() => _SurveyWidgetState();
}

class _SurveyWidgetState extends State<SurveyWidget> {
  @override
  Widget build(BuildContext context) {
    /*return WidgetContainer(
      title: widget.title,
      isSurvey: true,
      children: [
        for (var child in widget.children!) 
          child,
          const SizedBox(height: 2,),  
      ],
    );*/
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xE51E1E1E),
      ),
      child: Center(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (widget.data!["options"] != null)
              for (var child in widget.data!["options"]) child,
              const SizedBox(
                height: 2,
              ),
          ],
        ),
      )),
    );
  }
}
