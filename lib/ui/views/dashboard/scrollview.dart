import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/views/main_pages/dashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/mainDasboardinitializer.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ScrollViewWidget extends StatelessWidget {
  ScrollViewWidget({super.key});
  List<dynamic>? bufferArray = List.empty();
  bool justChangged = false;

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference<Object?>? day = context.watch<ProviderDay?>()?.day;
     if(day == null){
        return const CircularProgressIndicator();
    }
    final Stream<DocumentSnapshot> _dayStream =
        firestore.collection('days').doc(day?.id).snapshots();

    final StreamController<Map> _dayStreamFiltered = StreamController<Map>();
    _dayStream.listen((event) {
      debugPrint("Stream got Data");
      if (justChangged) {
        justChangged = false;
      } else {
        _dayStreamFiltered.add(event.get('active') as Map);
      }
    });
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

    return StreamBuilder<Map>(
        stream: _dayStreamFiltered.stream,
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          final Map? firestoreSnapshot = snapshot.data;
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }
          bufferArray =
              firestoreSnapshot?.entries?.map((entry) => entry.value)?.toList();

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
                debugPrint("Reorder");
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
                justChangged = true;
                _dayStreamFiltered.add(res2!);
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
                      onDismissed: (direction) async {
                        DocumentSnapshot archiveColl = await firestore
                            .collection('days')
                            .doc(day?.id)
                            .get();
                        Map<String, dynamic> archive =
                            archiveColl.get('archive') as Map<String, dynamic>;
                        archive[con["key"]] = con;
                        Map<String, dynamic> item = con;
                        List<dynamic>? tempArray = bufferArray;
                        tempArray?.remove(con);
                        Map<int, dynamic>? res = tempArray?.asMap();
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
                        justChangged = true;
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
