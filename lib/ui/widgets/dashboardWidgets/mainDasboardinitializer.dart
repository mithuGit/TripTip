import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/simpleNoteWidget.dart';
import 'package:provider/provider.dart';

class AddButton extends ChangeNotifier {
  bool _addButton = false;
  bool get addButton => _addButton;
  void setAddButton(bool value) {
    _addButton = value;
    notifyListeners();
  }
}

class MainDasboardinitializer extends StatefulWidget {
  double elevation = 0;
  final String title;
  Map<String, dynamic>? data;
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
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AddButton()),
          ],
          child: Container(
            padding:
                const EdgeInsets.only(top: 12, bottom: 12, left: 20, right: 12),
            child: Column(
              
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 25,
                      child: Text(
                        super.widget.title,
                        textAlign: TextAlign.left,
                        style: Styles.mainDasboardinitializerTitle,
                      ),
                    ),
                    if(widget.data?["addAble"] != null && widget.data?["addAble"] == true)
                    GestureDetector(
                      onTap: () {

                      },
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 40, 
                      ),
                    ),
                  ],
                ),
                LayoutBuilder(builder: (context, constraints) {
                  if (widget.data?["type"] == null) {
                    return const Text("No type is specified");
                  } else {
                    if (widget.data?["type"] == "note") {
                      return SimpleNoteWidget(data: widget.data);
                    } else if (widget.data?["type"] == "list") {
                      return SimpleNoteWidget(data: widget.data);
                    } else if(widget.data?["type" == "poll"]) {
                      return SimpleNoteWidget(data: widget.data);
                    } 
                    else {
                      return const Text("No type is specified");
                    }
                  }
                }),
              ],
            ),
          ),
        ));
  }
}
