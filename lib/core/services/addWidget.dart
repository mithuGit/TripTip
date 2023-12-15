import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AddWidget {
  var uuid = const Uuid();
  Future<void> addWidget(DocumentReference day, DocumentReference editor,
      Map<String, dynamic> data) async {
    Map<String, dynamic> dayData =
        (await day.get()).data() as Map<String, dynamic>;
    List<dynamic> widgets =
        dayData['active'].entries?.map((entry) => entry.value)?.toList();
    int length = widgets.length;
    data['key'] = uuid.v4();
    data['index'] = length;
    data['editor'] = editor;
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
}
