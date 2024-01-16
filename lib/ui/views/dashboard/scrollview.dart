import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/JobworkerService.dart';
import 'package:internet_praktikum/core/services/updateWidgetListeners.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/mainDasboardinitializer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ScrollViewWidget extends StatelessWidget {
  final DocumentReference day;
  final Map<String, dynamic> userdata;
  ScrollViewWidget({super.key, required this.day, required this.userdata});
  List<dynamic>? bufferArray = List.empty();
  bool justChangged = false;

  @override
  Widget build(BuildContext context) {
    final StreamController<List<dynamic>> dayStreamFiltered =
        StreamController<List<dynamic>>();
    day.snapshots().listen((event) async {
      try {
        debugPrint("Stream got Data");
        if (justChangged) {
          justChangged = false;
        } else {
          Map<String, dynamic> buffer =
              await event.get('active') as Map<String, dynamic>;
          List<dynamic> localbufferArray =
              buffer.entries.map((entry) => entry.value).toList();

          localbufferArray
              .sort((a, b) => (a['index'] as int).compareTo(b['index'] as int));
          for (var i = 0; i < localbufferArray!.length; i++) {
            if (localbufferArray[i]["createdBy"] != null) {
              DocumentSnapshot userdoc =
                  await localbufferArray[i]["createdBy"].get();
              if (userdoc.exists) {
                Map<String, dynamic> userdata =
                    userdoc.data() as Map<String, dynamic>;
                localbufferArray[i]["profilePicture"] =
                    userdata["profilePicture"];
                localbufferArray[i]["prename"] = userdata["prename"];
                localbufferArray[i]["lastname"] = userdata["lastname"];
              }
            }
          }
          dayStreamFiltered.add(localbufferArray);
        }
      } catch (e) {
        debugPrint(e.toString());
        dayStreamFiltered.addError(e);
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
            child: MainDasboardinitializer(
              key: Key('$index'),
              userdata: userdata,
              day: day,
              title: bufferArray![index]["title"] as String,
              data: bufferArray![index],
            ), // or any other fallback widget
          );
        },
        child: child,
      );
    }

    return StreamBuilder<List<dynamic>>(
        stream: dayStreamFiltered.stream,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          bufferArray = snapshot.data;
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return const Text(
              "No Widgets yet, press + to add one!",
              style: Styles.listviewNoContente,
            );
          }
          debugPrint("Container is editable");
          return Expanded(
            child: ReorderableListView(
              buildDefaultDragHandles: true,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 23),
              proxyDecorator: proxyDecorator,
              onReorder: (int oldIndex, int newIndex) {
                debugPrint("Reorder");
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                Map<String, dynamic> item = bufferArray?.removeAt(oldIndex);
                bufferArray?.insert(newIndex, item);
                dayStreamFiltered.add(bufferArray!);

                Map<int, dynamic>? res = bufferArray?.asMap();
                res?.forEach((key, value) {
                  value['index'] = key;
                });
                Map<String, dynamic>? res2 = res?.map((key, value) {
                  return MapEntry(value["key"] as String, value);
                });
                justChangged = true;
                //umschreibem
                day!.update({"active": res2});
              },
              children: bufferArray!
                  .map((con) {
                    return Slidable(
                      key: Key(con.hashCode.toString()),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        // if you shhoud use a left pane, use this:
                        //    dismissible: DismissiblePane(onDismissed: () {}),
                        children: [
                          if (con["dontEdit"] == null)
                            SlidableAction(
                              onPressed: (sdf) {
                                UpdateWidgetListeners().updateWidget(
                                  con["key"],
                                  con!,
                                  day!,
                                  userdata!,
                                  context,
                                );
                              },
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.blue,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                          if (con["dontDelete"] == null)
                            SlidableAction(
                              onPressed: (s) async {
                                Map<String, dynamic> archive =
                                    ((await day.get()).data()
                                        as Map<String, dynamic>)['archive'];

                                // Delete every corresponding worker

                                if (con["workers"] != null) {
                                  List<DocumentReference>? workers =
                                      (con["workers"] as List)
                                          .map((e) => e as DocumentReference)
                                          .toList();
                                  await JobworkerService.deleteAllWorkers(workers);
                                }

                                archive[con["key"]] = con;
                                List<dynamic>? tempArray = bufferArray;
                                tempArray?.remove(con);
                                dayStreamFiltered.add(tempArray!);
                                Map<int, dynamic>? res = tempArray.asMap();
                                res.forEach((key, value) {
                                  value['index'] = key;
                                });
                                Map<String, dynamic>? res2 =
                                    res.map((key, value) {
                                  return MapEntry(
                                      value["key"] as String, value);
                                });
                                //move Widget to Archive part
                                day.update(
                                    {"active": res2, "archive": archive});
                                justChangged = true;
                              },
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.red,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          if (con["dontDelete"] != null)
                            SlidableAction(
                              onPressed: (s) async {},
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.red,
                              label: "Can't delete this",
                            ),
                        ],
                      ),
                      child: MainDasboardinitializer(
                          title: con!["title"],
                          userdata: userdata,
                          day: day,
                          data: con),
                    );
                  })
                  .toList()
                  .cast(),
            ),
          );
        });
  }
}
