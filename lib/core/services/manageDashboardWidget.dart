import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ManageDashboardWidged {
  var uuid = const Uuid();
  var firestore = FirebaseFirestore.instance;
  Future<void> addWidget({required DocumentReference day, required DocumentReference user,
      required Map<String, dynamic> data, String? key}) async {
    Map<String, dynamic> dayData =
        (await day.get()).data() as Map<String, dynamic>;
    List<dynamic> widgets =
        dayData['active'].entries?.map((entry) => entry.value)?.toList();
    int length = widgets.length;
    data['key'] = key ?? uuid.v4();
    data['index'] = length;
    data['createdAt'] = DateTime.now();
    data['createdBy'] = user;
    widgets.add(data);
    Map<int, dynamic>? res = widgets?.asMap();
    res?.forEach((key, value) {
      value['index'] = key;
    });
    Map<String, dynamic>? res2 = res?.map((key, value) {
      return MapEntry(value["key"] as String, value);
    });

    await day.update({'active': res2});
  }

  Future<void> updateWidget(DocumentReference day, DocumentReference user,
      Map<String, dynamic> data, String key) async {
    Map<String, dynamic> dayData =
        (await day.get()).data() as Map<String, dynamic>;
    Map<String, dynamic> widget;

    // the widget is in the active list
    if (dayData['active'][key] != null) {
      widget = dayData['active'][key];
      // update each given value
      for (var item in data.entries) {
        widget[item.key] = item.value;
      }
      if (widget['modified'] == null) {
        widget['modified'] = List<Map<String, dynamic>>.empty(growable: true);
        widget['modified'].add({'when': DateTime.now(), 'by': user});
      } else {
        widget['modified'].add({'when': DateTime.now(), 'by': user});
      }

      Map<String, dynamic> widgets = dayData['active'];
      widgets[key] = widget;
      await day.update({'active': widgets});
      // the widget is in the archive list
    } else if (dayData['archive'][key] != null) {
      widget = dayData['archive'][key];
      // update each given value
      for (var item in data.entries) {
        widget[item.key] = item.value;
      }
      if (widget['modified'] == null) {
        widget['modified'] = List<Map<String, dynamic>>.empty(growable: true);
        widget['modified'].add({'when': DateTime.now(), 'by': user});
      } else {
        widget['modified'].add({'when': DateTime.now(), 'by': user});
      }

      Map<String, dynamic> widgets = dayData['archive'];
      widgets[key] = widget;
      await day.update({'archive': widgets});
    } else {
      throw Exception("Widget not found");
    }
  }

  Future<DocumentReference> addSurveyNotificationTask(DocumentReference day,
      DocumentReference user, Map<String, dynamic> data, String key) {
    return firestore.collection("tasks").add(data);
  }
}
