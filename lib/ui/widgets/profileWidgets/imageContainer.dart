import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/Interests.dart';

class ImageContainerToSetInterest extends StatefulWidget {
  final String image;

  final ValueChanged<List<String>> setInterested;
  final ValueChanged<List<String>> unsetInterested;

  final bool? isSelected;
  final bool? isNotinterested;
  const ImageContainerToSetInterest(
      {required this.image,
      super.key,
      required this.setInterested,
      required this.unsetInterested,
      this.isSelected,
      this.isNotinterested});

  @override
  State<ImageContainerToSetInterest> createState() => _ImageContainerToSetInterestState();
}

class _ImageContainerToSetInterestState extends State<ImageContainerToSetInterest> {
  bool isSelected = false;
  bool isNotinterested = false;
  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected ?? false;
    isNotinterested = widget.isNotinterested ?? false;
  }

  @override
  Widget build(BuildContext context) {
    int length = 0;
    for (final key in Interests.available.keys) {
      length += Interests.available[key]!.length;
    }
    print(length);
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          if (isSelected) {
            widget.setInterested(Interests.available[widget.image]!);
          } else {
            widget.unsetInterested(Interests.available[widget.image]!);
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
                color: isSelected ? Colors.green : Colors.white,
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
