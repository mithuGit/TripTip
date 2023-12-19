import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_praktikum/ticket/UserPLacesNotifier.dart';
import 'package:internet_praktikum/ticket/image_input.dart';
import 'dart:io';

import 'package:internet_praktikum/ticket/location_input.dart';
import 'package:internet_praktikum/ticket/place.dart';
class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddPlaceScreen> createState() {
    return _AddPlaceScreenState();
  }
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _titleController = TextEditingController();
  File? _selectedImage;
  PlaceLocation? _selectedLocation;

  void _savePlace(){
    final enteredText = _titleController.text;

    if(enteredText.isEmpty || _selectedImage==null || _selectedLocation==null){
      return;
    }

    ref.read(userPlacesProvider.notifier)
    .addPlace(enteredText, _selectedImage!, _selectedLocation!);  

  Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              controller: _titleController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 10),
            LocationINput(onSelectPlace: (location){
              _selectedLocation = location;
            },),
            const SizedBox(height: 10),
             ImageInput(onPickImage: (image) {
              _selectedImage = image;
            },),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _savePlace,
              icon: const Icon(Icons.add),
              label: const Text('Add Place'),
            ),
          ],
        ),
      ),
    );
  }
}
