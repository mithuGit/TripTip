import 'dart:async';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:location/location.dart';

class Place {
  final String name;
  final List<dynamic> types;
  final String primaryType;
  final LatLng location;
  final String placeId;
  final List<dynamic> photos;
  final String formattedAddress;
  final String internationalPhoneNumber;
  final String buisnessStatus;
  final double rating;
  final List<dynamic> reviews;
  get typesString => types.join(", ");

  Place(
      {required this.name,
      required this.types,
      required this.primaryType,
      required this.location,
      required this.placeId,
      required this.photos,
      required this.formattedAddress,
      required this.internationalPhoneNumber,
      required this.buisnessStatus,
      required this.rating,
      required this.reviews});
}

class GoogleMapService {
  static const key = "AIzaSyBUh4YsufaUkM8XQqdO8TSXKpBf_3dJOmA";

  Future<dynamic> getPlaceDetails(LatLng coords, int radius) async {
    var lat = coords.latitude;
    var lng = coords.longitude;

    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?&location=$lat,$lng&radius=$radius&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    return json;
  }

  Future<dynamic> getPlacesNew(LatLng coords, int radius) async {
    var lat = coords.latitude;
    var lng = coords.longitude;

    const String url = 'https://places.googleapis.com/v1/places:searchNearby';

    var apiRequest = await http.post(Uri.parse(url),
        body: convert.jsonEncode({
          "locationRestriction": {
            "circle": {
              "center": {"latitude": "$lat", "longitude": "$lng"},
              "radius": "$radius"
            }
          },
          "maxResultCount": "10",
        }),
        headers: {
          //  "Content-Type": "application/json",
          // "Accept": "application/json",
          "X-Goog-Api-Key": key,
          "X-Goog-FieldMask":
              "places.displayName,places.types,places.location,places.photos,places.id,places.formattedAddress,places.internationalPhoneNumber,places.businessStatus,places.rating,places.reviews,places.primaryType"
        });
    var json = convert.jsonDecode(apiRequest.body);

    List<dynamic> places = json["places"];
    List<Place> placeList = [];
    for (var place in places) {
      placeList.add(Place(
        name: place["displayName"]["text"],
        types: place["types"],
        location: LatLng(
            place["location"]["latitude"], place["location"]["longitude"]),
        placeId: place["id"],
        photos: place["photos"],
        formattedAddress: place["formattedAddress"] ?? "",
        internationalPhoneNumber: place["internationalPhoneNumber"] ?? "",
        buisnessStatus: place["businessStatus"],
        rating: place["rating"] * 1.0,
        primaryType: place["primaryType"] ?? "",
        reviews: place["reviews"],
      ));
    }
    return placeList;
  }

  Future<dynamic> getPlaceDetailsType(
      LatLng coords, int radius, String type) async {
    var lat = coords.latitude;
    var lng = coords.longitude;

    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?&location=$lat,$lng&radius=$radius&type=$type&key=$key';

    var response = await http.get(Uri.parse(url));

    var json = convert.jsonDecode(response.body);

    return json;
  }

  Future<dynamic> getMorePlaceDetails(String token) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?&pagetoken=$token&key=$key';

    var response = await http.get(Uri.parse(url));

    var json = convert.jsonDecode(response.body);

    return json;
  }

  Future<LatLng> getLatLng() async {
    final auth = FirebaseAuth.instance.currentUser;

    if (auth == null) {
      // Handle the case where the user is not authenticated
      return Future.error('User not authenticated');
    }

    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.uid)
            .get();

    final String tripId = userDoc.data()!['selectedtrip'].toString();

    final DocumentSnapshot<Map<String, dynamic>> selectedTripDoc =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();

    if (selectedTripDoc.exists == false) {
      // Handle the case where no trip is found for the user
      return Future.error('No trip found for the user');
    }

    final String lat = selectedTripDoc
        .data()!['placedetails']["location"]["latitude"]
        .toString();
    final String long = selectedTripDoc
        .data()!['placedetails']["location"]["longitude"]
        .toString();

    LatLng latLng = LatLng(double.parse(lat), double.parse(long));
    // print( "latLng: " + latLng.toString());
    return latLng;
  }

  Future<Map<String, dynamic>> getDetailsForPlace(String? input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$input&key=$key';

    var response = await http.get(Uri.parse(url));

    var json = convert.jsonDecode(response.body);

    var results = json['result'] as Map<String, dynamic>;

    return results;
  }

  Future<Marker> getCurrentLocation(
      Completer<GoogleMapController> _googleMapController) async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await Location().serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Location().requestService();
      if (!serviceEnabled) {
        return const Marker(
            markerId: MarkerId('myLocation'),
            infoWindow: InfoWindow(
              title: 'My Current Location',
            ),
            position: LatLng(0, 0));
      }
    }

    permissionGranted = await Location().hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await Location().requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return const Marker(
            markerId: MarkerId('myLocation'),
            infoWindow: InfoWindow(
              title: 'My Current Location',
            ),
            position: LatLng(0, 0));
      }
    }

    LocationData currentPosition = await Location().getLocation();
    var latitude = currentPosition.latitude!;
    var longitude = currentPosition.longitude!;

    final Uint8List markerIcon = await getBytesFromAsset(
        'assets/my_location.png',
        100); //TODO: ICON auf Blau machen, also die PNG Datei ändern

    var currentLocation = Marker(
        markerId: const MarkerId('myLocation'),
        infoWindow: const InfoWindow(
          title: 'My Current Location',
        ),
        position: LatLng(latitude, longitude),
        icon: BitmapDescriptor.fromBytes(markerIcon));

    var controller = await _googleMapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(latitude, longitude), zoom: 15),
      ),
    );
    return currentLocation;
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);

    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}
