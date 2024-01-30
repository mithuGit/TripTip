import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/JobworkerService.dart';
import 'package:internet_praktikum/core/services/updateWidgetListeners.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/mainDasboardinitializer.dart';
import 'package:internet_praktikum/ui/widgets/listSlidAble.dart';

// This class is used to display the widgets on the dashboard
// ignore: must_be_immutable
class ScrollViewWidget extends StatelessWidget {
  final bool isEditable;
  final DocumentReference day;
  final Map<String, dynamic> userdata;
  ScrollViewWidget(
      {super.key,
      required this.day,
      required this.userdata,
      required this.isEditable});
  List<dynamic>? bufferArray = List.empty();
  bool justChangged = false;

  @override
  Widget build(BuildContext context) {
    final StreamController<List<dynamic>> dayStreamFiltered =
        StreamController<List<dynamic>>();
    // We need this extra stream to filter the data from the database. When widgets are moved on the dashboard, the strean wont update
    //this is needed to prevent the widgets from jumping back to their old position
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

          // The widgets are sorted by their index, since they are stored in a map, the order is not guaranteed
          localbufferArray
              .sort((a, b) => (a['index'] as int).compareTo(b['index'] as int));
          // We need to get the user data for every widget, so we can display the profile picture and the name of the creator.
          //We cant do this in the dedicated widgets because of performance issues and blinking
          for (var i = 0; i < localbufferArray.length; i++) {
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
              } else {
                localbufferArray[i]["prename"] = "Deleted User";
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
    // This widget is drawed when a widget is dragged
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
          if (isEditable) {
            return Expanded(
              child: ReorderableListView(
                buildDefaultDragHandles: true,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                proxyDecorator: proxyDecorator,
                // whe the user stops dragging, the order of the widgets is updated
                onReorder: (int oldIndex, int newIndex) {
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
                  //update the database
                  day.update({"active": res2});
                },
                children: bufferArray!
                    .map((con) {
                      // the Slidable widget is used to display the edit and delete buttons
                      return ListSlidAble(
                        key: Key(con.hashCode.toString()),
                        onEdit: con["dontEdit"] == null ? (_) {
                          UpdateWidgetListeners().updateWidget(
                            con["key"],
                            con!,
                            day,
                            userdata,
                            context,
                          );
                        } : null,
                        onDelete: con["dontDelete"] == null ? (_) async {
                              Map<String, dynamic> archive =
                                    ((await day.get()).data()
                                        as Map<String, dynamic>)['archive'];
                                // Delete every corresponding worker
                                if (con["workers"] != null) {
                                  List<DocumentReference>? workers =
                                      (con["workers"] as List)
                                          .map((e) => e as DocumentReference)
                                          .toList();
                                  await JobworkerService.deleteAllWorkers(
                                      workers);
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
                        } : null,
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
          } else {
            // this is on the dashboard if the dashboard is not editable, since it is in the past
            return Expanded(
                child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 23),
              children: bufferArray!
                  .map((con) {
                    return MainDasboardinitializer(
                        title: con!["title"],
                        isEditable: false,
                        userdata: userdata,
                        day: day,
                        data: con);
                  })
                  .toList()
                  .cast(),
            ));
          }
        });
  }
}
