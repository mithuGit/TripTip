import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidget.dart';

class ScrollViewWidget extends StatefulWidget {
  final DocumentReference? day;
  const ScrollViewWidget({super.key, required this.day});

  @override
  State<ScrollViewWidget> createState() => _ScrollViewWidget();
}

class _ScrollViewWidget extends State<ScrollViewWidget> {
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final Stream<DocumentSnapshot> _dayStream =
        firestore.collection('days').doc(widget.day?.id).snapshots();
    final Color oddItemColor = Colors.lime.shade100;
    final Color evenItemColor = Colors.deepPurple.shade100;

    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double elevation = lerpDouble(1, 6, animValue)!;
          final double scale = lerpDouble(1, 1.02, animValue)!;
          return Transform.scale(
            scale: scale,
            // Create a Card based on the color and the content of the dragged one
            // and set its elevation to the animated value.
            child: DashboardWidget(
              key: Key('$index'),
              elevation: elevation,
              title: 'Card: $index',
            ),
          );
        },
        child: child,
      );
    }

    return StreamBuilder<DocumentSnapshot>(
        stream: _dayStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          print(snapshot);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }
          List<dynamic> currentArray = snapshot.data!.get('widgets') ?? [];
          return ReorderableListView(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                // final int item = _items.removeAt(oldIndex);
                // _items.insert(newIndex, item);
              });
            },
            children: currentArray
                .map((widget) {
                  return DashboardWidget(
                      key: Key(widget!.hashCode.toString()),
                      title: widget!["title"] as String);
                })
                .toList()
                .cast(),
          );

          /*  

     List<DashboardWidget> cards = <DashboardWidget>[
      for (int index = 0; index < _items.length; index += 1)
        DashboardWidget(key: Key('$index'), title: 'Card: $index')
    ];
    
     padding: const EdgeInsets.symmetric(horizontal: 23),
      proxyDecorator: proxyDecorator,
      buildDefaultDragHandles: true,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final int item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
        });
      },
      children: cards, */
        });
  }
}
