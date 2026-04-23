import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart';

class PostImageViewer extends StatelessWidget {
  const PostImageViewer({
    Key? key,
    this.imgURL,
  }) : super(key: key);
  final String? imgURL;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        showImageViewer(
          context,
          Image.network(imgURL!).image,
          useSafeArea: true,
          swipeDismissible: true,
        );
      },
      child: Container(
        child: CachedNetworkImage(
          imageUrl: imgURL!,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  //scale: 0.6,
                  colorFilter:
                      ColorFilter.mode(Colors.black12, BlendMode.darken)),
            ),
          ),
          placeholder: (context, url) =>
              Center(child: CupertinoActivityIndicator()),
          errorWidget: (context, url, error) => Center(
              child: Icon(
            Icons.error,
            color: Colors.grey,
          )),
        ),
      ),
    );
  }
}

