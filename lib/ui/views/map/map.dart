import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:internet_praktikum/core/services/dashboardData.dart';
import 'package:internet_praktikum/core/services/placeApiProvider.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/views/map/directions.dart';
import 'package:internet_praktikum/ui/views/map/directions_repository.dart';
import 'package:internet_praktikum/core/services/map_service.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/mapWidgets/createWidgetFromMapToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/mapWidgets/mapButton.dart';
import 'package:internet_praktikum/ui/widgets/mapWidgets/smallButton.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _googleMapController = Completer();
  //TODO: Wenn schon CurrentLocationData existiert und man auf Directions Button oben links drückt, dann bewegt sich nur die Camera an den Marker

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
  String tokenKey = '';

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
  bool showBlankCard = false;
  bool isReviews = true;
  bool isPhotos = false;

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

  @override
  void initState() {
    super.initState();
    GoogleMapService().getLatLng().then((value) => setState(() {
          latLng = value;
          _initialCameraPosition = CameraPosition(
            target: latLng != null ? latLng! : const LatLng(0, 0),
            zoom: 11.5,
          );
        }));
    _pageController = PageController(initialPage: 1, viewportFraction: 0.85)
      ..addListener(_swipe);
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
      showBlankCard = false;
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
        isInitialCameraMove =
            false; // Markieren Sie, dass die erste Kamerabewegung abgeschlossen ist
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
              IconButton(
                icon: const Icon(Icons.directions_outlined,
                    color: Colors.black, size: 30),
                onPressed: () async {
                  setState(() {
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
                const Text(
                  'Vacation',
                  style: TextStyle(
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
                          color: Colors.red,
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
                                          tilt: 50.0,
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
                                          tilt: 50.0,
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
                                      tilt: 50.0,
                                    ),
                                  ),
                                );
                              },
                              onClose: () => setState(() => {
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

                                          final notInterests = userCollection
                                              .data()!['uninterested'];

                                          List<Place> places =
                                              await GoogleMapService()
                                                  .getPlacesNew(
                                                      tappedPointInCircle,
                                                      radiusValue.toInt(),
                                                      interests.cast<String>(),
                                                      notInterests
                                                          .cast<String>());

                                          if (places.isEmpty) {
                                            pressToGetRecommend = false;
                                            markers = {};
                                            // ignore: use_build_context_synchronously
                                            return ErrorSnackbar
                                                .showErrorSnackbar(
                                                    context, "No places found");
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
                                          });
                                        },
                                        icon: const ImageIcon(
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
                                    onPressed: () {
                                      setState(() {
                                        isExpanded = false;
                                        radiusSlider = false;
                                        pressToGetRecommend = false;
                                        radiusValue = 3000.0;
                                        _circles = {};
                                        markers = {};
                                        allFavoritePlaces = [];
                                      });
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

  _showReview(review) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
          child: Row(
            children: [
              Container(
                height: 35.0,
                width: 35.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(
                            review['authorAttribution']['photoUri']),
                        fit: BoxFit.cover)),
              ),
              const SizedBox(width: 4.0),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: 160.0,
                  child: Text(review['authorAttribution']['displayName'],
                      style: Styles.autorreview),
                ),
                const SizedBox(height: 3.0),
                RatingStars(
                  value: review['rating'] * 1.0,
                  starCount: 5,
                  starSize: 7,
                  starColor: Colors.white,
                  starOffColor: const Color(0xff9b9b9b),
                  valueLabelColor: const Color(0xff9b9b9b),
                  valueLabelTextStyle: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'WorkSans',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 9.0),
                  valueLabelRadius: 7,
                  maxValue: 5,
                  starSpacing: 2,
                  maxValueVisibility: false,
                  //mit der zeile unten drunten auch abschalten oder eher net ?
                  valueLabelVisibility: true,
                  animationDuration: const Duration(milliseconds: 1000),
                  valueLabelPadding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                  valueLabelMargin: const EdgeInsets.only(right: 4),
                )
              ])
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            review['text']['text'] ?? '',
            style: Styles.reviewtext,
          ),
        ),
        Divider(color: Colors.grey.shade600, height: 1.0)
      ],
    );
  }

  showPhoto(List<PlacePhoto> photoElement) {
    if (photoElement.isEmpty) {
      showBlankCard = true;
      return const Center(
        child: Text(
          'No Photos',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'WorkSans',
              fontSize: 12.0,
              fontWeight: FontWeight.w500),
        ),
      );
    } else {
      var tempDisplayIndex = photoGalleryIndex + 1;

      return Column(
        children: [
          const SizedBox(height: 5.0),
          Container(
              height: 250.0,
              width: 250.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                      image: photoElement[photoGalleryIndex].imageProvider,
                      fit: BoxFit.cover))),
          const SizedBox(height: 15.0),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            MySmallButton(
                borderColor: photoGalleryIndex == 0 ? Colors.red : Colors.green,
                onTap: () {
                  setState(() {
                    if (photoGalleryIndex != 0) {
                      photoGalleryIndex = photoGalleryIndex - 1;
                    } else {
                      photoGalleryIndex = 0;
                    }
                  });
                },
                text: "Prev"),
            Text(
              '$tempDisplayIndex/${photoElement.length}',
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'WorkSans',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500),
            ),
            MySmallButton(
                borderColor: photoGalleryIndex == photoElement.length - 1
                    ? Colors.red
                    : Colors.green,
                onTap: () {
                  setState(() {
                    if (photoGalleryIndex != photoElement.length - 1) {
                      photoGalleryIndex = photoGalleryIndex + 1;
                    } else {
                      photoGalleryIndex = photoElement.length - 1;
                    }
                  });
                },
                text: "Next"),
          ])
        ],
      );
    }
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
          .getBytesFromAsset('assets/map_icon/bars.png', 75);
    } else if (types.contains('bakery')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/cake-shop.png', 75);
    } else if (types.contains('clothing_store')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/clothings.png', 75);
    } else if (types.contains('cafe')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/coffee-n-tea.png', 75);
    } else if (types.contains('electronics_store')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/computers.png', 75);
    } else if (types.contains('night_club')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/dance-clubs.png', 75);
    } else if (types.contains('doctor')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/doctors.png', 75);
    } else if (types.contains('bowling_alley ') ||
        types.contains('zoo') ||
        types.contains('amusement_park')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/karaoke.png', 75);
    } else if (types.contains('art_gallery ')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/exhibitions.png', 75);
    } else if (types.contains('bank') ||
        types.contains('atm') ||
        types.contains('finance')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/financial-services.png', 75);
    } else if (types.contains('food')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/food.png', 75);
    } /* else if (types.contains('health') || types.contains('hospital')) { //TODO: Gym zählt auch ins health medical
    //WIE problem BEHEBEN ?? da es nicht nur health medical ist
    //z.B. bei Health medical zählt auch gym mit dazu aber wird nur als health medical png angezeigt statt ein eigenes gym png
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/health-medical.png', 75);
    }  */
    else if (types.contains('lodging')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/hotels.png', 75);
    } else if (types.contains('library') || types.contains('book_store')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/libraries.png', 75);
    } else if (types.contains('spa')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/massage-therapy.png', 75);
    } else if (types.contains('pharmacy') ||
        types.contains("physiotherapist")) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/medical.png', 75);
    } else if (types.contains('movie_rental') ||
        types.contains('movie_theater')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/movies.png', 75);
    } else if (types.contains('museum')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/museums.png', 75);
    } else if (types.contains('park')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/places.png', 75);
    } else if (types.contains('restaurant')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/restaurants.png', 75);
    } else if (types.contains('store') || types.contains('shoe_store')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/retail-stores.png', 75);
    } else if (types.contains('beauty_salon') || types.contains('hair_care')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/saloon.png', 75);
    } else if (types.contains('school') ||
        types.contains('secondary_school') ||
        types.contains('university')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/schools.png', 75);
    } else if (types.contains('supermarket') ||
        types.contains('convenience_store') ||
        types.contains('shopping_mall')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/shopping.png', 75);
    } else if (types.contains('gym') || types.contains('stadium')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/sports.png', 75);
    } else if (types.contains('train_station') ||
        types.contains('travel_agency')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/tickets.png', 75);
    } else if (types.contains('tourist_attraction')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/tours.png', 75);
    } else if (types.contains('mosque') ||
        types.contains('church') ||
        types.contains('hindu_temple') ||
        types.contains('synagogue') ||
        types.contains('place_of_worship')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/religious.png', 75);
    } else {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/default.png', 75);
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
              child: FlipCard(
                flipOnTouch: isExpanded ? true : false,
                front: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  height: isExpanded ? 500.0 : 125.0,
                  width: 325.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34.5),
                    color:
                        const Color.fromARGB(255, 43, 43, 43).withOpacity(0.90),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 18, right: 18, top: 14, bottom: 16),
                      child: Column(
                        children: [
                          isExpanded
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isExpanded = !isExpanded;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.white,
                                          size: 30,
                                        ))
                                  ],
                                )
                              : const SizedBox(width: 0, height: 0),
                          Row(
                            children: [
                              _pageController.position.haveDimensions
                                  ? _pageController.page!.toInt() == index
                                      ? Container(
                                          height: 90.0,
                                          width: 90.0,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              image: DecorationImage(
                                                  image: placeImage != ''
                                                      ? allFavoritePlaces[index]
                                                          .firstImage
                                                          .imageProvider
                                                      : Image.asset(
                                                              height: 80.0,
                                                              width: 80.0,
                                                              "assets/no_camera.png")
                                                          .image,
                                                  fit: BoxFit.cover),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 4,
                                              )),
                                        )
                                      : Container(
                                          height: 90.0,
                                          width: 10.0,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              color: Colors.white),
                                        )
                                  : Container(),
                              const SizedBox(width: 15.0),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 130.0,
                                    height: 50.0,
                                    child: Text(allFavoritePlaces[index].name,
                                        style: Styles.maptitle),
                                  ),
                                  RatingStars(
                                    value: allFavoritePlaces[index].rating,
                                    starCount: 5,
                                    starSize: 20,
                                    starColor: Colors.white,
                                    starOffColor: const Color(0xff9b9b9b),
                                    valueLabelColor: const Color(0xff9b9b9b),
                                    valueLabelTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'WorkSans',
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 12.0),
                                    valueLabelRadius: 10,
                                    maxValue: 5,
                                    starSpacing: 2,
                                    maxValueVisibility: false,
                                    valueLabelVisibility: false,
                                    animationDuration:
                                        const Duration(milliseconds: 3000),
                                    valueLabelPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 1, horizontal: 8),
                                    valueLabelMargin:
                                        const EdgeInsets.only(right: 8),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          isExpanded
                              ? const SizedBox(height: 20.0)
                              : Container(),
                          isExpanded
                              ? Container(
                                  padding: const EdgeInsets.all(7.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Address: ',
                                        style: Styles.mapadress,
                                      ),
                                      SizedBox(
                                          width: 150.0,
                                          child: Text(
                                            allFavoritePlaces[index]
                                                .formattedAddress,
                                            style: Styles.mapadressformatted,
                                          ))
                                    ],
                                  ),
                                )
                              : Container(),
                          isExpanded
                              ? Container(
                                  padding: const EdgeInsets.all(7.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Contact: ',
                                        style: Styles.mapcontact,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                          width: 150.0,
                                          child: Text(
                                            allFavoritePlaces[index]
                                                .internationalPhoneNumber,
                                            style: Styles.mapcontactformatted,
                                            overflow: TextOverflow.ellipsis,
                                          ))
                                    ],
                                  ),
                                )
                              : Container(),
                          isExpanded
                              ? Container(
                                  padding: const EdgeInsets.all(7.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Availability: ',
                                        style: Styles.mapcontact,
                                      ),
                                      SizedBox(
                                        width: 150.0,
                                        child: Text(
                                          allFavoritePlaces[index]
                                                      .buisnessStatus ==
                                                  'OPERATIONAL'
                                              ? 'Operational '
                                              : allFavoritePlaces[index]
                                                          .buisnessStatus ==
                                                      'CLOSED_TEMPORARILY'
                                                  ? "Closed temporarily"
                                                  : allFavoritePlaces[index]
                                                              .buisnessStatus ==
                                                          'CLOSED_PERMANENTLY'
                                                      ? "Closed permanently"
                                                      : 'None given',
                                          style: TextStyle(
                                              color: allFavoritePlaces[index]
                                                          .buisnessStatus ==
                                                      'OPERATIONAL'
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Ubuntu'),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          isExpanded
                              ? const SizedBox(height: 20.0)
                              : Container(),
                          isExpanded
                              ? MyButton(
                                  onTap: () {
                                    CustomBottomSheet.show(context,
                                        title:
                                            "Add new Widget to your Dashboard",
                                        content: [
                                          FutureBuilder(
                                              future: Future.wait([
                                                DashBoardData.getUserData(),
                                              ]),
                                              builder: (context,
                                                  AsyncSnapshot<List<dynamic>>
                                                      snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                                if (snapshot.hasError) {
                                                  return const Center(
                                                    child: Text(
                                                        'An error occured!'),
                                                  );
                                                }
                                                return CreateWidgetFromMapToDashboard(
                                                    place: allFavoritePlaces[
                                                        index],
                                                    userdata:
                                                        snapshot.data![0]);
                                              })
                                        ]);
                                  },
                                  text: "Add to Dashboard")
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
                back: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  height: isExpanded ? 500.0 : 125.0,
                  width: 325.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34.5),
                    color:
                        const Color.fromARGB(255, 43, 43, 43).withOpacity(0.90),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: isExpanded
                          ? const EdgeInsets.all(8)
                          : EdgeInsets.zero,
                      child: isExpanded
                          ? Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      MySmallButton(
                                          onTap: () {
                                            setState(() {
                                              isReviews = true;
                                              isPhotos = false;
                                            });
                                          },
                                          text: 'Review'),
                                      MySmallButton(
                                          onTap: () {
                                            setState(() {
                                              isReviews = false;
                                              isPhotos = true;
                                            });
                                          },
                                          text: 'Photos'),
                                    ],
                                  ),
                                ),
                                isExpanded
                                    ? SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        child: isReviews
                                            ? ListView(
                                                children: [
                                                  if (isReviews)
                                                    ...allFavoritePlaces[index]
                                                        .reviews
                                                        .map((e) {
                                                      return _showReview(e);
                                                    })
                                                ],
                                              )
                                            : showPhoto(allFavoritePlaces[index]
                                                .photosElements))
                                    : Container(),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.only(
                                  left: 18, right: 18, top: 18, bottom: 16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      _pageController.position.haveDimensions
                                          ? _pageController.page!.toInt() ==
                                                  index
                                              ? Container(
                                                  height: 90.0,
                                                  width: 90.0,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      image: DecorationImage(
                                                          image: placeImage !=
                                                                  ''
                                                              ? allFavoritePlaces[
                                                                      index]
                                                                  .firstImage
                                                                  .imageProvider
                                                              : Image.asset(
                                                                      height:
                                                                          80.0,
                                                                      width:
                                                                          80.0,
                                                                      "assets/no_camera.png")
                                                                  .image,
                                                          fit: BoxFit.cover),
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 4,
                                                      )),
                                                )
                                              : Container(
                                                  height: 90.0,
                                                  width: 10.0,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                      color: Colors.white),
                                                )
                                          : Container(),
                                      const SizedBox(width: 15.0),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 130.0,
                                            height: 50.0,
                                            child: Text(
                                                allFavoritePlaces[index].name,
                                                style: Styles.maptitle),
                                          ),
                                          RatingStars(
                                            value:
                                                allFavoritePlaces[index].rating,
                                            starCount: 5,
                                            starSize: 20,
                                            starColor: Colors.white,
                                            starOffColor:
                                                const Color(0xff9b9b9b),
                                            valueLabelColor:
                                                const Color(0xff9b9b9b),
                                            valueLabelTextStyle:
                                                const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'WorkSans',
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 12.0),
                                            valueLabelRadius: 10,
                                            maxValue: 5,
                                            starSpacing: 2,
                                            maxValueVisibility: false,
                                            valueLabelVisibility: false,
                                            animationDuration: const Duration(
                                                milliseconds: 3000),
                                            valueLabelPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 1, horizontal: 8),
                                            valueLabelMargin:
                                                const EdgeInsets.only(right: 8),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
