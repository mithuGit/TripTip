import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidget.dart';
import 'package:rxdart/rxdart.dart';


class EditableStreamFirebaseDatastream {
  final bool boolValue;
  final DocumentSnapshot firestoreSnapshot;
  EditableStreamFirebaseDatastream(this.boolValue, this.firestoreSnapshot);
}

class ScrollViewWidget extends StatefulWidget {
  final DocumentReference? day;
  const ScrollViewWidget({super.key, required this.day});

  @override
  State<ScrollViewWidget> createState() => _ScrollViewWidget();
}

class _ScrollViewWidget extends State<ScrollViewWidget> {
  List<dynamic> newArray = List.empty();
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final Stream<DocumentSnapshot> _dayStream =
        firestore.collection('days').doc(widget.day?.id).snapshots();
    _dayStream.listen((event) {
      newArray = event.get('widgets');
    });
    final StreamController<bool> _editableStream = StreamController<bool>();
    _editableStream.add(false);

    final mergedStream = CombineLatestStream.combine2<bool,DocumentSnapshot, EditableStreamFirebaseDatastream>(
    _editableStream.stream,
    _dayStream,
    (boolValue, snapshot) => EditableStreamFirebaseDatastream(boolValue, snapshot)
  );

    final Color oddItemColor = Colors.lime.shade100;
    final Color evenItemColor = Colors.deepPurple.shade100;
    List<dynamic> bufferArray = List.empty();
    int movingIndex = 0; // The index of the card that is currently moving

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
              title: bufferArray[index]["title"] as String,
              key: Key('$index'),
            ),
          );
        },
        child: child,
      );
    }

    return StreamBuilder<EditableStreamFirebaseDatastream>(
        stream: mergedStream,
        builder:
            (BuildContext context, AsyncSnapshot<EditableStreamFirebaseDatastream> snapshot) {
          final bool _editable = snapshot.data?.boolValue ?? false;
          final DocumentSnapshot? firestoreSnapshot = snapshot.data?.firestoreSnapshot;    
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            if (bufferArray.isEmpty) {
              return const Text("Loading");
            }
            return ListView(
              children: bufferArray
                  .map((con) {
                    return DashboardWidget(
                        key: Key(con!.hashCode.toString()),
                        title: con!["title"] as String);
                  })
                  .toList()
                  .cast(),
            );
          }

          List<dynamic> currentArray = firestoreSnapshot?.get('widgets') ?? [];
          bufferArray = currentArray;

          if (_editable) {
            return Container(
              margin: const EdgeInsets.only(
                  bottom: 65), // 65 because of the bottom navigation bar
              child: ReorderableListView(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                proxyDecorator: proxyDecorator,
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    movingIndex = oldIndex;
                    Map<String, dynamic> item = bufferArray.removeAt(oldIndex);
                    bufferArray.insert(newIndex, item);
                    firestore
                        .collection('days')
                        .doc(widget.day?.id)
                        .set({"widgets": bufferArray});
                  });
                },
                children: bufferArray
                    .map((con) {
                      return DashboardWidget(
                          key: Key(con!.hashCode.toString()),
                          title: con!["title"] as String);
                    })
                    .toList()
                    .cast(),
              ),
            );
          } else {
            return Container(
              margin: const EdgeInsets.only(
                  bottom: 65), // 65 because of the bottom navigation bar
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                children: bufferArray
                    .map((con) {
                      return GestureDetector(
                        onLongPress: () {
                          setState(() {
                            _editableStream.add(true);
                          });
                        },
                        child: DashboardWidget(
                            key: Key(con!.hashCode.toString()),
                            title: con!["title"] as String),
                      );
                    })
                    .toList()
                    .cast(),
              ),
            );
          }
        });
  }
}
