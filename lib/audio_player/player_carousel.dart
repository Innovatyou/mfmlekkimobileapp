import 'package:flutter/material.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:provider/provider.dart';
import 'package:higherground/utils/TimUtil.dart';
import 'package:higherground/providers/AudioPlayerModel.dart';
import 'package:higherground/providers/MediaPlayerModel.dart';

class Player extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AudioPlayerModel audioPlayerModel = Provider.of<AudioPlayerModel>(context);
    return Column(
      children: _controllers(context, audioPlayerModel),
    );
  }

  Widget _timer(BuildContext context, AudioPlayerModel audioPlayerModel) {
    var style = new TextStyle(
      color: Colors.white,
      fontSize: 15,
    );
    return StreamBuilder(
      initialData: audioPlayerModel.backgroundAudioPositionSeconds,
      stream: audioPlayerModel.audioProgressStreams.stream.asBroadcastStream(),
      builder: (BuildContext? context, dynamic snapshot) {
        double? seekSliderValue = 0;
        if (snapshot.data != null) {
          seekSliderValue = snapshot.data /
              audioPlayerModel.backgroundAudioDurationSeconds.floor();
          if (seekSliderValue!.isNaN || seekSliderValue < 0) {
            seekSliderValue = 0;
          }
          if (seekSliderValue > 1) {
            seekSliderValue = 1;
          }
          print("snapshot.data = " + snapshot.data.toString());
          print("backgroundAudioDurationSeconds = " +
              audioPlayerModel.backgroundAudioDurationSeconds.toString());
          print("seekSliderValue = " + seekSliderValue.toString());
        }
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Slider(
                      activeColor: MyColors.primary,
                      value: seekSliderValue,
                      onChangeEnd: (v) {
                        audioPlayerModel.onStartSeek();
                      },
                      onChanged: (double val) {
                        final double positionSeconds = val *
                            audioPlayerModel.backgroundAudioDurationSeconds;
                        audioPlayerModel.seekTo(positionSeconds);
                      }),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  width: 20,
                ),
                Text(
                  TimUtil.stringForSeconds(
                      (snapshot == null || snapshot.data == null)
                          ? 0.0
                          : snapshot.data),
                  style: style,
                ),
                Spacer(),
                new Text(
                  TimUtil.stringForSeconds(
                      audioPlayerModel.backgroundAudioDurationSeconds),
                  style: style,
                ),
                Container(
                  width: 20,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  List<Widget> _controllers(
      BuildContext context, AudioPlayerModel audioPlayerModel) {
    return [
      Visibility(
        visible: !audioPlayerModel.showList,
        child: new Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: _timer(context, audioPlayerModel),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              onPressed: () async {
                await audioPlayerModel.skipPrevious();
                Provider.of<MediaPlayerModel>(context, listen: false)
                    .setMediaLikesCommentsCount(audioPlayerModel.currentMedia!);
              },
              icon: Icon(
                //Icons.skip_previous,
                Icons.fast_rewind,
                size: 35.0,
                color: Colors.white,
              ),
            ),
            ClipOval(
                child: Container(
              color: Theme.of(context).colorScheme.secondary.withAlpha(30),
              width: 70.0,
              height: 70.0,
              child: IconButton(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                onPressed: () async {
                  await audioPlayerModel.onPressed();
                },
                icon: audioPlayerModel.icon(),
              ),
            )),
            IconButton(
              onPressed: () async {
                await audioPlayerModel.skipNext();
                Provider.of<MediaPlayerModel>(context, listen: false)
                    .setMediaLikesCommentsCount(audioPlayerModel.currentMedia!);
              },
              icon: Icon(
                //Icons.skip_next,
                Icons.fast_forward,
                size: 35.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ];
  }
}



