import 'dart:async';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:internet_praktikum/core/services/placeApiProvider.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/views/map/directions.dart';
import 'package:internet_praktikum/ui/views/map/directions_repository.dart';
import 'package:internet_praktikum/core/services/map_service.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/createNewWidgetOnDashboard.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:internet_praktikum/ui/widgets/mapWidgets/smallButton.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
//import 'package:internet_praktikum/ui/widgets/inputfield_search_lookahead.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //TODO: Wenn noch Zeit fixen das beim swipe daten in realtime aktualisert werden !!!
  //TODO: BACK FLIPCARD darf nicht swipen sonst kommt ein Fehler, vor swipen wird back auf front gesetzt.
  //TODO autoklicker bei den Swipes d,h, damit GestureDetector von allein getriggert wird
  final Completer<GoogleMapController> _googleMapController = Completer();
  static const key = "AIzaSyBUh4YsufaUkM8XQqdO8TSXKpBf_3dJOmA";

  Marker? origin;
  Marker? destination;
  Marker? currentLocation;
  Directions? infoDistanceAndDuration;
  LatLng? latLng;
  PlaceDetails? placeDetails;

  CameraPosition? _initialCameraPosition;

  //Marker
  Set<Marker> _markers = <Marker>{};

  int markerIdCounter = 1;

  //TODO

  //places
  List allFavoritePlaces = []; //TODO: Name ändern
  String tokenKey = '';

  //Circle
  Set<Circle> _circles = <Circle>{};
  var radiusValue = 3000.0;
  dynamic tappedPoint; //TODO: Name ändern

  //Toggling UI as we need;
  bool radiusSlider = false;
  bool pressedNear = false; //TODO: Name ändern

  //page Controller
  late PageController _pageController;
  int prevPage = 0; //TODO: Name ändern
  var tappedPlaceDetail;
  String placeImg = '';
  var photoGalleryIndex = 0;
  bool showBlankCard = false;
  bool isReviews = true;
  bool isPhotos = false;

  //expandable container
  bool isExpanded = false;

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
    if (_pageController.page!.toInt() != prevPage) {
      prevPage = _pageController.page!.toInt();
      photoGalleryIndex = 1;
      showBlankCard = false;
      isExpanded = false;
      goToTappedPlace();
      fetchImage();
    }
  }

  Future<void> goToTappedPlace() async {
    final GoogleMapController controller = await _googleMapController.future;

    _markers = {};

    var selectedPlace = allFavoritePlaces[_pageController.page!.toInt()];

    _setNearMarker(
      LatLng(selectedPlace['geometry']['location']['lat'],
          selectedPlace['geometry']['location']['lng']),
      selectedPlace['name'] ?? 'no name',
      selectedPlace['types'],
    );

    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(selectedPlace['geometry']['location']['lat'] + 0.015,
            selectedPlace['geometry']['location']['lng']),
        zoom: 14.0,
        bearing: 180.0,
        tilt: 45.0)));
  }

  void fetchImage() async {
    if (_pageController.page != null) {
      if (allFavoritePlaces[_pageController.page!.toInt()]['photos'] != null) {
        setState(() {
          placeImg = allFavoritePlaces[_pageController.page!.toInt()]['photos']
              [0]['photo_reference'];
        });
      }
    } else {
      placeImg = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Map',
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
            ),
          ),
          backgroundColor: Colors.transparent,
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Column(
                children: [
                  if (infoDistanceAndDuration == null &&
                      !radiusSlider &&
                      !pressedNear &&
                      !isExpanded &&
                      destination == null)
                    Container(
                      padding: const EdgeInsets.symmetric(),
                      child: origin == null
                          ? const Text(
                              'Tap to see personilized recomendations OR Long press to set origin and destination',
                              style: Styles.warningmap,
                              textAlign: TextAlign.center,
                            )
                          : const Text(
                              'Long press again to set destination',
                              style: Styles.warningmap,
                              textAlign: TextAlign.center,
                            ),
                    ),
                ],
              )),
          leading: IconButton(
            icon: const Icon(Icons.my_location, color: Colors.black, size: 30),
            onPressed: () async {
              currentLocation = await GoogleMapService()
                  .getCurrentLocation(_googleMapController);
              setState(() {
                currentLocation!.position.latitude == 0
                    ? currentLocation = null
                    : currentLocation = currentLocation;
              });
            },
          ),
          actions: [
            IconButton(
              onPressed: () async {
                var controller = await _googleMapController.future;
                controller.animateCamera(
                  infoDistanceAndDuration != null
                      ? CameraUpdate.newLatLngBounds(
                          infoDistanceAndDuration!.bounds, 100.0)
                      : CameraUpdate.newCameraPosition(_initialCameraPosition!),
                );
              },
              icon: const Icon(Icons.center_focus_strong),
            ),
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
                      if (currentLocation != null) currentLocation!,
                      ..._markers,
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
                      tappedPoint = point;
                      _setCircle(point);
                    },
                  ),
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
                        borderRadius: BorderRadius.circular(20.0),
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
                if (origin != null || currentLocation != null)
                  Positioned(
                      top: 90.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (origin != null)
                            Row(
                              children: [
                                MySmallButton(
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
                                ),
                                MySmallButton(
                                  iconData: Icons.close,
                                  borderColor: Colors.red,
                                  onTap: () => setState(() => {
                                        origin = null,
                                        destination = null,
                                        infoDistanceAndDuration = null,
                                      }),
                                ),
                              ],
                            ),
                          if (destination != null)
                            Row(
                              children: [
                                MySmallButton(
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
                                    }),
                                MySmallButton(
                                  iconData: Icons.close,
                                  borderColor: Colors.red,
                                  onTap: () => setState(() => {
                                        destination = null,
                                        infoDistanceAndDuration = null,
                                      }),
                                ),
                              ],
                            ),
                          if (currentLocation != null)
                            Row(
                              children: [
                                MySmallButton(
                                  colors: Colors.blue,
                                  text: "Cur",
                                  onTap: () async {
                                    var controller =
                                        await _googleMapController.future;
                                    controller.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: currentLocation!.position,
                                          zoom: 14.5,
                                          tilt: 50.0,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                MySmallButton(
                                  iconData: Icons.close,
                                  borderColor: Colors.red,
                                  onTap: () => setState(
                                    () => currentLocation = null,
                                  ),
                                ),
                              ],
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
                              height: MediaQuery.of(context).size.height *
                                  0.28, //TODO: Falls Navbar ändert sich, dann hier auch ändern wahrscheinlich
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
                                        pressedNear = false;
                                        if (tappedPoint != null) {
                                          _setCircle(tappedPoint!);
                                        }
                                      });
                                    },
                                  ),
                                )),
                                !pressedNear
                                    ? IconButton(
                                        onPressed: () async {
                                          var placesResult =
                                              await GoogleMapService()
                                                  .getPlaceDetails(tappedPoint,
                                                      radiusValue.toInt());

                                          List<dynamic> placesWithin =
                                              placesResult['results'] as List;

                                          allFavoritePlaces = placesWithin;

                                          tokenKey =
                                              placesResult['next_page_token'] ??
                                                  'none';
                                          _markers = {};
                                          for (var element in placesWithin) {
                                            /* bool isRecommened =
                                                getRecommend(element['types']);
                                            if (isRecommened) { */
                                            _setNearMarker(
                                              LatLng(
                                                  element['geometry']
                                                      ['location']['lat'],
                                                  element['geometry']
                                                      ['location']['lng']),
                                              element['name'],
                                              element['types'],
                                            );
                                            //}
                                          }
                                          //filterDefaultMarker(_markers);
                                          pressedNear = true;
                                          if (allFavoritePlaces[1]['photos'] !=
                                              null) {
                                            setState(() {
                                              placeImg = allFavoritePlaces[1]
                                                      ['photos'][0]
                                                  ['photo_reference'];
                                            });
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.near_me,
                                          color: Colors.blue,
                                        ))
                                    : IconButton(
                                        onPressed: () async {
                                          if (tokenKey != 'none') {
                                            var placesResult =
                                                await GoogleMapService()
                                                    .getMorePlaceDetails(
                                                        tokenKey);

                                            List<dynamic> placesWithin =
                                                placesResult['results'] as List;

                                            allFavoritePlaces
                                                .addAll(placesWithin);

                                            tokenKey = placesResult[
                                                    'next_page_token'] ??
                                                'none';

                                            for (var element in placesWithin) {
                                              /*  bool isRecommened = getRecommend(
                                                  element['types']);
                                              if (isRecommened) { */
                                              _setNearMarker(
                                                LatLng(
                                                    element['geometry']
                                                        ['location']['lat'],
                                                    element['geometry']
                                                        ['location']['lng']),
                                                element['name'],
                                                element['types'],
                                              );
                                              //}
                                            }
                                            // filterDefaultMarker(_markers);
                                          } else {
                                            ErrorSnackbar.showErrorSnackbar(
                                                context,
                                                "No more places available");
                                          }
                                        },
                                        icon: const Icon(Icons.more_time,
                                            color: Colors.blue)),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isExpanded = false;
                                        radiusSlider = false;
                                        pressedNear = false;
                                        radiusValue = 3000.0;
                                        _circles = {};
                                        _markers = {};
                                        allFavoritePlaces = [];
                                      });
                                    },
                                    icon: const Icon(Icons.close,
                                        color: Colors.red))
                              ]),
                            )))
                    : Container(),
                pressedNear
                    ? Positioned(
                        bottom: 20.0,
                        child: SizedBox(
                          height: isExpanded ? 500.0 : 200.0,
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
                        image: NetworkImage(review['profile_photo_url']),
                        fit: BoxFit.cover)),
              ),
              const SizedBox(width: 4.0),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: 160.0,
                  child: Text(review['author_name'], style: Styles.autorreview),
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
            review['text'],
            style: Styles.reviewtext,
          ),
        ),
        Divider(color: Colors.grey.shade600, height: 1.0)
      ],
    );
  }

  showPhoto(photoElement) {
    if (photoElement == null || photoElement.length == 0) {
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
      var placeImg = photoElement[photoGalleryIndex]['photo_reference'];
      var maxWidth = photoElement[photoGalleryIndex]['width'];
      var maxHeight = photoElement[photoGalleryIndex]['height'];
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
                      image: NetworkImage(
                          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&maxheight=$maxHeight&photo_reference=$placeImg&key=$key'),
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
    } else if (types.contains('health') || types.contains('hospital')) {
      markerIcon = await GoogleMapService()
          .getBytesFromAsset('assets/map_icon/health-medical.png', 75);
    } else if (types.contains('lodging')) {
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
      _markers.add(marker);
    });
  }

  Future<void> filterDefaultMarker(Set<Marker> markers) async {
    //TODO: Funktioniert noch nicht, es soll die default marker entfernen
    Uint8List markerIcon = await GoogleMapService()
        .getBytesFromAsset('assets/map_icon/default.png', 75);

    for (var element in markers) {
      if (element.icon == BitmapDescriptor.fromBytes(markerIcon)) {
        markers.remove(element);
      }
    }
  }

  bool getRecommend(List<dynamic> element) {
    for (var type in element) {
      if (type == 'bar') {
        print(type);
        return true;
      }
    }
    return false;
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
                if (isExpanded) {
                  tappedPlaceDetail = await GoogleMapService()
                      .getPlace(allFavoritePlaces[index]['place_id']);
                  setState(() {
                    fetchImage();
                  });
                }
              },
              child: FlipCard(
                //TODO: vlt die FlipDirection auf Vertoical ändern tim entscheidet

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
                          left: 18, right: 18, top: 18, bottom: 16),
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
                                                  image: placeImg != ''
                                                      ? NetworkImage(
                                                          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$placeImg&key=$key')
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
                                    child: Text(
                                        allFavoritePlaces[index]['name'],
                                        style: Styles.maptitle),
                                  ),
                                  RatingStars(
                                    value: allFavoritePlaces[index]['rating']
                                                .runtimeType ==
                                            int
                                        ? allFavoritePlaces[index]['rating'] *
                                            1.0
                                        : allFavoritePlaces[index]['rating'] ??
                                            0.0,
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
                                      tappedPlaceDetail != null
                                          ? SizedBox(
                                              width: 150.0,
                                              child: Text(
                                                tappedPlaceDetail[
                                                        'formatted_address'] ??
                                                    'none given',
                                                style:
                                                    Styles.mapadressformatted,
                                              ))
                                          : const Column(
                                              children: [
                                                Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                              ],
                                            ),
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
                                      ),
                                      tappedPlaceDetail != null
                                          ? SizedBox(
                                              width: 150.0,
                                              child: Text(
                                                tappedPlaceDetail[
                                                        'formatted_phone_number'] ??
                                                    'none given',
                                                style:
                                                    Styles.mapcontactformatted,
                                              ))
                                          : const Column(
                                              children: [
                                                Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                              ],
                                            ),
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
                                      //TODO: Hier nur da wegen types testen
                                      /*        Text(
                                        allFavoritePlaces[0]['types'][0],
                                        style: TextStyle(
                                            color: allFavoritePlaces[index]
                                                        ['business_status'] ==
                                                    'OPERATIONAL'
                                                ? Colors.green
                                                : Colors.red,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Ubuntu'),
                                      ), */
                                      SizedBox(
                                        width: 150.0,
                                        child: Text(
                                          allFavoritePlaces[index]
                                                      ['business_status'] ==
                                                  'OPERATIONAL'
                                              ? 'Open '
                                              : allFavoritePlaces[index]
                                                          ['business_status'] ==
                                                      'CLOSED_TEMPORARILY'
                                                  ? "Closed temporarily"
                                                  : allFavoritePlaces[index][
                                                              'business_status'] ==
                                                          'CLOSED_PERMANENTLY'
                                                      ? "Closed permanently"
                                                      : 'None given',
                                          style: TextStyle(
                                              color: allFavoritePlaces[index]
                                                          ['business_status'] ==
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
                                              future: Future.wait([]),
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
                                                return CreateNewWidgetOnDashboard(
                                                    day: snapshot.data![1],
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
                      padding: const EdgeInsets.all(8),
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
                                        child: tappedPlaceDetail != null
                                            ? isReviews
                                                ? ListView(
                                                    children: [
                                                      if (isReviews &&
                                                          tappedPlaceDetail[
                                                                  'reviews'] !=
                                                              null)
                                                        ...tappedPlaceDetail[
                                                                'reviews']!
                                                            .map((e) {
                                                          return _showReview(e);
                                                        })
                                                    ],
                                                  )
                                                : showPhoto(tappedPlaceDetail[
                                                        'photos'] ??
                                                    [])
                                            : const Column(
                                                children: [
                                                  Center(
                                                      child:
                                                          CircularProgressIndicator())
                                                ],
                                              ),
                                      )
                                    : Container(),
                              ],
                            )
                          : Container(),
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
