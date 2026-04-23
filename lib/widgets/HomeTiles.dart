import 'package:flutter/material.dart';

class HomeTiles extends StatelessWidget {
  final String title;
  final String thumbnail;
  final Color color;
  final int index;
  final double height, width;
  final Function onclick;

  const HomeTiles({
    Key? key,
    required this.index,
    required this.title,
    required this.thumbnail,
    required this.color,
    required this.height,
    required this.width,
    required this.onclick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onclick();
      },
      child: Stack(
        children: [
          Container(
            width: width,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey[300]!, width: 0.5)),
              color: color,
              child: Container(
                height: height,
                width: width,
                padding: EdgeInsets.all(8),
                child: Image.asset(
                  thumbnail,
                  //height: 75,
                  //width: 75,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 3,
            child: Container(
              height: 40,
              width: width,
              padding: EdgeInsetsDirectional.only(
                bottom: 6,
              ),
              color: Colors.black38,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.white),
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

