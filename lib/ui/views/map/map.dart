import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:internet_praktikum/core/services/placeApiProvider.dart';
import 'package:internet_praktikum/ui/views/map/directions.dart';
import 'package:internet_praktikum/ui/views/map/directions_repository.dart';
//import 'package:internet_praktikum/ui/widgets/inputfield_search_lookahead.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
// TODO: null beim landen von map -> fixen
  final Completer<GoogleMapController> _googleMapController = Completer();
  Marker? _origin;
  Marker? _destination;
  Directions? _info;
  LatLng? latLng;
  bool mapIsActiv = true;
  PlaceDetails? placeDetails;

  CameraPosition? _initialCameraPosition;

  //Circle
  Set<Circle> _circles = {};
  var radiusValue = 3000.0;
  LatLng? tappedPoint;

  //Toggling UI as we need;
  bool searchToggle = false;
  bool radiusSlider = false;
  bool cardTapped = false;
  bool pressedNear = false;
  bool getDirections = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLatLng().then((value) => setState(() {
          latLng = value;
          _initialCameraPosition = CameraPosition(
            target: latLng != null ? latLng! : const LatLng(0, 0),
            zoom: 11.5,
          );
        }));
  }

  @override
  void dispose() {
    //_googleMapController?.dispose(); //TODO: brauch ich das?
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
          centerTitle: false,
          title: const Text(
            'Map',
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
            ),
          ),
          backgroundColor: Colors.transparent,
          actions: [
            if (_origin != null)
              TextButton(
                  onPressed: () async {
                    var controller = await _googleMapController.future;
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _origin!.position,
                          zoom: 14.5,
                          tilt: 50.0,
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: const Text("Origin")),
            if (_destination != null)
              TextButton(
                  onPressed: () async {
                    var controller = await _googleMapController.future;
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _destination!.position,
                          zoom: 14.5,
                          tilt: 50.0,
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: const Text("Destination")),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black, size: 30),
              onPressed: () {
                //search in map
              },
            ),
          ]),
      body: Stack(
        children: [
          Container(
            //height: MediaQuery.of(context).size.height * 0.5,
            //width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: _initialCameraPosition!,
              onMapCreated: (GoogleMapController controller) {
                _googleMapController.complete(controller);
              },
              markers: {
                if (_origin != null) _origin!,
                if (_destination != null) _destination!,
              },
              polylines: {
                if (_info != null)
                  Polyline(
                    polylineId: const PolylineId('overview_polyline'),
                    color: Colors.red,
                    width: 5,
                    points: _info!.polylinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList(),
                  ),
              },
              onLongPress: _addMarker,
              circles: _circles,
              onTap: (point) {
                //tappedPoint = point; // TODO: maxbe für später
                _setCircle(point);
              },
            ),
          ),
          if (_info != null)
            Positioned(
              top: 20.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    )
                  ],
                ),
                child: Text(
                  '${_info!.totalDistance}, ${_info!.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          /*mapIsActiv ? Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background_forest_trans.png'), // assets/BackgroundCity.png
                fit: BoxFit.fitWidth,
              ),
            ),
          ) : const Text("Map is not activ"),*/

          /*Padding(
            padding: const EdgeInsets.only(left: 14, right: 14),
            child: AsyncAutocomplete(
              onDestinationPick: (PlaceDetails details) {
                setState(() {
                  placeDetails = details;
                });
              },
            ),
          ),*/
          radiusSlider
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                  child: Container(
                    height: 50,
                    color: Colors.black.withOpacity(0.3),
                    child: Row(children: [
                      Expanded(
                        child: Slider(
                          max: 7000,
                          min: 1000,
                          value: radiusValue,
                          onChanged: (newValue) {
                            setState(() {
                              radiusValue = newValue;
                              pressedNear = false;
                              if (tappedPoint != null) {
                                _setCircle(tappedPoint!);
                              }
                            });
                          },
                        ),
                      )
                    ]),
                  ))
              : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () async {
          var controller = await _googleMapController.future;
          controller.animateCamera(
            _info != null
                ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
                : CameraUpdate.newCameraPosition(_initialCameraPosition!),
          );
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  void _setCircle(LatLng point) async {
    final GoogleMapController controller = await _googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: point, zoom: 12)));
    setState(() {
      _circles.add(Circle(
          circleId: const CircleId('RecommendationCircle'),
          center: point,
          fillColor: Colors.blue.withOpacity(0.1),
          radius: radiusValue,
          strokeColor: Colors.blue,
          strokeWidth: 1));
      getDirections = false;
      searchToggle = false;
      radiusSlider = true;
    });
  }

  void _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      // Origin is not set OR Origin/Destination are both set
      // Set origin
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Current Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          position: pos,
        );
        _destination = null;

        // Reset info
        _info = null;
      });
    } else {
      // Origin is already set
      // Set destination
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
          position: pos,
        );
      });

      // Get directions
      final directions = await DirectionsRepository()
          .getDirection(origin: _origin!.position, destination: pos);
      setState(() => _info = directions);
    }
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
}
