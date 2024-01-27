import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:internet_praktikum/core/services/dashboardData.dart';
import 'package:internet_praktikum/core/services/map_service.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/mapWidgets/smallButton.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/mapWidgets/createWidgetFromMapToDashboard.dart';

// ignore: must_be_immutable
class MapCard extends StatefulWidget {
  final Place place;
  final Function(bool) onExpandedChanged;
  bool isExpanded;
  int photoGalleryIndex;
  String placeImage;
  MapCard(
      {super.key,
      required this.place,
      required this.isExpanded,
      required this.photoGalleryIndex,
      required this.placeImage,
      required this.onExpandedChanged});

  @override
  State<MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {
  bool isReviews = true;
  bool isPhotos = false;
  bool showBlankCard = false;

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
            review['text'] != null ? review['text']['text'] ?? '' : '',
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
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      return Column(
        children: [
          const SizedBox(height: 20.0),
          SizedBox(
            height: 270.0,
            width: 275.0,
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: photoElement.length,
              controller: PageController(
                initialPage: 0,
              ),
              onPageChanged: (index) {
                setState(() {
                  widget.photoGalleryIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Container(
                      height: 250.0,
                      width: 250.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white,
                          width: 4.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 250.0,
                          width: 250.0,
                          child: Image(
                            image: photoElement[index].imageProvider,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return CircularProgressIndicator(
                                  color: Colors.white,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Text(
            "${widget.photoGalleryIndex + 1}/${photoElement.length}",
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Ubuntu',
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5.0),
          const Icon(
            Icons.swipe_vertical,
            color: Colors.white,
            size: 22.0,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      flipOnTouch: widget.isExpanded ? true : false,
      front: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        height: widget.isExpanded ? 500.0 : 125.0,
        width: 325.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34.5),
          color: const Color.fromARGB(255, 43, 43, 43).withOpacity(0.90),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                widget.isExpanded
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.onExpandedChanged(!widget.isExpanded);
                                  widget.isExpanded = !widget.isExpanded;
                                });
                              },
                              icon: Image.asset(
                                  "assets/moveModalDown_white.png",
                                  height: 45.0,
                                  width: 45.0)),
                        ],
                      )
                    : const SizedBox(width: 0, height: 0),
                Row(
                  children: [
                    Container(
                      height: 90.0,
                      width: 90.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          widget.placeImage != ''
                              ? widget.place.firstImage.imageProviderAsUrl
                              : 'assets/no_camera.png', // Fallback to 'no_camera.png' if widget.placeImage is empty
                          fit: BoxFit.cover,
                          height: 80.0,
                          width: 80.0,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 130.0,
                          height: 50.0,
                          child:
                              Text(widget.place.name, style: Styles.maptitle),
                        ),
                        RatingStars(
                          value: widget.place.rating,
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
                          animationDuration: const Duration(milliseconds: 3000),
                          valueLabelPadding: const EdgeInsets.symmetric(
                              vertical: 1, horizontal: 8),
                          valueLabelMargin: const EdgeInsets.only(right: 8),
                        ),
                      ],
                    ),
                  ],
                ),
                widget.isExpanded ? const SizedBox(height: 20.0) : Container(),
                widget.isExpanded
                    ? Container(
                        padding: const EdgeInsets.all(7.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Address: ',
                              style: Styles.mapadress,
                            ),
                            Flexible(
                              child: SizedBox(
                                width: 150.0,
                                child: Text(
                                  widget.place.formattedAddress,
                                  style: Styles.mapadressformatted,
                                  maxLines: 4,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : Container(),
                widget.isExpanded
                    ? Container(
                        padding: const EdgeInsets.all(7.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Contact: ',
                              style: Styles.mapcontact,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                                width: 150.0,
                                child: Text(
                                  widget.place.internationalPhoneNumber,
                                  style: Styles.mapcontactformatted,
                                  overflow: TextOverflow.ellipsis,
                                ))
                          ],
                        ),
                      )
                    : Container(),
                widget.isExpanded
                    ? Container(
                        padding: const EdgeInsets.all(7.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Availability: ',
                              style: Styles.mapcontact,
                            ),
                            SizedBox(
                              width: 150.0,
                              child: Text(
                                widget.place.buisnessStatus == 'OPERATIONAL'
                                    ? 'Operational '
                                    : widget.place.buisnessStatus ==
                                            'CLOSED_TEMPORARILY'
                                        ? "Closed temporarily"
                                        : widget.place.buisnessStatus ==
                                                'CLOSED_PERMANENTLY'
                                            ? "Closed permanently"
                                            : 'None given',
                                style: TextStyle(
                                    color: widget.place.buisnessStatus ==
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
                widget.isExpanded ? const SizedBox(height: 20.0) : Container(),
                widget.isExpanded
                    ? MyButton(
                        onTap: () {
                          CustomBottomSheet.show(context,
                              title: "Add new Widget to your Dashboard",
                              content: [
                                FutureBuilder(
                                    future: Future.wait([
                                      DashBoardData.getUserData(),
                                    ]),
                                    builder: (context,
                                        AsyncSnapshot<List<dynamic>> snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        return const Center(
                                          child: Text('An error occured!'),
                                        );
                                      }
                                      return CreateWidgetFromMapToDashboard(
                                          place: widget.place,
                                          userdata: snapshot.data![0]);
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
        height: widget.isExpanded ? 500.0 : 125.0,
        width: 325.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34.5),
          color: const Color.fromARGB(255, 43, 43, 43).withOpacity(0.90),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding:
                widget.isExpanded ? const EdgeInsets.all(8) : EdgeInsets.zero,
            child: widget.isExpanded
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      widget.isExpanded
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: isReviews
                                  ? ListView(
                                      children: [
                                        if (isReviews)
                                          ...widget.place.reviews.map((e) {
                                            return _showReview(e);
                                          })
                                      ],
                                    )
                                  : showPhoto(widget.place.photosElements))
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
                            Container(
                              height: 90.0,
                              width: 90.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  image: DecorationImage(
                                      image: widget.placeImage != ''
                                          ? widget
                                              .place.firstImage.imageProvider
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
                            ),
                            const SizedBox(width: 15.0),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 130.0,
                                  height: 50.0,
                                  child: Text(widget.place.name,
                                      style: Styles.maptitle),
                                ),
                                RatingStars(
                                  value: widget.place.rating,
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
                                  valueLabelPadding: const EdgeInsets.symmetric(
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
    );
  }
}
