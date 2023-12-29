import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:internet_praktikum/core/services/placeApiProvider.dart';
import 'package:internet_praktikum/ui/views/map/directions.dart';
import 'package:internet_praktikum/ui/views/map/directions_repository.dart';
import 'package:internet_praktikum/core/services/map_service.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
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

//Marker
  Set<Marker> _markers = <Marker>{};
  //Set<Marker> _markersDupe = Set<Marker>();

  int markerIdCounter = 1;

  //places
  List allFavoritePlaces = [];
  String tokenKey = '';

  //Circle
  final Set<Circle> _circles = <Circle>{};
  var radiusValue = 3000.0;
  dynamic tappedPoint;
  Timer? _debounce;

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
    GoogleMapService().getLatLng().then((value) => setState(() {
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
                ..._markers,
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
                tappedPoint = point;
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
                      )),
                      !pressedNear
                          ? IconButton(
                              onPressed: () {
                                if (_debounce?.isActive ?? false) {
                                  _debounce?.cancel();
                                }
                                _debounce =
                                    Timer(const Duration(seconds: 2), () async {
                                  var placesResult = await GoogleMapService()
                                      .getPlaceDetails(
                                          tappedPoint, radiusValue.toInt());

                                  List<dynamic> placesWithin =
                                      placesResult['results'] as List;

                                  allFavoritePlaces = placesWithin;

                                  tokenKey =
                                      placesResult['next_page_token'] ?? 'none';
                                  _markers = {};
                                  for (var element in placesWithin) {
                                    _setNearMarker(
                                      LatLng(
                                          element['geometry']['location']
                                              ['lat'],
                                          element['geometry']['location']
                                              ['lng']),
                                      element['name'],
                                      element['types'],
                                      element['business_status'] ??
                                          'not available',
                                    );
                                  }
                                  //_markersDupe = _markers;
                                  pressedNear = true;
                                });
                              },
                              icon: const Icon(
                                Icons.near_me,
                                color: Colors.blue,
                              ))
                          : IconButton(
                              onPressed: () {
                                if (_debounce?.isActive ?? false) {
                                  _debounce?.cancel();
                                }
                                _debounce =
                                    Timer(const Duration(seconds: 2), () async {
                                  if (tokenKey != 'none') {
                                    var placesResult = await GoogleMapService()
                                        .getMorePlaceDetails(tokenKey);

                                    List<dynamic> placesWithin =
                                        placesResult['results'] as List;

                                    allFavoritePlaces.addAll(placesWithin);

                                    tokenKey =
                                        placesResult['next_page_token'] ??
                                            'none';

                                    for (var element in placesWithin) {
                                      _setNearMarker(
                                        LatLng(
                                            element['geometry']['location']
                                                ['lat'],
                                            element['geometry']['location']
                                                ['lng']),
                                        element['name'],
                                        element['types'],
                                        element['business_status'] ??
                                            'not available',
                                      );
                                    }
                                  } else {
                                    ErrorSnackbar.showErrorSnackbar(context, "No more places available");
                                  }
                                });
                              },
                              icon: const Icon(Icons.more_time,
                                  color: Colors.blue)),
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

  _setNearMarker(LatLng point, String label, List types, String status) async {
    var counter = markerIdCounter++;

    final Uint8List markerIcon;
//TODO alle else if teile machen 
    if (types.contains('restaurants')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/restaurants.png', 75);
    } else if (types.contains('food')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/food.png', 75);
    } else if (types.contains('school')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/schools.png', 75);
    } else if (types.contains('bar')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/bars.png', 75);
    } else if (types.contains('lodging')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/hotels.png', 75);
    } else if (types.contains('store')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/retail-stores.png', 75);
    } else if (types.contains('locality')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/local-services.png', 75);
    } else {
      markerIcon = await getBytesFromAsset('assets/map_icon/places.png', 75);
    }
    final Marker marker = Marker(
        markerId: MarkerId('marker_$counter'),
        position: point,
        onTap: () {},
        icon: BitmapDescriptor.fromBytes(markerIcon));

    setState(() {
      _markers.add(marker);
    });
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
}
