import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/views/main_pages/dashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/mainDasboardinitializer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PressdEditButton extends ChangeNotifier {
  StreamController<bool> pressedStream = StreamController<bool>();
  get stream => pressedStream.stream;
  void emmitPress() {
    pressedStream.add(true);
    // notifyListeners();
  }
}

class ScrollViewWidget extends StatelessWidget {
  ScrollViewWidget({super.key});
  List<dynamic>? bufferArray = List.empty();
  bool justChangged = false;

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference<Object?>? day = context.watch<ProviderDay>().day;

    if (day == null) {
      return const CircularProgressIndicator();
    }
    Map<String, PressdEditButton> pressedEditButton = {};
    final Stream<DocumentSnapshot> _dayStream =
        firestore.collection('days').doc(day?.id).snapshots();

    final StreamController<List<dynamic>> dayStreamFiltered =
        StreamController<List<dynamic>>();
    _dayStream.listen((event) async {
      try {
        debugPrint("Stream got Data");
        if (justChangged) {
          justChangged = false;
        } else {
          Map<String, dynamic> buffer =
              await event.get('active') as Map<String, dynamic>;
          List<dynamic> localbufferArray =
              buffer.entries.map((entry) => entry.value).toList();

          if (localbufferArray != null) {
            localbufferArray?.sort(
                (a, b) => (a['index'] as int).compareTo(b['index'] as int));
          }
          for (var i = 0; i < localbufferArray!.length; i++) {
            DocumentSnapshot userdoc =
                await localbufferArray![i]["createdBy"].get();
            if (userdoc.exists) {
              Map<String, dynamic> userdata =
                  userdoc.data() as Map<String, dynamic>;
              localbufferArray![i]["profilePicture"] =
                  userdata["profilePicture"];
              localbufferArray![i]["prename"] = userdata["prename"];
              localbufferArray![i]["lastname"] = userdata["lastname"];
            }

            //Add for every widget a PressdEditButton that it can listen on changes
            pressedEditButton[localbufferArray![i]["key"]] = PressdEditButton();
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
          return Container(
            margin: const EdgeInsets.only(
                bottom: 65), // 65 because of the bottom navigation bar
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
                firestore
                    .collection('days')
                    .doc(day?.id)
                    .update({"active": res2});
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
                          SlidableAction(
                            onPressed: (sdf) {
                              pressedEditButton[con["key"]]?.emmitPress();
                            },
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.blue,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                          SlidableAction(
                            onPressed: (s) async {
                              debugPrint("Delete");
                              DocumentSnapshot archiveColl = await firestore
                                  .collection('days')
                                  .doc(day?.id)
                                  .get();
                              Map<String, dynamic> archive = archiveColl
                                  .get('archive') as Map<String, dynamic>;
                              archive[con["key"]] = con;
                              Map<String, dynamic> item = con;
                              List<dynamic>? tempArray = bufferArray;
                              tempArray?.remove(con);
                              dayStreamFiltered.add(tempArray!);
                              Map<int, dynamic>? res = tempArray?.asMap();
                              res?.forEach((key, value) {
                                value['index'] = key;
                              });
                              Map<String, dynamic>? res2 =
                                  res?.map((key, value) {
                                return MapEntry(value["key"] as String, value);
                              });
                              //umschreibem
                              firestore
                                  .collection('days')
                                  .doc(day?.id)
                                  .update({"active": res2, "archive": archive});
                              justChangged = true;
                            },
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.red,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: ChangeNotifierProvider<PressdEditButton>(
                        create: (_) => pressedEditButton[con["key"]]!,
                        child: MainDasboardinitializer(
                            title: con!["title"], data: con),
                      ),
                    );
                  })
                  .toList()
                  .cast(),
            ),
          );
        });
  }
}
