import 'package:flutter/material.dart';

class ImageContainer extends StatefulWidget {
  final String image;

  final ValueChanged<List<String>> setInterested;
  final ValueChanged<List<String>> unsetInterested;
  final ValueChanged<List<String>> unInterestetset;
  final ValueChanged<List<String>> unInterestetunset;
  const ImageContainer(
      {required this.image,
      super.key,
      required this.setInterested,
      required this.unsetInterested,
      required this.unInterestetset,
      required this.unInterestetunset});

  @override
  State<ImageContainer> createState() => _ImageContainerState();
}

class _ImageContainerState extends State<ImageContainer> {
  bool isSelected = false;
  bool isNotinterested = false;
  Map<String, List<String>> available = {
    "assets/interests_pic/car.png": [
      "car_rental",
      "car_repair",
      "electric_vehicle_charging_station",
      "gas_station",
      "parking",
      "rest_stop"
    ],
    "assets/interests_pic/culture.png": [
      "art_gallery",
      "museum",
      "performing_arts_theater"
    ],
    "assets/interests_pic/education.png": [
      "library",
      "preschool",
      "primary_school",
      "school",
      "secondary_school",
      "university"
    ],
    "assets/interests_pic/entertainment.png": [
      "amusement_center",
      "amusement_park",
      "aquarium",
      "bowling_alley",
      "casino",
      "movie_rental",
      "movie_theater",
      "night_club",
      "tourist_attraction",
      "zoo"
    ],
    //"finance": ["accounting", "atm", "bank"], is now in services, because it is more fitting and less confusing
    'assets/interests_pic/food.png': [
      "bakery",
      "bar",
      "cafe",
      "coffee_shop",
      "meal_delivery",
      "meal_takeaway",
      "restaurant",
    ],
    "assets/interests_pic/health.png": [
      "doctor",
      "drugstore",
      "hospital",
      "pharmacy",
      "spa",
    ],
    "assets/interests_pic/lodging.png": [
      "bed_and_breakfast",
      "campground",
      "camping_cabin",
      "extended_stay_hotel",
      "guest_house",
      "hostel",
      "hotel",
      "motel",
      "private_guest_room",
      "resort_hotel",
      "rv_park",
    ],
    'assets/interests_pic/religion.png': [
      "church",
      "hindu_temple",
      "mosque",
      "synagogue"
    ],
    "assets/interests_pic/services.png": [
      "barber_shop",
      "beauty_salon",
      "courier_service",
      "hair_care",
      "hair_salon",
      "laundry",
      "storage",
      "telecommunication_service_provider",
      "travel_agency",
      "accounting",
      "atm",
      "bank"
    ],
    "assets/interests_pic/shopping.png": [
      "market",
      "shopping_mall",
      "store",
      "supermarket",
      "wholesaler",
    ],
    "assets/interests_pic/sports.png": [
      "athletic_field",
      "fitness_center",
      "golf_course",
      "gym",
      "playground",
      "ski_resort",
      "sports_club",
      "sports_complex",
      "stadium",
      "swimming_pool",
    ],
    "assets/interests_pic/transport.png": [
      "airport",
      "bus_station",
      "bus_stop",
      "ferry_terminal",
      "park_and_ride",
      "subway_station",
      "taxi_stand",
      "train_station",
      "transit_station",
    ],
  };
  @override
  Widget build(BuildContext context) {
    int length = 0;
    for (final key in available.keys) {
      length += available[key]!.length;
    }
    print(length);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isNotinterested) {
            widget.unInterestetunset(available[widget.image]!);
            isSelected = false;
          } else {
            isSelected = !isSelected;
            if (isSelected) {
              widget.setInterested(available[widget.image]!);
            } else {
              widget.unInterestetset(available[widget.image]!);
            }
          }
        });
      },
      onLongPress: () {
        setState(() {
          isNotinterested = !isNotinterested;
          if (isNotinterested) {
            widget.unInterestetset(available[widget.image]!);
          } else {
            widget.unInterestetunset(available[widget.image]!);
          }
        });
      },
      child: Column(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Colors.green
                    : (isNotinterested ? Colors.red : Colors.white),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(14),
              image: DecorationImage(
                image: AssetImage(widget.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            widget.image.split("/").last.split(".").first[0].toUpperCase() +
                widget.image.split("/").last.split(".").first.substring(1),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
