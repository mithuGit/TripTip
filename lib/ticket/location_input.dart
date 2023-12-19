import 'package:flutter/material.dart';
import 'package:internet_praktikum/ticket/place.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationINput extends StatefulWidget {
  const LocationINput({super.key, required this.onSelectPlace});

  final void Function(PlaceLocation location) onSelectPlace;

  @override
  State<LocationINput> createState() => _LocationINputState();
}

class _LocationINputState extends State<LocationINput> {

  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  String get locationImage{
    if(_pickedLocation == null){
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:blue%7Clabel:S%7C40.702147,-74.015794&markers=color:green%7Clabel:G%7C40.711614,-74.012318&markers=color:red%7Clabel:C%7C$lat,$lng&key=AIzaSyD-8ZzZ3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3';
    }


  void _getcurrentLocation() async {
    
    Location location =  Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    
  final lat  = locationData.latitude;
  final long = locationData.longitude;

  if(lat == null || long == null){

    return;
  }


  final url =Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=AIzaSyD-8ZzZ3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3');  

  final response = await http.get(url);
  final resData = json.decode(response.body);
  final address = resData['results'][0]['formatted_address'];

    setState(() {
      _pickedLocation=PlaceLocation(latitude: lat,
       longitude: long,
        address: address);
      _isGettingLocation = false;
    });

    widget.onSelectPlace(_pickedLocation!);


  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = const Text(
          'No Location Chosen',
          textAlign: TextAlign.center,
        );


if(_pickedLocation != null){
  previewContent = Image.network(
    locationImage,
    fit: BoxFit.cover,
    width: double.infinity,
    height:double.infinity,
  );

}
    if(_isGettingLocation ){
      previewContent = const CircularProgressIndicator();
    }
    


    return Column(children: [
      Container(
        height: 170,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey),
        ),
        child: previewContent,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.location_on),
            label: const Text('Current Location'),
            onPressed: _getcurrentLocation,
          ),
          TextButton.icon(
            icon: const Icon(Icons.map),
            label: const Text('Select on Map'),
            onPressed: () {},
          ),
        ],
      ),
    ]);
  }
}
