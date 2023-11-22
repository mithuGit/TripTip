import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/placeApiProvider.dart';
import 'package:uuid/uuid.dart';

const Duration fakeAPIDuration = Duration(seconds: 1);

class AsyncAutocomplete extends StatefulWidget {
  const AsyncAutocomplete();

  @override
  State<AsyncAutocomplete> createState() => _AsyncAutocompleteState();
}

class _AsyncAutocompleteState extends State<AsyncAutocomplete> {
  String? _searchingWithQuery;
  late Iterable<String> _lastOptions = <String>[];

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        _searchingWithQuery = textEditingValue.text;

        if (_searchingWithQuery != '') {
          PlaceApiProvider placeApiProvider =
              PlaceApiProvider(const Uuid().v4());
          final Iterable<String> options =
              await placeApiProvider.fetchSuggestions(_searchingWithQuery!);
          if (_searchingWithQuery != textEditingValue.text) {
            return _lastOptions;
          }
          _lastOptions = options;
          return options;
        } else {
          return _lastOptions;
        }
      },
      onSelected: (String selection) {
        debugPrint('You just selected $selection');
      },
    );
  }
}
