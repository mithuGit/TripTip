import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/Interests.dart';

class ImageContainer extends StatefulWidget {
  final String image;

  final ValueChanged<List<String>> setInterested;
  final ValueChanged<List<String>> unsetInterested;
  final ValueChanged<List<String>> unInterestetset;
  final ValueChanged<List<String>> unInterestetunset;

  final bool? isSelected;
  final bool? isNotinterested;
  const ImageContainer(
      {required this.image,
      super.key,
      required this.setInterested,
      required this.unsetInterested,
      required this.unInterestetset,
      required this.unInterestetunset,
      this.isSelected,
      this.isNotinterested});

  @override
  State<ImageContainer> createState() => _ImageContainerState();
}

class _ImageContainerState extends State<ImageContainer> {
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
          if (isNotinterested) {
            widget.unInterestetunset(Interests.available[widget.image]!);
            isSelected = false;
            isNotinterested = false;
          } else {
            isSelected = !isSelected;
            if (isSelected) {
              widget.setInterested(Interests.available[widget.image]!);
            } else {
              widget.unsetInterested(Interests.available[widget.image]!);
            }
          }
        });
      },
      onLongPress: () {
        setState(() {
          if(isSelected){
            widget.unsetInterested(Interests.available[widget.image]!);
            isSelected = false;
          }
          isNotinterested = !isNotinterested;
          if (isNotinterested) {
            widget.unInterestetset(Interests.available[widget.image]!);
          } else {
            widget.unInterestetunset(Interests.available[widget.image]!);
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
