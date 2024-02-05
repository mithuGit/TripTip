import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

// This class is used to create a custom bottom sheet

class CustomBottomSheet {
  static Future<void> show(BuildContext context,
      {required String title, required List<Widget> content}) {
    return showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  resizeToAvoidBottomInset: false,
                  body: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: CustomScrollView(
                      slivers: [
                        SliverPersistentHeader(
                            pinned: true,
                            delegate: ListHeader(
                              title: title,
                              onActionTap: () => Navigator.pop(context),
                            )),
                        SliverList.list(children: [
                          ...content,
                        ])
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ListHeader extends SliverPersistentHeaderDelegate {
  final double _maxExtent = 70;
  final VoidCallback onActionTap;
  final String title;

  ListHeader({
    required this.onActionTap,
    required this.title,
  });
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    debugPrint(shrinkOffset.toString());
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onActionTap,
                child: Container(
                  color: Colors.transparent,
                  height: 20,
                  width: 100,
                  child: Center(
                    child: Image.asset(
                      'assets/moveModalDown.png',
                      width: 80,
                      height: 10,
                    ),
                  ),
                ),
              )
            ],
          ),
          Text(
            title,
            style: Styles.title,
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(covariant ListHeader oldDelegate) {
    return oldDelegate != this;
  }
}
