import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:internet_praktikum/core/services/placeApiProvider.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/views/map/directions.dart';
import 'package:internet_praktikum/ui/views/map/directions_repository.dart';
import 'package:internet_praktikum/core/services/map_service.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/mapWidgets/mapButton.dart';
import 'package:internet_praktikum/ui/widgets/mapWidgets/mapcard.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  final Place? place;
  const MapPage({super.key, this.place});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _googleMapController = Completer();

  Marker? origin;
  Marker? destination;
  Directions? infoDistanceAndDuration;
  LatLng? latLng;
  PlaceDetails? placeDetails;

  CameraPosition? _initialCameraPosition;

  //Marker
  Set<Marker> markers = <Marker>{};

  int markerIdCounter = 1;

  //places
  List<Place> allFavoritePlaces = [];

  //Circle
  Set<Circle> _circles = <Circle>{};
  var radiusValue = 3000.0;
  dynamic tappedPointInCircle;

  //Toggling UI as we need;
  bool radiusSlider = false;

  bool pressToGetRecommend = false;

  //page Controller
  late PageController _pageController;
  int previewCard = 0;

  String placeImage = '';
  var photoGalleryIndex = 0;

  //expandable container
  bool isExpanded = false;
  bool isExpandedOrigin = false;
  bool isExpandedDestination = false;
  bool isExpandedCurrentLocation = false;

  //Current Location Data
  LocationData? currentLocationData;
  Location? location;
  Uint8List? currentIcon;
  bool isInitialCameraMove = true;
  StreamSubscription<LocationData>? locationSubscription;

  bool isLocationLoading = false;
  bool loadingRecommendations = false;

  @override
  void initState() {
    super.initState();
    if (widget.place == null) {
      GoogleMapService().getLatLng().then((value) => setState(() {
            latLng = value;
            _initialCameraPosition = CameraPosition(
              target: latLng != null ? latLng! : const LatLng(0, 0),
              zoom: 11.5,
            );
          }));
      _pageController = PageController(initialPage: 1, viewportFraction: 0.85)
        ..addListener(_swipe);
    } else {
      _initialCameraPosition = CameraPosition(
          target: LatLng(widget.place!.location.latitude,
              widget.place!.location.longitude),
          zoom: 11.5);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_swipe);
    _pageController.dispose();
    super.dispose();
  }

  void _swipe() {
    if (_pageController.page!.toInt() != previewCard) {
      previewCard = _pageController.page!.toInt();
      photoGalleryIndex = 0;
      goToTappedPlace();
    }
  }

  Future<void> goToTappedPlace() async {
    final GoogleMapController controller = await _googleMapController.future;
    markers = {};

    var selectedPlace = allFavoritePlaces[_pageController.page!.toInt()];

    _setNearMarker(
      LatLng(selectedPlace.location.latitude, selectedPlace.location.longitude),
      selectedPlace.name,
      selectedPlace.types,
    );

    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(selectedPlace.location.latitude + 0.015,
            selectedPlace.location.longitude),
        zoom: 14.0,
        bearing: 180.0,
        tilt: 45.0)));
  }

  void getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    location = Location();

    serviceEnabled = await location!.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location!.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location!.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location!.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    currentIcon = await GoogleMapService()
        .getBytesFromAsset('assets/my_location.png', 135);

    location!.getLocation().then(
      (location) {
        currentLocationData = location;
      },
    );

    var controller = await _googleMapController.future;
    locationSubscription =
        location!.onLocationChanged.listen((LocationData currentLocation) {
      currentLocationData = currentLocation;

      if (isInitialCameraMove) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(currentLocationData!.latitude!,
                  currentLocationData!.longitude!),
              zoom: 15,
            ),
          ),
        );
        setState(() {});
        isInitialCameraMove = false;
      } else {
        if (mounted) {
          setState(() {
            CameraPosition(
              target: LatLng(currentLocationData!.latitude!,
                  currentLocationData!.longitude!),
              zoom: 15,
            );
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
          scrolledUnderElevation: 0,
          toolbarHeight: 65,
          centerTitle: true,
          title: const Text(
            'Map',
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
            ),
          ),
          backgroundColor: Colors.transparent,
          leading: Column(
            children: [
              if (isLocationLoading == true && currentLocationData == null) ...{
                // Show CircularProgressIndicator only when data is not available
                const Column(
                  children: [
                    SizedBox(height: 14),
                    SizedBox(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    )
                  ],
                ),
              } else if (isLocationLoading == false ||
                  currentLocationData != null) ...{
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.directions_outlined,
                          color: Colors.black, size: 30),
                      onPressed: () async {
                        setState(() {
                          isLocationLoading = true;
                          currentLocationData = null;
                          isInitialCameraMove = true;
                        });
                        getCurrentLocation();
                      },
                    ),
                    const Text(
                      'Location',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              }
            ],
          ),
          actions: [
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.center_focus_strong),
                  onPressed: () async {
                    var controller = await _googleMapController.future;
                    controller.animateCamera(
                      infoDistanceAndDuration != null
                          ? CameraUpdate.newLatLngBounds(
                              infoDistanceAndDuration!.bounds, 100.0)
                          : CameraUpdate.newCameraPosition(
                              _initialCameraPosition!),
                    );
                  },
                ),
                Text(
                  infoDistanceAndDuration != null
                      ? 'Zoom to route'
                      : 'Vacation',
                  style: const TextStyle(
                      color: Colors.black, fontFamily: 'Ubuntu', fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 3),
          ]),
      body: _initialCameraPosition == null
          ? const Column(
              children: [
                SizedBox(height: 100),
                Center(child: CircularProgressIndicator()),
                SizedBox(height: 20),
                Center(child: Text('Loading Map')),
              ],
            )
          : Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: GoogleMap(
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    initialCameraPosition: _initialCameraPosition!,
                    onMapCreated: (GoogleMapController controller) {
                      _googleMapController.complete(controller);
                    },
                    markers: {
                      if (origin != null) origin!,
                      if (destination != null) destination!,
                      if (currentLocationData != null &&
                          currentIcon != null) ...{
                        Marker(
                          markerId: const MarkerId("currentLocation"),
                          position: LatLng(currentLocationData!.latitude!,
                              currentLocationData!.longitude!),
                          icon: BitmapDescriptor.fromBytes(currentIcon!),
                        ),
                      },
                      ...markers,
                    },
                    polylines: {
                      if (infoDistanceAndDuration != null)
                        Polyline(
                          polylineId: const PolylineId('overview_polyline'),
                          color: Theme.of(context).primaryColor,
                          width: 4,
                          points: infoDistanceAndDuration!.polylinePoints
                              .map((e) => LatLng(e.latitude, e.longitude))
                              .toList(),
                        ),
                    },
                    onLongPress: _addMarker,
                    circles: _circles,
                    onTap: (point) {
                      tappedPointInCircle = point;
                      _setCircle(point);
                      markers = {};
                      pressToGetRecommend = false;
                    },
                  ),
                ),
                if (widget.place != null) ...[
                  Positioned(
                      bottom: isExpanded ? 40.0 : 28.0,
                      child: SizedBox(
                        height: isExpanded ? 480.0 : 200.0,
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          children: [
                            Center(
                              child: GestureDetector(
                                  onTap: () async {
                                    isExpanded = !isExpanded;
                                    goToTappedPlace();
                                  },
                                  child: MapCard(
                                      place: widget.place!,
                                      isExpanded: isExpanded,
                                      onExpandedChanged: (newIsExpanded) {
                                        setState(() {
                                          isExpanded = newIsExpanded;
                                        });
                                      },
                                      photoGalleryIndex: photoGalleryIndex,
                                      placeImage: placeImage)),
                            )
                          ],
                        ),
                      ))
                ],
                Column(
                  children: [
                    if (infoDistanceAndDuration == null &&
                        !radiusSlider &&
                        !pressToGetRecommend &&
                        !isExpanded &&
                        destination == null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.65,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(34.5),
                                color: Colors.white.withOpacity(0.9)),
                            padding: const EdgeInsets.symmetric(),
                            child: origin == null
                                ? const Text(
                                    'Tap to see personalized recommendation \nLong press to set origin and destination',
                                    style: Styles.warningmap,
                                    textAlign: TextAlign.center,
                                  )
                                : const Text(
                                    'Long press again to set destination',
                                    style: Styles.warningmap,
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (infoDistanceAndDuration != null)
                  Positioned(
                    top: 50.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 43, 43, 43)
                            .withOpacity(0.90),
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(34.5),
                            bottomRight: Radius.circular(34.5)),
                      ),
                      child: Text(
                        '${infoDistanceAndDuration!.totalDistance}, ${infoDistanceAndDuration!.totalDuration}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (origin != null || currentLocationData != null)
                  Positioned(
                      top: 90.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (origin != null)
                            Column(
                              children: [
                                MapButton(
                                  icon: Icons.pin_drop,
                                  makeSmaller: () {
                                    setState(() {
                                      isExpandedOrigin = false;
                                    });
                                  },
                                  makeBigger: () {
                                    setState(() {
                                      isExpandedOrigin = true;
                                    });
                                  },
                                  isExpandedButton: isExpandedOrigin,
                                  colors: Colors.green,
                                  text: "Ori",
                                  onTap: () async {
                                    var controller =
                                        await _googleMapController.future;
                                    controller.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: origin!.position,
                                          zoom: 14.5,
                                        ),
                                      ),
                                    );
                                  },
                                  onClose: () => setState(() => {
                                        origin = null,
                                        destination = null,
                                        infoDistanceAndDuration = null,
                                        isExpandedOrigin = false,
                                      }),
                                ),
                                const SizedBox(height: 5.0),
                              ],
                            ),
                          if (destination != null)
                            Column(
                              children: [
                                MapButton(
                                  icon: Icons.pin_drop,
                                  makeSmaller: () {
                                    setState(() {
                                      isExpandedDestination = false;
                                    });
                                  },
                                  makeBigger: () {
                                    setState(() {
                                      isExpandedDestination = true;
                                    });
                                  },
                                  isExpandedButton: isExpandedDestination,
                                  colors: Colors.red,
                                  text: "Des",
                                  onTap: () async {
                                    var controller =
                                        await _googleMapController.future;
                                    controller.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: destination!.position,
                                          zoom: 14.5,
                                        ),
                                      ),
                                    );
                                  },
                                  onClose: () => setState(() => {
                                        destination = null,
                                        infoDistanceAndDuration = null,
                                        isExpandedDestination = false,
                                      }),
                                ),
                                const SizedBox(height: 5.0),
                              ],
                            ),
                          if (currentLocationData != null)
                            MapButton(
                              icon: Icons.directions,
                              makeSmaller: () {
                                setState(() {
                                  isExpandedCurrentLocation = false;
                                });
                              },
                              makeBigger: () {
                                setState(() {
                                  isExpandedCurrentLocation = true;
                                });
                              },
                              isExpandedButton: isExpandedCurrentLocation,
                              colors: Colors.blue,
                              text: "Cur",
                              onTap: () async {
                                var controller =
                                    await _googleMapController.future;
                                controller.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(
                                          currentLocationData!.latitude!,
                                          currentLocationData!.longitude!),
                                      zoom: 14.5,
                                    ),
                                  ),
                                );
                              },
                              onClose: () => setState(() => {
                                    isLocationLoading = false,
                                    currentLocationData = null,
                                    isExpandedCurrentLocation = false,
                                    locationSubscription!.cancel(),
                                  }),
                            ),
                        ],
                      )),
                radiusSlider
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                        child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(34.5),
                                  color: const Color.fromARGB(255, 43, 43, 43)
                                      .withOpacity(0.90)),
                              width: 50,
                              height: MediaQuery.of(context).size.height * 0.28,
                              child: Column(children: [
                                Expanded(
                                    child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Slider(
                                    activeColor: Colors.white,
                                    max: 7000,
                                    min: 1000,
                                    value: radiusValue,
                                    onChanged: (newValue) {
                                      setState(() {
                                        radiusValue = newValue;
                                        pressToGetRecommend = false;
                                        if (tappedPointInCircle != null) {
                                          _setCircle(tappedPointInCircle!);
                                        }
                                      });
                                    },
                                  ),
                                )),
                                !pressToGetRecommend
                                    ? IconButton(
                                        onPressed: () async {
                                          final user = FirebaseAuth
                                              .instance.currentUser!;
                                          final userCollection =
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(user.uid)
                                                  .get();

                                          if (userCollection.exists == false) {
                                            // ignore: use_build_context_synchronously
                                            return ErrorSnackbar
                                                .showErrorSnackbar(context,
                                                    "No interests selected");
                                          }

                                          final interests = userCollection
                                              .data()!['interests'];

                                          setState(() {
                                            loadingRecommendations =
                                                true; // Setzen Sie den Ladezustand
                                          });

                                          try {
                                            List<Place> places =
                                                await GoogleMapService()
                                                    .getPlacesNew(
                                              tappedPointInCircle,
                                              radiusValue.toInt(),
                                              interests.cast<String>(),
                                            );

                                            if (places.isEmpty) {
                                              pressToGetRecommend = false;
                                              markers = {};
                                              setState(() {
                                                loadingRecommendations = false;
                                              });
                                              // ignore: use_build_context_synchronously
                                              return ErrorSnackbar
                                                  .showErrorSnackbar(context,
                                                      "No places found");
                                            }

                                            for (var place in places) {
                                              _setNearMarker(
                                                place.location,
                                                place.name,
                                                place.types,
                                              );
                                            }
                                            allFavoritePlaces = places;
                                            pressToGetRecommend = true;

                                            setState(() {
                                              placeImage =
                                                  places[1].photos[0]['name'];
                                              loadingRecommendations = false;
                                            });
                                          } catch (e) {
                                            if (kDebugMode) {
                                              print(
                                                  "Error fetching recommendations: $e");
                                            }
                                            // ignore: use_build_context_synchronously
                                            ErrorSnackbar.showErrorSnackbar(
                                                context,
                                                "Error fetching recommendations \nPlease try again later");
                                            setState(() {
                                              loadingRecommendations = false;
                                            });
                                          }
                                        },
                                        icon: loadingRecommendations
                                            ? const SizedBox(
                                                height: 30,
                                                width: 30,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                ))
                                            : const ImageIcon(
                                                AssetImage(
                                                    'assets/recommend_pic/recommend.png'),
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                      )
                                    : IconButton(
                                        onPressed: () {
                                          setState(() {
                                            markers = {};
                                            allFavoritePlaces = [];
                                            pressToGetRecommend = false;
                                          });
                                        },
                                        icon: const ImageIcon(
                                          AssetImage(
                                              'assets/recommend_pic/delete_recommend.png'),
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                IconButton(
                                    onPressed: () async {
                                      setState(() {
                                        isExpanded = false;
                                        radiusSlider = false;
                                        pressToGetRecommend = false;
                                        radiusValue = 3000.0;
                                        _circles = {};
                                        markers = {};
                                        allFavoritePlaces = [];
                                      });
                                      final GoogleMapController controller =
                                          await _googleMapController.future;
                                      controller.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                  target: currentLocationData ==
                                                          null
                                                      ? LatLng(latLng!.latitude,
                                                          latLng!.longitude)
                                                      : LatLng(
                                                          currentLocationData!
                                                              .latitude!,
                                                          currentLocationData!
                                                              .longitude!),
                                                  zoom: 12)));
                                    },
                                    icon: const Icon(Icons.close,
                                        color: Colors.red))
                              ]),
                            )))
                    : Container(),
                pressToGetRecommend
                    ? Positioned(
                        bottom: isExpanded ? 40.0 : 28.0,
                        child: SizedBox(
                          height: isExpanded ? 480.0 : 200.0,
                          width: MediaQuery.of(context).size.width,
                          child: PageView.builder(
                              controller: _pageController,
                              itemCount: allFavoritePlaces.length,
                              itemBuilder: (BuildContext context, int index) {
                                return _nearbyPlacesList(index);
                              }),
                        ))
                    : Container(),
              ],
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
      radiusSlider = true;
    });
  }

  _setNearMarker(LatLng point, String name, List types) async {
    var counter = markerIdCounter++;

    final Uint8List markerIcon;

    if (types.contains('bar')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/bars.png', 100);
    } else if (types.contains('car_rental') ||
        types.contains('car_repair') ||
        types.contains("electric_vehicle_charging_station") ||
        types.contains("gas_station") ||
        types.contains("parking") ||
        types.contains("rest_stop")) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/car.png', 100);
    } else if (types.contains('bakery')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/cake-shop.png', 100);
    } else if (types.contains('clothing_store')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/clothings.png', 100);
    } else if (types.contains('cafe') || types.contains('coffee_shop')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/coffee-n-tea.png', 100);
    } else if (types.contains('electronics_store')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/computers.png', 100);
    } else if (types.contains('night_club')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/dance-clubs.png', 100);
    } else if (types.contains('doctor')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/doctors.png', 100);
    } else if (types.contains('bowling_alley ') ||
        types.contains('zoo') ||
        types.contains('amusement_park') ||
        types.contains("amusement_center") ||
        types.contains("aquarium")) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/karaoke.png', 100);
    } else if (types.contains('bank') ||
        types.contains('atm') ||
        types.contains('finance') ||
        types.contains('accounting')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/financial-services.png', 100);
    } else if (types.contains('food') ||
        types.contains('meal_takeaway') ||
        types.contains('meal_delivery')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/food.png', 100);
    } else if (types.contains('health') ||
        types.contains('hospital') ||
        types.contains('drugstore')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/health-medical.png', 100);
    } else if (types.contains('lodging') ||
        types.contains("bed_and_breakfast") ||
        types.contains("campground") ||
        types.contains("camping_cabin") ||
        types.contains("extended_stay_hotel") ||
        types.contains("guest_house") ||
        types.contains("hostel") ||
        types.contains("hotel") ||
        types.contains("motel") ||
        types.contains("private_guest_room") ||
        types.contains("resort_hotel") ||
        types.contains("rv_park")) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/hotels.png', 100);
    } else if (types.contains('library') || types.contains('book_store')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/libraries.png', 100);
    } else if (types.contains('spa')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/massage-therapy.png', 100);
    } else if (types.contains('pharmacy') ||
        types.contains("physiotherapist")) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/medical.png', 100);
    } else if (types.contains('movie_rental') ||
        types.contains('movie_theater')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/movies.png', 100);
    } else if (types.contains('museum') ||
        types.contains("art_gallery") ||
        types.contains("performing_arts_theater")) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/museums.png', 100);
    } else if (types.contains('park')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/places.png', 100);
    } else if (types.contains('restaurant')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/restaurants.png', 100);
    } else if (types.contains('store') || types.contains('shoe_store')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/retail-stores.png', 100);
    } else if (types.contains('beauty_salon') ||
        types.contains('hair_care') ||
        types.contains("barber_shop") ||
        types.contains("hair_salon")) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/saloon.png', 100);
    } else if (types.contains('school') ||
        types.contains('secondary_school') ||
        types.contains('university') ||
        types.contains(
          "preschool",
        ) ||
        types.contains("primary_school")) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/schools.png', 100);
    } else if (types.contains('supermarket') ||
        types.contains('convenience_store') ||
        types.contains('shopping_mall') ||
        types.contains('market') ||
        types.contains('store') ||
        types.contains('wholesaler')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/shopping.png', 100);
    } else if (types.contains('gym') ||
        types.contains('stadium') ||
        types.contains("athletic_field") ||
        types.contains("fitness_center") ||
        types.contains("golf_course") ||
        types.contains("playground") ||
        types.contains("ski_resort") ||
        types.contains("sports_club") ||
        types.contains("sports_complex") ||
        types.contains("swimming_pool")) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/sports.png', 100);
    } else if (types.contains('train_station') ||
        types.contains('travel_agency') ||
        types.contains("airport") ||
        types.contains("bus_station") ||
        types.contains("bus_stop") ||
        types.contains("ferry_terminal") ||
        types.contains("park_and_ride") ||
        types.contains("subway_station") ||
        types.contains('taxi_stand') ||
        types.contains('transit_station')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/tickets.png', 100);
    } else if (types.contains('tourist_attraction')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/tours.png', 100);
    } else if (types.contains('mosque') ||
        types.contains('church') ||
        types.contains('hindu_temple') ||
        types.contains('synagogue') ||
        types.contains('place_of_worship')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/religious.png', 100);
    } else {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/default.png', 100);
    }

    final Marker marker = Marker(
        markerId: MarkerId('marker_$counter'),
        infoWindow: InfoWindow(title: name),
        position: point,
        onTap: () {},
        icon: BitmapDescriptor.fromBytes(markerIcon));

    setState(() {
      markers.add(marker);
    });
  }

  void _addMarker(LatLng pos) async {
    if (origin == null || (origin != null && destination != null)) {
      // Origin is not set OR Origin/Destination are both set
      // Set origin
      setState(() {
        origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Start Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          position: pos,
        );
        destination = null;
        isExpandedOrigin = false;
        isExpandedDestination = false;
        // Reset info
        infoDistanceAndDuration = null;
      });
    } else {
      // Origin is already set
      // Set destination
      setState(() {
        destination = Marker(
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
          .getDirection(origin: origin!.position, destination: pos);
      setState(() => infoDistanceAndDuration = directions);
    }
  }

  _nearbyPlacesList(index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (BuildContext context, Widget? widget) {
        double value = 1;
        if (_pageController.position.haveDimensions) {
          value = (_pageController.page! - index);
          value = (1 - (value.abs() * 0.3) + 0.06).clamp(0.0, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) *
                MediaQuery.of(context).size.height *
                0.5,
            width: Curves.easeInOut.transform(value) * 350.0,
            child: widget,
          ),
        );
      },
      child: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTap: () async {
                isExpanded = !isExpanded;
                goToTappedPlace();
              },
              child: MapCard(
                  place: allFavoritePlaces[index],
                  isExpanded: isExpanded,
                  onExpandedChanged: (newIsExpanded) {
                    setState(() {
                      isExpanded = newIsExpanded;
                    });
                  },
                  photoGalleryIndex: photoGalleryIndex,
                  placeImage: placeImage),
            ),
          )
        ],
      ),
    );
  }
}
