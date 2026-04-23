import 'package:flutter/material.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/utils/Utility.dart';

class CircleWidget extends StatelessWidget {
  final String? personImagePath;
  final String? name;
  final double? width, height;
  final BorderRadius? borderRadius;
  const CircleWidget({
    Key? key,
    this.personImagePath,
    this.name,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      //overflow: Overflow.visible,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            padding: const EdgeInsets.all(3.4),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(
                width: 2.0,
                color: MyColors.mainC0lor,
              ),
            ),
            child: Container(
              width: height,
              height: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    borderRadius == BorderRadius.horizontal() ? 0.0 : 50),
                image: DecorationImage(
                    image: NetworkImage(Utility.convertLocalhostToEmulator(personImagePath)), fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        Container(
          width: 50.0,
          //height: 10.0,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              name!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}



