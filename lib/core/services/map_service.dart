import 'dart:async';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;




// This is a PlacePhoto class that is used to store the photo of a place
abstract class PlacePhoto {
  final String name;
  final int widthPx;
  final int heightPx;
  ImageProvider get imageProvider;
  PlacePhoto({required this.name, required this.heightPx, required this.widthPx});
}
// We have two classes that implement the PlacePhoto class
// PlacePhotoNetwork is used to get the photo from the internet from the google places api
class PlacePhotoNetwork extends PlacePhoto {
  final String name;
  int widthPx;
  int heightPx;
  static const _key = "YOUR_NEW_GOOGLE_MAPS_API_KEY_HERE";

  ImageProvider get imageProvider => NetworkImage(
        "https://places.googleapis.com/v1/$name/media?maxHeightPx=$heightPx&maxWidthPx=$widthPx&key=$_key",
      );
  PlacePhotoNetwork({
    required this.name,
    required this.heightPx,
    required this.widthPx,
  }) : super(name: '', heightPx: 0, widthPx: 0) {
    if (widthPx >= 4800) {
      widthPx = 4800;
    }
    if (heightPx >= 4800) {
      heightPx = 4800;
    }
  }
}
// when no photo is available, we use the PlacePhotoAsset class
class PlacePhotoAsset extends PlacePhoto {
  @override
  final String name = "no name";
  @override
  final int heightPx = 100;
  @override
  final int widthPx = 100;
  ImageProvider get imageProvider => const AssetImage("assets/placeholder.jpg");
  PlacePhotoAsset() : super(name: '', heightPx: 0, widthPx: 0);
}

// This is the Place class that is used to store the details of a place
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
  get photosElements => photos.map((photo) {
        if (photo == null) {
          return PlacePhotoAsset();
        }
        return PlacePhotoNetwork(
          name: photo["name"],
          heightPx: photo["widthPx"],
          widthPx: photo["heightPx"],
        );
      }).toList();
  PlacePhoto get firstImage => photos.isNotEmpty ? photosElements.first : PlacePhotoAsset();  //TODO: check if first Photo is null => was soll dann passieren?
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
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "types": types,
      "primaryType": primaryType,
      "location": {
        "latitude": location.latitude,
        "longitude": location.longitude
      },
      "placeId": placeId,
      "photos": photos,
      "formattedAddress": formattedAddress,
      "internationalPhoneNumber": internationalPhoneNumber,
      "buisnessStatus": buisnessStatus,
      "rating": rating,
      "reviews": reviews
    };
  }

  static Place fromMap(Map<String, dynamic> map) {
    return Place(
        name: map["name"],
        types: map["types"],
        primaryType: map["primaryType"],
        location:
            LatLng(map["location"]["latitude"], map["location"]["longitude"]),
        placeId: map["placeId"],
        photos: map["photos"],
        formattedAddress: map["formattedAddress"],
        internationalPhoneNumber: map["internationalPhoneNumber"],
        buisnessStatus: map["buisnessStatus"],
        rating: map["rating"],
        reviews: map["reviews"]);
  }
}

class GoogleMapService {
  static const key = "YOUR_NEW_GOOGLE_MAPS_API_KEY_HERE";

  Future<dynamic> getPlacesNew(
      LatLng coords, int radius, List<String> interests) async {
    var lat = coords.latitude;
    var lng = coords.longitude;

    const String url = 'https://places.googleapis.com/v1/places:searchNearby';

    List<String> interestsList1 = [];
    List<String> interestsList2 = [];

    for (var i = 0; i < interests.length; i++) {
      if (i < 40) {
        interestsList1.add(interests[i]);
      } else {
        interestsList2.add(interests[i]);
      }
    }
    String maxAmount = "5";
    if (interestsList2.isEmpty) {
      maxAmount = "10";
    }
    // Split into two requests if more than 40 interests
    // since the google places api only allows 40 interests per request
    var apiRequest1 = await http.post(Uri.parse(url),
        body: convert.jsonEncode({
          "locationRestriction": {
            "circle": {
              "center": {"latitude": "$lat", "longitude": "$lng"},
              "radius": "$radius"
            }
          },
          "maxResultCount": maxAmount,
          "includedTypes": interestsList1,
        }),
        headers: {
          "X-Goog-Api-Key": key,
          "X-Goog-FieldMask":
              "places.displayName,places.types,places.location,places.photos,places.id,places.formattedAddress,places.internationalPhoneNumber,places.businessStatus,places.rating,places.reviews,places.primaryType"
        });
    var json2;
    if (interestsList2.isNotEmpty) {
      var apiRequest2 = await http.post(Uri.parse(url),
          body: convert.jsonEncode({
            "locationRestriction": {
              "circle": {
                "center": {"latitude": "$lat", "longitude": "$lng"},
                "radius": "$radius"
              }
            },
            "maxResultCount": "5",
            "includedTypes": interestsList2,
          }),
          headers: {
            "X-Goog-Api-Key": key,
            "X-Goog-FieldMask":
                "places.displayName,places.types,places.location,places.photos,places.id,places.formattedAddress,places.internationalPhoneNumber,places.businessStatus,places.rating,places.reviews,places.primaryType"
          });
      json2 = convert.jsonDecode(apiRequest2.body);
    }

    var json1 = convert.jsonDecode(apiRequest1.body);
    List<dynamic> places;
    List<Place> placeList = [];

    if (json1["places"] == null) {
      return placeList;
    }
    if (json2 != null) {
      places = [...json1["places"], ...json2["places"]];
    } else {
      places = json1["places"];
    }
    for (var place in places) {
      placeList.add(Place(
        name: place["displayName"]["text"] ?? "No name",
        types: place["types"] ?? ["No types"],
        location: LatLng(
            place["location"]["latitude"], place["location"]["longitude"]),
        placeId: place["id"],
        photos: place["photos"] ?? [],
        formattedAddress: place["formattedAddress"] ?? "Non given",
        internationalPhoneNumber:
            place["internationalPhoneNumber"] ?? "Non given",
        buisnessStatus: place["businessStatus"] ?? "Non given",
        rating: place["rating"] != null ? place["rating"] * 1.0 : 0.0,
        primaryType: place["primaryType"] ?? "",
        reviews: place["reviews"] ?? [],
      ));
    }
    return placeList;
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
