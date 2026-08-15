import 'package:flutter/material.dart';
import 'package:higherground/audio_player/radio_player.dart';
import 'package:provider/provider.dart';
import 'player_page.dart';
import 'package:higherground/providers/AudioPlayerModel.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/widgets/MarqueeWidget.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  _AudioPlayout createState() => _AudioPlayout();
}

class _AudioPlayout extends State<MiniPlayer> {
  @override
  Widget build(BuildContext context) {
    Provider.of<AudioPlayerModel>(context, listen: false).setContext(context);
    return Consumer<AudioPlayerModel>(
      builder: (context, audioPlayerModel, child) {
        Media? mediaItem = audioPlayerModel.currentMedia;
        return mediaItem == null
            ? Container()
            : GestureDetector(
                onTap: () {
                  if (!audioPlayerModel.isRadio) {
                    Navigator.of(context).pushNamed(PlayPage.routeName);
                  } else {
                    Navigator.of(context).pushNamed(RadioPlayer.routeName);
                  }
                },
                child: Container(
                  height: 65,
                  //color: Colors.grey[900],
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.rectangle,
                  ),
                  child: Card(
                      color: Colors.grey[50],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)),
                      margin: EdgeInsets.all(0),
                      elevation: 20,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: <Widget>[
                            mediaItem.coverPhoto == ""
                                ? Icon(Icons.audiotrack)
                                : Container(
                                    padding: EdgeInsets.all(5),
                                    height: 50,
                                    width: 60,
                                    child: Image(
                                      image:
                                          NetworkImage(mediaItem.coverPhoto!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                            Container(
                              width: 12,
                            ),
                            Expanded(
                              child: MarqueeWidget(
                                direction: Axis.horizontal,
                                child: Text(
                                  mediaItem.title ?? "",
                                  maxLines: 1,
                                  style: TextStyles.subhead(context).copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              onPressed: () async {
                                await audioPlayerModel.skipPrevious();
                              },
                              icon: const Icon(
                                Icons.skip_previous,
                                size: 30,
                                //color: Colors.white,
                              ),
                            ),
                            ClipOval(
                                child: Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withAlpha(30),
                              width: 50.0,
                              height: 50.0,
                              child: IconButton(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                onPressed: () async {
                                  await audioPlayerModel.onPressed();
                                },
                                icon: audioPlayerModel.miniicon(),
                              ),
                            )),
                            IconButton(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              onPressed: () async {
                                await audioPlayerModel.skipNext();
                              },
                              icon: const Icon(
                                Icons.skip_next,
                                size: 30,
                                //color: Colors.white,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              width: 25,
                              child: IconButton(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                onPressed: () {
                                  audioPlayerModel.cleanUpResources();
                                },
                                icon: const Icon(
                                  Icons.cancel,
                                  size: 20,
                                  //color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              color: MyColors.primary,
                              //width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[],
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              );
      },
    );
  }
}



