import 'dart:async';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/utils/Utility.dart';

class AudioPlayerModel with ChangeNotifier {
  List<Media?> currentPlaylist = [];
  Media? currentMedia;
  int currentMediaPosition = 0;
  Color backgroundColor = MyColors.primary;
  bool isDialogShowing = false;

  double backgroundAudioDurationSeconds = 0.0;
  double backgroundAudioPositionSeconds = 0.0;

  bool isSeeking = false;
  late AudioPlayer _remoteAudio;
  bool remoteAudioPlaying = false;
  bool _remoteAudioLoading = false;
  bool isUserSubscribed = false;
  late StreamController<double> audioProgressStreams;
  bool isRadio = false;

  StreamController<String> _curPositionController =
      StreamController<String>.broadcast();
  Stream<String> get curPositionStream => _curPositionController.stream;
  Duration? curSongDuration;

  /// Identifiers for the two custom Android notification buttons.
  static const String replayButtonId = 'replayButtonId';
  static const String newReleasesButtonId = 'newReleasesButtonId';
  static const String skipPreviousButtonId = 'skipPreviousButtonId';
  static const String skipNextButtonId = 'skipNextButtonId';

  AudioPlayerModel() {
    // ✅ CRITICAL: Create AudioPlayer instance HERE after JustAudioBackground.init()
    // JustAudioBackground.init() runs in main() BEFORE this provider is created
    // This ensures the global audio handler is ready
    _remoteAudio = AudioPlayer();
    print("✅ AudioPlayer instance created");
    
    getRepeatMode();
    audioProgressStreams = new StreamController<double>.broadcast();
    audioProgressStreams.add(0);
    
    // Initialize listeners immediately
    initplayer();
  }

  initplayer() {
    _remoteAudio.durationStream.listen((position) {
      print(position);
      _remoteAudioLoading = false;
      remoteAudioPlaying = true;
      if (!isRadio && position != null) {
        backgroundAudioDurationSeconds = position.inSeconds.toDouble();
      }
      //Toast.show(autoplay.toString(), _context);
      Future.delayed(const Duration(milliseconds: 0), () {
        //player.play();
        // _resumeBackgroundAudio();
        //Toast.show("true 1", _context);
        _remoteAudio.play();
        remoteAudioPlaying = true;
        notifyListeners();
      });
      //final duration = Duration(seconds: durationSeconds.toInt());
      curSongDuration = position;
      notifyListeners();
    });
    _remoteAudio.positionStream.listen((position) {
      print("current audio position is = " + position.toString());
      //final p = Duration(seconds: positionSeconds.toInt());
      if (!isRadio && curSongDuration != null) {
        double positionSeconds = position.inSeconds.toDouble();
        sinkProgress(position.inMilliseconds > curSongDuration!.inMilliseconds
            ? curSongDuration!.inMilliseconds
            : position.inMilliseconds);
        //print("positionSeconds = " + positionSeconds.toString());
        backgroundAudioPositionSeconds = positionSeconds;
        //if (isSeeking) return;
        audioProgressStreams.add(backgroundAudioPositionSeconds);
      }
    });

    _remoteAudio.playerStateStream.listen((playerState) async {
      print("playercheck = " + _remoteAudio.androidAudioSessionId.toString());
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
      } else if (processingState == ProcessingState.completed) {
        print("oncompletecalled");
        if (_isRepeat!) {
          await startAudioPlayBack(currentMedia);
        } else {
          skipNext();
        }
      } else if (!isPlaying) {
        remoteAudioPlaying = false;
        notifyListeners();
        print("remoteAudioPlaying2=" + remoteAudioPlaying.toString());
      } else {
        remoteAudioPlaying = true;
        notifyListeners();
        print("remoteAudioPlaying3=" + remoteAudioPlaying.toString());
      }
    });

    remoteAudioPlaying = false;
  }

  void sinkProgress(int m) {
    _curPositionController.sink.add('$m-${curSongDuration!.inMilliseconds}');
  }

  bool? _isRepeat = false;
  bool? get isRepeat => _isRepeat;
  changeRepeat() async {
    _isRepeat = !_isRepeat!;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("_isRepeatMode", _isRepeat!);
  }

  getRepeatMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("_isRepeatMode") != null) {
      _isRepeat = prefs.getBool("_isRepeatMode");
    }
  }

  setUserSubscribed(bool isUserSubscribed) {
    this.isUserSubscribed = isUserSubscribed;
  }

  setContext(BuildContext context) {
    //_context = context;
  }

  bool _showList = false;
  bool get showList => _showList;
  setShowList(bool showList) {
    _showList = showList;
    notifyListeners();
  }

  preparePlaylist(List<Media?> playlist, Media media) async {
    isRadio = false;
    currentPlaylist = playlist;
    //await setPlaylistData(playlist);
    startAudioPlayBack(media);
  }

  prepareradioplayer(List<Media?> playlist, Media media) async {
    isRadio = true;
    currentPlaylist = playlist;
    //await setPlaylistData(playlist);
    startAudioPlayBack(media);
  }

  setPlaylistData(List<Media?> playlist) async {
    List<AudioSource> _audioplaylist = [];
    playlist.forEach((element) {
      _audioplaylist.add(AudioSource.uri(
        Uri.parse(element!.streamUrl!),
      ));
    });
    final _playlist = ConcatenatingAudioSource(children: _audioplaylist);
    try {
      await _remoteAudio.setAudioSource(_playlist);
    } catch (e, stackTrace) {
      // Catch load errors: 404, invalid url ...
      print("Error loading playlist: $e");
      print(stackTrace);
    }
  }

  startAudioPlayBack(Media? media) async {
    if (media == null) {
      print("❌ ERROR: Media is null, cannot play");
      _remoteAudioLoading = false;
      notifyListeners();
      return;
    }
    
    print("🎵 Starting playback: ${media.title} - ${media.streamUrl}");
    
    if (currentMedia != null) {
      await _remoteAudio.pause();
    }
    
    currentMedia = media;
    Utility.updatemediatotalviews(currentMedia!.id!);
    setCurrentMediaPosition();
    _remoteAudioLoading = true;
    remoteAudioPlaying = false;
    notifyListeners();
    audioProgressStreams.add(0);

    try {
      final audioUri = Uri.parse(currentMedia!.streamUrl!);
      print("📍 Loading audio from: $audioUri");
      
      // ✅ Load audio source directly with just_audio (no background service metadata)
      await _remoteAudio.setAudioSource(AudioSource.uri(audioUri));
      
      print("✅ Audio source loaded successfully");
      _remoteAudioLoading = false;
      notifyListeners();
      
    } catch (e) {
      print("❌ ERROR loading audio source: $e");
      _remoteAudioLoading = false;
      remoteAudioPlaying = false;
      notifyListeners();
      
      // Note: Error handling in UI layer can show error to user if needed
      // Provider doesn't have direct access to BuildContext
    }
  }

  setCurrentMediaPosition() {
    currentMediaPosition = currentPlaylist.indexOf(currentMedia);
    if (currentMediaPosition == -1) {
      currentMediaPosition = 0;
    }
    print("currentMediaPosition = " + currentMediaPosition.toString());
  }

  cleanUpResources() {
    _stopBackgroundAudio();
  }

  Widget icon() {
    if (_remoteAudioLoading) {
      return Theme(
          data: ThemeData(
              cupertinoOverrideTheme:
                  CupertinoThemeData(brightness: Brightness.dark)),
          child: CupertinoActivityIndicator());
    }
    if (remoteAudioPlaying) {
      return const Icon(
        Icons.pause,
        size: 40,
        color: Colors.white,
      );
    }
    return const Icon(
      Icons.play_arrow,
      size: 40,
      color: Colors.white,
    );
  }

  Widget radioicon() {
    if (_remoteAudioLoading) {
      return Theme(
          data: ThemeData(
              cupertinoOverrideTheme:
                  CupertinoThemeData(brightness: Brightness.dark)),
          child: CupertinoActivityIndicator());
    }
    if (remoteAudioPlaying) {
      return const Icon(
        Icons.pause,
        size: 60,
        color: Colors.white,
      );
    }
    return const Icon(
      Icons.play_arrow,
      size: 60,
      color: Colors.white,
    );
  }

  Widget miniicon() {
    if (_remoteAudioLoading) {
      return Theme(
          data: ThemeData(
              cupertinoOverrideTheme:
                  CupertinoThemeData(brightness: Brightness.light)),
          child: CupertinoActivityIndicator());
    }
    if (remoteAudioPlaying) {
      return const Icon(
        Icons.pause,
        size: 40,
        //color: Colors.white,
      );
    }
    return const Icon(
      Icons.play_arrow,
      size: 40,
      //color: Colors.white,
    );
  }

  Widget radiominiicon() {
    if (_remoteAudioLoading) {
      return Theme(
          data: ThemeData(
              cupertinoOverrideTheme:
                  CupertinoThemeData(brightness: Brightness.light)),
          child: CupertinoActivityIndicator());
    }
    if (remoteAudioPlaying) {
      return const Icon(
        Icons.pause,
        size: 30,
        //color: Colors.white,
      );
    }
    return const Icon(
      Icons.play_arrow,
      size: 30,
      //color: Colors.white,
    );
  }

  Future<void> onPressed() async {
    if (remoteAudioPlaying) {
      await _pauseBackgroundAudio();
    } else {
      await _resumeBackgroundAudio();
    }
  }

  Future<void> _resumeBackgroundAudio() async {
    print("▶️ Resuming audio playback");
    await _remoteAudio.play();
    remoteAudioPlaying = true;
    notifyListeners();
  }

  Future<void> _pauseBackgroundAudio() async {
    print("⏸️ Pausing audio playback");
    await _remoteAudio.pause();
    remoteAudioPlaying = false;
    notifyListeners();
  }

  void _stopBackgroundAudio() {
    print("⏹️ Stopping audio playback");
    _remoteAudio.pause();
    currentMedia = null;
    notifyListeners();
  }

  void shufflePlaylist() {
    currentPlaylist.shuffle();
    startAudioPlayBack(currentPlaylist[0]);
  }

  Future<void> skipPrevious() async {
    if (currentPlaylist.length == 0 || currentPlaylist.length == 1) return;
    int pos = currentMediaPosition - 1;
    if (pos == -1) {
      pos = currentPlaylist.length - 1;
    }
    Media? media = currentPlaylist[pos];
    await startAudioPlayBack(media);
  }

  Future<void> skipNext() async {
    if (currentPlaylist.length == 0 || currentPlaylist.length == 1) return;
    int pos = currentMediaPosition + 1;
    if (pos >= currentPlaylist.length) {
      pos = 0;
    }
    Media? media = currentPlaylist[pos];
    await startAudioPlayBack(media);
  }

  seekTo(double positionSeconds) {
    print("📍 Seeking to $positionSeconds seconds");
    backgroundAudioPositionSeconds = positionSeconds;
    _remoteAudio.seek(Duration(seconds: positionSeconds.toInt()));
    audioProgressStreams.add(backgroundAudioPositionSeconds);
  }

  onStartSeek() {
    isSeeking = true;
  }

  /// Generates a 200x200 png, with randomized colors, to use as art for the
  /// notification/lockscreen.
  static Future<Uint8List> generateImageBytes(String coverphoto) async {
    /*Uint8List byteImage = await networkImageToByte(coverphoto);
    return byteImage;*/

    Uint8List bytes =
        (await NetworkAssetBundle(Uri.parse(coverphoto)).load(coverphoto))
            .buffer
            .asUint8List();
    return bytes;
  }
}


