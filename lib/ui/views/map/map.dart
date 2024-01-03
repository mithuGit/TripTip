import 'dart:async';
import 'dart:ui' as ui;
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:internet_praktikum/core/services/placeApiProvider.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/views/map/directions.dart';
import 'package:internet_praktikum/ui/views/map/directions_repository.dart';
import 'package:internet_praktikum/core/services/map_service.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
//import 'package:internet_praktikum/ui/widgets/inputfield_search_lookahead.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _googleMapController = Completer();
  static const key = "AIzaSyBUh4YsufaUkM8XQqdO8TSXKpBf_3dJOmA";

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
  Set<Circle> _circles = <Circle>{};
  var radiusValue = 3000.0;
  dynamic tappedPoint;
  Timer? _debounce;

  //Toggling UI as we need;
  bool searchToggle = false;
  bool radiusSlider = false;
  bool cardTapped = false;
  bool pressedNear = false;
  bool getDirections = false;

  //page Controller
  late PageController _pageController;
  int prevPage = 0;
  dynamic tappedPlaceDetail;
  String placeImg = '';
  var photoGalleryIndex = 0;
  bool showBlankCard = false;
  bool isReviews = true;
  bool isPhotos = false;

  //expandable container
  bool isExpanded = false;

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
    _pageController = PageController(initialPage: 1, viewportFraction: 0.85)
      ..addListener(_swipe);
  }

  @override
  void dispose() {
    //_googleMapController?.dispose(); //TODO: brauch ich das?
    super.dispose();
  }

  void _swipe() {
    if (_pageController.page!.toInt() != prevPage) {
      prevPage = _pageController.page!.toInt();
      cardTapped = false;
      photoGalleryIndex = 1;
      showBlankCard = false;
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
        selectedPlace['business_status'] ?? 'none');

    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(selectedPlace['geometry']['location']['lat'],
            selectedPlace['geometry']['location']['lng']),
        zoom: 14.0,
        bearing: 45.0,
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
      body: _initialCameraPosition == null
          ? const Column(
              //TODO: maybe ein Bild mit Animation für Loading Screen
              children: [
                SizedBox(height: 100),
                Center(child: CircularProgressIndicator()),
                SizedBox(height: 20),
                Center(child: Text('Loading Map')),
              ],
            )
          : Stack(
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
                                      _debounce = Timer(
                                          const Duration(seconds: 2), () async {
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
                                      _debounce = Timer(
                                          const Duration(seconds: 2), () async {
                                        if (tokenKey != 'none') {
                                          var placesResult =
                                              await GoogleMapService()
                                                  .getMorePlaceDetails(
                                                      tokenKey);

                                          List<dynamic> placesWithin =
                                              placesResult['results'] as List;

                                          allFavoritePlaces
                                              .addAll(placesWithin);

                                          tokenKey =
                                              placesResult['next_page_token'] ??
                                                  'none';

                                          for (var element in placesWithin) {
                                            _setNearMarker(
                                              LatLng(
                                                  element['geometry']
                                                      ['location']['lat'],
                                                  element['geometry']
                                                      ['location']['lng']),
                                              element['name'],
                                              element['types'],
                                              element['business_status'] ??
                                                  'not available',
                                            );
                                          }
                                        } else {
                                          ErrorSnackbar.showErrorSnackbar(
                                              context,
                                              "No more places available");
                                        }
                                      });
                                    },
                                    icon: const Icon(Icons.more_time,
                                        color: Colors.blue)),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    radiusSlider = false;
                                    pressedNear = false;
                                    cardTapped = false;
                                    radiusValue = 3000.0;
                                    _circles = {};
                                    _markers = {};
                                    allFavoritePlaces = [];
                                  });
                                },
                                icon:
                                    const Icon(Icons.close, color: Colors.red))
                          ]),
                        ))
                    : Container(),
                pressedNear
                    ? Positioned(
                        bottom: 20.0,
                        child: SizedBox(
                          height: isExpanded
                              ? 500.0
                              : 200.0, // TODO: Hier kann man die Höhe der Karte einstellen
                          width: MediaQuery.of(context).size.width,
                          child: PageView.builder(
                              controller: _pageController,
                              itemCount: allFavoritePlaces.length,
                              itemBuilder: (BuildContext context, int index) {
                                return _nearbyPlacesList(index);
                              }),
                        ))
                    : Container(),
                cardTapped
                    ? Positioned(
                        top: 100.0,
                        left: 15.0,
                        child: FlipCard(
                          front: Container(
                            height: 250.0,
                            width: 175.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: const Color.fromARGB(255, 43, 43, 43)
                                  .withOpacity(0.90),
                            ),
                            child: SingleChildScrollView(
                              child: Column(children: [
                                Container(
                                  height: 150.0,
                                  width: 175.0,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8.0),
                                        topRight: Radius.circular(8.0),
                                      ),
                                      image: DecorationImage(
                                          image: NetworkImage(placeImg != ''
                                              ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$placeImg&key=$key'
                                              : 'https://pic.onlinewebfonts.com/svg/img_546302.png'),
                                          fit: BoxFit.cover)),
                                ),
                                Container(
                                  padding: EdgeInsets.all(7.0),
                                  width: 175.0,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Address: ',
                                        style: Styles.mapadress,
                                      ),
                                      Container(
                                          width: 105.0,
                                          child: Text(
                                            tappedPlaceDetail[
                                                    'formatted_address'] ??
                                                'none given',
                                            style: Styles.mapadressformatted,
                                          ))
                                    ],
                                  ),
                                ),
                                Container(
                                  padding:
                                      EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 0.0),
                                  width: 175.0,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Contact: ',
                                        style: Styles.mapcontact,
                                      ),
                                      Container(
                                          width: 105.0,
                                          child: Text(
                                            tappedPlaceDetail[
                                                    'formatted_phone_number'] ??
                                                'none given',
                                            style: Styles.mapcontactformatted,
                                          ))
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                          ),
                          back: Container(
                            height: 300.0,
                            width: 225.0,
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 43, 43, 43)
                                    .withOpacity(0.90),
                                borderRadius: BorderRadius.circular(8.0)),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isReviews = true;
                                            isPhotos = false;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 700),
                                          curve: Curves.easeIn,
                                          padding: EdgeInsets.fromLTRB(
                                              7.0, 4.0, 7.0, 4.0),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(11.0),
                                              // entscheid du ma
                                              color: isReviews
                                                  ? Colors.green.shade300
                                                  : Colors.white),
                                          child: Text(
                                            'Reviews',
                                            style: TextStyle(
                                                color: isReviews
                                                    ? Colors.white
                                                    : Colors.black87,
                                                fontFamily: 'WorkSans',
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isReviews = false;
                                            isPhotos = true;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 700),
                                          curve: Curves.easeIn,
                                          padding: EdgeInsets.fromLTRB(
                                              7.0, 4.0, 7.0, 4.0),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(11.0),
                                              color: isPhotos
                                                  ? Colors.green.shade300
                                                  : Colors.white),
                                          child: Text(
                                            'Photos',
                                            style: TextStyle(
                                                color: isPhotos
                                                    ? Colors.white
                                                    : Colors.black87,
                                                fontFamily: 'WorkSans',
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 250.0,
                                  child: isReviews
                                      ? ListView(
                                          children: [
                                            if (isReviews &&
                                                tappedPlaceDetail['reviews'] !=
                                                    null)
                                              ...tappedPlaceDetail['reviews']!
                                                  .map((e) {
                                                return _buildReviewItem(e);
                                              })
                                          ],
                                        )
                                      : _buildPhotoGallery(
                                          tappedPlaceDetail['photos'] ?? []),
                                )
                              ],
                            ),
                          ),
                        ))
                    : Container(),
              ],
            ),
      /*  floatingActionButton: FloatingActionButton(
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
      ),*/
    );
  }

  _buildReviewItem(review) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
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
                Container(
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
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Text(
              review['text'],
              style: Styles.reviewtext,
            ),
          ),
        ),
        Divider(color: Colors.grey.shade600, height: 1.0)
      ],
    );
  }

  _buildPhotoGallery(photoElement) {
    if (photoElement == null || photoElement.length == 0) {
      showBlankCard = true;
      return Container(
        child: const Center(
          child: Text(
            'No Photos',
            style: TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 12.0,
                fontWeight: FontWeight.w500),
          ),
        ),
      );
    } else {
      var placeImg = photoElement[photoGalleryIndex]['photo_reference'];
      var maxWidth = photoElement[photoGalleryIndex]['width'];
      var maxHeight = photoElement[photoGalleryIndex]['height'];
      var tempDisplayIndex = photoGalleryIndex + 1;

      return Column(
        children: [
          const SizedBox(height: 10.0),
          Container(
              height: 200.0,
              width: 200.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                      image: NetworkImage(
                          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&maxheight=$maxHeight&photo_reference=$placeImg&key=$key'),
                      fit: BoxFit.cover))),
          const SizedBox(height: 10.0),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (photoGalleryIndex != 0)
                    photoGalleryIndex = photoGalleryIndex - 1;
                  else
                    photoGalleryIndex = 0;
                });
              },
              child: Container(
                width: 40.0,
                height: 20.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9.0),
                    color: photoGalleryIndex != 0
                        ? Colors.green.shade500
                        : Colors.grey.shade500),
                child: const Center(
                  child: Text(
                    'Prev',
                    style: TextStyle(
                        fontFamily: 'WorkSans',
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            Text(
              '$tempDisplayIndex/' + photoElement.length.toString(),
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'WorkSans',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (photoGalleryIndex != photoElement.length - 1)
                    photoGalleryIndex = photoGalleryIndex + 1;
                  else
                    photoGalleryIndex = photoElement.length - 1;
                });
              },
              child: Container(
                width: 40.0,
                height: 20.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9.0),
                    color: photoGalleryIndex != photoElement.length - 1
                        ? Colors.green.shade500
                        : Colors.grey.shade500),
                child: const Center(
                  child: Text(
                    'Next',
                    style: TextStyle(
                        fontFamily: 'WorkSans',
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
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
      getDirections = false;
      searchToggle = false;
      radiusSlider = true;
    });
  }

  _setNearMarker(LatLng point, String label, List types, String status) async {
    var counter = markerIdCounter++;

    final Uint8List markerIcon;

    if (types.contains('bars')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/bars.png', 75);
    } else if (types.contains('breakfast')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/breakfast-n-brunch.png', 75);
    } else if (types.contains('cake')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/cake-shop.png', 75);
    } else if (types.contains('clothings')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/clothings.png', 75);
    } else if (types.contains('clubs')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/clubs.png', 75);
    } else if (types.contains('coffee')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/coffee-n-tea.png', 75);
    } else if (types.contains('commercial ')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/commercial-places.png', 75);
    } else if (types.contains('computers ')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/computers.png', 75);
    } else if (types.contains('concerts')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/concerts.png', 75);
    } else if (types.contains('dance clubs')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/dance-clubs.png', 75);
    } else if (types.contains('doctors')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/doctors.png', 75);
    } else if (types.contains('entertainment ')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/entertainment.png', 75);
    } else if (types.contains('event')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/event.png', 75);
    } else if (types.contains('exhibitions ')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/exhibitions.png', 75);
    } else if (types.contains('fashion')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/fashion.png', 75);
    } else if (types.contains('festivals')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/festivals.png', 75);
    } else if (types.contains('financial ')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/financial-services.png', 75);
    } else if (types.contains('food')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/food.png', 75);
    } else if (types.contains('games')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/games.png', 75);
    } else if (types.contains('halloween')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/halloween.png', 75);
    } else if (types.contains('health medical')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/health-medical.png', 75);
    } else if (types.contains('hotels')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/hotels.png', 75);
    } else if (types.contains('internet')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/internet.png', 75);
    } else if (types.contains('karaoke')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/karaoke.png', 75);
    } else if (types.contains('libraries')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/libraries.png', 75);
    } else if (types.contains('massage')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/massage-therapy.png', 75);
    } else if (types.contains('medical')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/medical.png', 75);
    } else if (types.contains('medical')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/medical.png', 75);
    } else if (types.contains('movies')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/movies.png', 75);
    } else if (types.contains('museums')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/museums.png', 75);
    } else if (types.contains('nightlife ')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/nightlife.png', 75);
    } else if (types.contains('parties')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/parties.png', 75);
    } else if (types.contains('pizza')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/pizza.png', 75);
    } else if (types.contains('places')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/places.png', 75);
    } else if (types.contains('pool haals')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/pool-haals.png', 75);
    } else if (types.contains('restaurants')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/restaurants.png', 75);
    } else if (types.contains('retail stores')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/retail-stores.png', 75);
    } else if (types.contains('saloon')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/saloon.png', 75);
    } else if (types.contains('schools')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/schools.png', 75);
    } else if (types.contains('shopping')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/shopping.png', 75);
    } else if (types.contains('sports')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/sports.png', 75);
    } else if (types.contains('swimming pools')) {
      markerIcon =
          await getBytesFromAsset('assets/map_icon/swimming-pools.png', 75);
    } else if (types.contains('tickets')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/tickets.png', 75);
    } else if (types.contains('tours')) {
      markerIcon = await getBytesFromAsset('assets/map_icon/tours.png', 75);
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
      child: InkWell(
        onTap: () async {
          cardTapped = !cardTapped;
          if (cardTapped) {
            tappedPlaceDetail = await GoogleMapService()
                .getPlace(allFavoritePlaces[index]['place_id']);
            setState(() {});
          }
          moveCameraSlightly();
        },
        child: Stack(
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  height: isExpanded ? 900.0 : 125.0,
                  width: 325.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34.5),
                    color:
                        const Color.fromARGB(255, 43, 43, 43).withOpacity(0.90),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                                                image: NetworkImage(placeImg !=
                                                        ''
                                                    //TODO erstes bild in map wird nicht angezeigt und immer default kamera
                                                    ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$placeImg&key=$key'
                                                    : 'https://pic.onlinewebfonts.com/svg/img_546302.png'), //TODO anderes Bild für Default nehmen sonst so ähnlich
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 130.0,
                                  height: 50.0,
                                  child: Text(allFavoritePlaces[index]['name'],
                                      style: Styles.maptitle),
                                ),
                                RatingStars(
                                  value: allFavoritePlaces[index]['rating']
                                              .runtimeType ==
                                          int
                                      ? allFavoritePlaces[index]['rating'] * 1.0
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
                                  //TODO Demokratie abstimmung mit text an sternen oder nicht !!!!!!!!!!!
                                  valueLabelVisibility: false,
                                  animationDuration:
                                      const Duration(milliseconds: 3000),
                                  valueLabelPadding: const EdgeInsets.symmetric(
                                      vertical: 1, horizontal: 8),
                                  valueLabelMargin:
                                      const EdgeInsets.only(right: 8),
                                ),
                              ],
                            ),
                          ],
                        ),
                        isExpanded ? const SizedBox(height: 10.0) : Container(),
                        isExpanded
                            ? Container(
                                child: const Row(
                                  children: [
                                    Text(
                                      'Address: ',
                                      style: TextStyle(
                                          fontFamily: 'WorkSans',
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                    SizedBox(
                                        width: 105.0,
                                        child: Text(
                                          "Hello", //TODO: hier noch änder
                                          style: TextStyle(
                                              fontFamily: 'WorkSans',
                                              fontSize: 11.0,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white),
                                        ))
                                  ],
                                ),
                              )
                            : Container(),
                        isExpanded
                            ? Container(
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Contact: ',
                                      style: TextStyle(
                                          fontFamily: 'WorkSans',
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                    SizedBox(
                                        width: 105.0,
                                        child: Text(
                                          "Hello", //TODO: hier noch änder
                                          style: TextStyle(
                                              fontFamily: 'WorkSans',
                                              fontSize: 11.0,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white),
                                        ))
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> moveCameraSlightly() async {
    final GoogleMapController controller = await _googleMapController.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(
            allFavoritePlaces[_pageController.page!.toInt()]['geometry']
                    ['location']['lat'] +
                0.0125,
            allFavoritePlaces[_pageController.page!.toInt()]['geometry']
                    ['location']['lng'] +
                0.005),
        zoom: 14.0,
        bearing: 45.0,
        tilt: 45.0)));
  }
}
