import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/placeApiProvider.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:uuid/uuid.dart';

const Duration fakeAPIDuration = Duration(seconds: 1);

class AsyncAutocomplete extends StatefulWidget {
  const AsyncAutocomplete();

  @override
  State<AsyncAutocomplete> createState() => _AsyncAutocompleteState();
}

class _AsyncAutocompleteState extends State<AsyncAutocomplete> {
  String? _searchingWithQuery;
  String? _lastsearching;
  late Iterable<String> _lastOptions = <String>[];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) => Autocomplete<String>(
              fieldViewBuilder: (BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted) {
                return InputField(
                    hintText: 'Destination',
                    obscureText: false,
                    focusNode: fieldFocusNode,
                    controller: fieldTextEditingController);
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    child: Container(
                      width: constraints.biggest.width,
                      color: Colors.white,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(2),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return GestureDetector(
                            onTap: () {
                              onSelected(option);
                            },
                            child: ListTile(
                              title:
                                  Text(option, style: Styles.textAutocomplete),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              optionsBuilder: (TextEditingValue textEditingValue) async {
                _searchingWithQuery = textEditingValue.text;
                
                if (_searchingWithQuery != '' && _searchingWithQuery != _lastsearching) {
                  PlaceApiProvider placeApiProvider =
                      PlaceApiProvider(const Uuid().v4());
                  final Iterable<String> options = await placeApiProvider
                      .fetchSuggestions(_searchingWithQuery!).catchError((error) => 
                        ErrorSnackbar.showErrorSnackbar(context);
                        return Iterable<String>.empty();
                      );
                  if (_searchingWithQuery != textEditingValue.text) {
                    return _lastOptions;
                  }
                  _lastsearching = _searchingWithQuery;
                  _lastOptions = options;
                  return options;
                } else {
                  return _lastOptions;
                }
              },
              onSelected: (String selection) {
                debugPrint('You just selected $selection');
              },
            ));
  }
}
