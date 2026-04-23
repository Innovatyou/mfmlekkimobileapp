import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/providers/AudioPlayerModel.dart';
import 'package:provider/provider.dart';

class RadioPlayer extends StatefulWidget {
  static const routeName = "/RadioPlayer";
  RadioPlayer();

  @override
  State<RadioPlayer> createState() => _RadioPlayerState();
}

class _RadioPlayerState extends State<RadioPlayer> {
  late AudioPlayerModel audioplayermodel;
  @override
  Widget build(BuildContext context) {
    audioplayermodel = Provider.of<AudioPlayerModel>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          t.radiostreams,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 250,
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(0.0),
                        image: DecorationImage(
                          image: NetworkImage(
                              audioplayermodel.currentMedia!.coverPhoto!),
                          fit: BoxFit.cover,
                        )),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.blue.withOpacity(0.5)),
                    child: Text(
                      audioplayermodel.currentMedia!.title!,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: ClipOval(
                        child: Container(
                      color:
                          Theme.of(context).colorScheme.secondary.withAlpha(30),
                      width: 120.0,
                      height: 120.0,
                      child: IconButton(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        onPressed: () {
                          audioplayermodel.onPressed();
                        },
                        icon: audioplayermodel.radioicon(),
                      ),
                    )),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              margin: EdgeInsets.only(bottom: 10),
              color: Colors.black,
              child: Text(
                (audioplayermodel.currentPlaylist.length.toString() +
                        " " +
                        t.radiostreams)
                    .toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
            ListView.separated(
              itemCount: audioplayermodel.currentPlaylist.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemBuilder: (context, index) {
                Media? media = audioplayermodel.currentPlaylist[index];
                return ListTile(
                  onTap: () {
                    audioplayermodel.startAudioPlayBack(media);
                  },
                  leading: Container(
                    padding: EdgeInsets.all(5),
                    height: 50,
                    width: 50,
                    child: Image(
                      image: NetworkImage(media!.coverPhoto!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    media.title!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  //subtitle: Text(media.description!),
                  trailing: (audioplayermodel.currentMedia!.id! == media.id)
                      ? ClipOval(
                          child: Container(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withAlpha(30),
                          width: 40.0,
                          height: 40.0,
                          child: IconButton(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            onPressed: () {
                              audioplayermodel.onPressed();
                            },
                            icon: audioplayermodel.radiominiicon(),
                          ),
                        ))
                      : Icon(
                          Icons.play_arrow,
                          size: 30,
                        ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}



