import 'package:flutter/material.dart';

class ImageContainer extends StatefulWidget {
  final String image;

  final ValueChanged<List<String>> setVal;
  final ValueChanged<List<String>> unsetVal;
  final ValueChanged<List<String>> unInterestetset;
  final ValueChanged<List<String>> unInterestetunset;
  const ImageContainer(
      {required this.image,
      super.key,
      required this.setVal,
      required this.unsetVal,
      required this.unInterestetset,
      required this.unInterestetunset});

  @override
  State<ImageContainer> createState() => _ImageContainerState();
}

class _ImageContainerState extends State<ImageContainer> {
  bool isSelected = false;
  bool isNotinterested = false;
  Map<String, List<String>> available = {
    "automotive": [
      "car_dealer",
      "car_rental",
      "car_repair",
      "car_wash",
      "electric_vehicle_charging_station",
      "gas_station",
      "parking",
      "rest_stop"
    ],
    "business": ["farm"],
    "assets/interests_pic/culture.png": [
      "art_gallery",
      "museum" "performing_arts_theater"
    ],
    "education": [
      "library",
      "preschool",
      "primary_school",
      "school",
      "secondary_school",
      "university"
    ],
    "entertainment": [
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
    "finance": ["accounting", "atm", "bank"],
    'assets/interests_pic/food.png': [
      "american_restaurant",
      "bakery",
      "bar",
      "barbecue_restaurant",
      "brazilian_restaurant",
      "breakfast_restaurant",
      "brunch_restaurant",
      "cafe",
      "chinese_restaurant",
      "coffee_shop",
      "fast_food_restaurant",
      "french_restaurant",
      "greek_restaurant",
      "hamburger_restaurant",
      "ice_cream_shop",
      "indian_restaurant",
      "indonesian_restaurant",
      "italian_restaurant",
      "japanese_restaurant",
      "korean_restaurant",
      "lebanese_restaurant",
      "meal_delivery",
      "meal_takeaway",
      "mediterranean_restaurant",
      "mexican_restaurant",
      "middle_eastern_restaurant",
      "pizza_restaurant",
      "ramen_restaurant",
      "restaurant",
      "sandwich_shop",
      "seafood_restaurant",
      "spanish_restaurant",
      "steak_house",
      "sushi_restaurant",
      "thai_restaurant",
      "turkish_restaurant",
      "vegan_restaurant",
      "vegetarian_restaurant",
      "vietnamese_restaurant"
    ],
    "geographical": [
      "administrative_area_level_1",
      "administrative_area_level_2",
      "country	locality",
      "postal_code",
      "school_district"
    ],
    "government": [
      "city_hall",
      "courthouse",
      "embassy",
      "fire_station",
      "local_government_office",
      "police",
      "post_office"
    ],
    "assets/interests_pic/health.png": [
      "dental_clinic",
      "doctor",
      "drugstore",
      "hospital",
      "pharmacy",
      "physiotherapist",
      "medical_lab",
      "spa",
    ],
    "assets/interests_pic/lodging.png": [
      "bed_and_breakfast",
      "campground",
      "camping_cabin",
      "cottage",
      "extended_stay_hotel",
      "farmstay",
      "guest_house",
      "hostel",
      "hotel",
      "motel",
      "private_guest_room",
      "resort_hotel"
          "rv_park",
    ],
    "Worship": ["church", "hindu_temple", "mosque", "synagogue"],
    "Services": [
      "barber_shop",
      "beauty_salon",
      "cemetry",
      "child_care_agency",
      "consultant",
      "courier_service",
      "electrician",
      "florist",
      "funeral_home",
      "hair_care",
      "hair_salon",
      "insurance_agency",
      "laundry",
      "lawyer",
      "locksmith",
      "moving_company",
      "painter",
      "plumber",
      "real_estate_agency",
      "roofing_contractor",
      "storage",
      "tailor",
      "telecommunication_service_provider",
      "travel_agency",
      "veterinary_care",
    ],
    "assets/interests_pic/shopping.png": [
      "auto_parts_store",
      "bicycle_store",
      "book_store",
      "cell_phone_store",
      "clothing_store",
      "convenience_store",
      "department_store",
      "discount_store",
      "electronics_store",
      "furniture_store",
      "gift_store",
      "grocery_store",
      "hardware_store",
      "home_goods_store",
      "home_improvement_store",
      "jewelry_store",
      "liquor_store",
      "market",
      "pet_store",
      "shoe_store",
      "shopping_mall",
      "sporting_goods_store",
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
      "heliport",
      "light_rail_station",
      "park_and_ride",
      "subway_station",
      "taxi_stand",
      "train_station",
      "transit_depot",
      "transit_station",
      "truck_stop"
    ],
  };
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isNotinterested) {
            widget.unInterestetunset(available[widget.image]!);
          } else {
            isSelected = !isSelected;
            if (isSelected) {
              widget.unsetVal(available[widget.image]!);
            } else {
              widget.setVal(available[widget.image]!);
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
      child: Container(
        width: 80,
        height: 80,
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
    );
  }
}
