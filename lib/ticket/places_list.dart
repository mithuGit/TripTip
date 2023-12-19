import 'package:flutter/material.dart';
import 'package:internet_praktikum/ticket/place.dart';
import 'package:internet_praktikum/ticket/places_detail.dart';

class PlacesList extends StatelessWidget {
  const PlacesList({Key? key, required this.places}) : super(key: key);
  
  final List<Place> places;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return const Center(
        child: Text("Got no places yet, start adding some!"),
      );
    }

    return ListView.builder(
      itemCount: places.length,
      itemBuilder: (ctx, index) => ListTile(
        leading: CircleAvatar(
          radius:26,
          backgroundImage: FileImage(places[index].image),
        ),
        title: Text(
          places[index].title,
          style: Theme.of(context).textTheme.headline6!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        subtitle: Text(
          places[index].location.address,
          style: Theme.of(context).textTheme.subtitle1!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => PlaceDetailScreen(place: places[index]),
          ));
        },
      ),
    );
  }
}
