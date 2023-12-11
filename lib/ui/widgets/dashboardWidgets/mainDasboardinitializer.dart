import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/simpleNoteWidget.dart';

class MainDasboardinitializer extends StatefulWidget {
  double elevation = 0;
  final String title;
  Stream<Map<String, dynamic>> data;
  MainDasboardinitializer(
      {super.key, double? elevation, required this.title, required this.data});
  @override
  State<MainDasboardinitializer> createState() =>
      _MainDasboardinitializerState();
}

class _MainDasboardinitializerState extends State<MainDasboardinitializer> {
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: widget.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(34.4),
        ),
        color: const Color(0xE51E1E1E),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    super.widget.title,
                    textAlign: TextAlign.left,
                    style: Styles.mainDasboardinitializerTitle,
                  ),
                 
                ],
              ),
               StreamBuilder<Map<String, dynamic>>(
                    stream: widget.data,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if(snapshot.data!["type"] == "note") {
                          if(snapshot.data!["content"] == null) {
                            return Text("no content");
                          } else {
                            return SimpleNoteWidget(data : snapshot!.data);
                          }
                        } else if(snapshot.data!["type"] == "list") {
                          return SimpleNoteWidget(data : snapshot!.data);
                        } else {
                          return Text("no type is s");
                        }
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
            ],
          ),
        ));
  }
}
