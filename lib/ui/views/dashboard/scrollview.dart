import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/mainDasboardinitializer.dart';
import 'package:rxdart/rxdart.dart';

class EditableStreamFirebaseDatastream {
  final bool boolValue;
  final DocumentSnapshot firestoreSnapshot;
  EditableStreamFirebaseDatastream(this.boolValue, this.firestoreSnapshot);
}

class ScrollViewWidget extends StatelessWidget {
  final DocumentReference? day;
  ScrollViewWidget({super.key, required this.day});
  List<dynamic>? bufferArray = List.empty();

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final Stream<DocumentSnapshot> _dayStream =
        firestore.collection('days').doc(day?.id).snapshots();
    final StreamController<bool> _editableStream = StreamController<bool>();
    _editableStream.add(false);

    final mergedStream = CombineLatestStream.combine2<bool, DocumentSnapshot,
            EditableStreamFirebaseDatastream>(
        _editableStream.stream,
        _dayStream,
        (boolValue, snapshot) =>
            EditableStreamFirebaseDatastream(boolValue, snapshot));

    final Color oddItemColor = Colors.lime.shade100;
    final Color evenItemColor = Colors.deepPurple.shade100;

    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double scale = lerpDouble(1, 1.02, animValue)!;
          return Transform.scale(
            scale: scale,
            // Create a Card based on the color and the content of the dragged one
            // and set its elevation to the animated value.
            child: Dismissible(
              key: Key('$index'),
              child: MainDasboardinitializer(
                title: bufferArray![index]["title"] as String,
                data: bufferArray![index],
              ),
            ), // or any other fallback widget
          );
        },
        child: child,
      );
    }

    return StreamBuilder<EditableStreamFirebaseDatastream>(
        stream: mergedStream,
        builder: (BuildContext context,
            AsyncSnapshot<EditableStreamFirebaseDatastream> snapshot) {
          final DocumentSnapshot? firestoreSnapshot =
              snapshot.data?.firestoreSnapshot;
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }
          bufferArray =
              (firestoreSnapshot?.get('active') as Map<String, dynamic>)
                  .entries
                  ?.map((entry) => entry.value)
                  ?.toList();

          if (bufferArray != null) {
            bufferArray?.sort(
                (a, b) => (a['index'] as int).compareTo(b['index'] as int));
          }
          debugPrint("Container is editable");
          return Container(
            margin: const EdgeInsets.only(
                bottom: 65), // 65 because of the bottom navigation bar
            child: ReorderableListView(
              buildDefaultDragHandles: true,
              padding: const EdgeInsets.symmetric(horizontal: 23),
              proxyDecorator: proxyDecorator,
              onReorder: (int oldIndex, int newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                Map<String, dynamic> item = bufferArray?.removeAt(oldIndex);
                bufferArray?.insert(newIndex, item);
                Map<int, dynamic>? res = bufferArray?.asMap();
                res?.forEach((key, value) {
                  value['index'] = key;
                });
                Map<String, dynamic>? res2 = res?.map((key, value) {
                  return MapEntry(value["key"] as String, value);
                });
                //umschreibem
                firestore
                    .collection('days')
                    .doc(day?.id)
                    .update({"active": res2});
              },
              children: bufferArray!
                  .map((con) {
                    return Dismissible(
                      direction: DismissDirection.horizontal,
                      key: Key(con.hashCode.toString()),
                      onDismissed: (direction) {
                        Map<String, dynamic> archive = firestoreSnapshot!
                            .get('archive') as Map<String, dynamic>;
                        archive[con["key"]] = con;

                        Map<String, dynamic> item = con;
                        bufferArray?.remove(con);
                        Map<int, dynamic>? res = bufferArray?.asMap();
                        res?.forEach((key, value) {
                          value['index'] = key;
                        });
                        Map<String, dynamic>? res2 = res?.map((key, value) {
                          return MapEntry(value["key"] as String, value);
                        });
                        //umschreibem
                        firestore
                            .collection('days')
                            .doc(day?.id)
                            .update({"active": res2, "archive": archive});
                      },
                      child: MainDasboardinitializer(
                          title: con!["title"], data: con),
                    );
                  })
                  .toList()
                  .cast(),
            ),
          );
        });
  }
}
