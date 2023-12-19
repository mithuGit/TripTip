
import 'package:flutter_riverpod/flutter_riverpod.dart';    
import 'package:internet_praktikum/ticket/place.dart';
import 'dart:io';

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super([]);

 void addPlace(String title, File image, PlaceLocation location) {
  final newPlace = Place(
    title: title,
    image: image,
    location: location,
  );

  state = [newPlace, ...state];
}


  void removePlace(Place place) {
    state = state.where((element) => element != place).toList();
  }
}

final userPlacesProvider = StateNotifierProvider<UserPlacesNotifier, List<Place>>(
  (ref) => UserPlacesNotifier(),
);
