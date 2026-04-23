// Adapter shim: implement legacy BetterPlayer API on top of video_player + chewie
library better_player;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

enum BetterPlayerDataSourceType { network, file }
enum BetterPlayerVideoFormat { hls, other }

class BetterPlayerDataSource {
	final BetterPlayerDataSourceType type;
	final String url;
	final BetterPlayerVideoFormat? videoFormat;
	BetterPlayerDataSource(this.type, this.url, {this.videoFormat});
}

class BetterPlayerConfiguration {
	final double? aspectRatio;
	final Widget? placeholder;
	final bool? autoPlay;
	final bool? allowedScreenSleep;
	final bool? fullScreenByDefault;
	const BetterPlayerConfiguration({this.aspectRatio, this.placeholder, this.autoPlay, this.allowedScreenSleep, this.fullScreenByDefault});
}

class BetterPlayerController {
	final BetterPlayerConfiguration? configuration;
	final BetterPlayerDataSource? betterPlayerDataSource;
	late final VideoPlayerController _videoController;
	ChewieController? _chewieController;
	bool _initialized = false;

	BetterPlayerController(this.configuration, {this.betterPlayerDataSource}) {
		if (betterPlayerDataSource != null) {
			if (betterPlayerDataSource!.type == BetterPlayerDataSourceType.network) {
				_videoController = VideoPlayerController.networkUrl(Uri.parse(betterPlayerDataSource!.url));
			} else {
				_videoController = VideoPlayerController.file(File(betterPlayerDataSource!.url));
			}
			_chewieController = ChewieController(
				videoPlayerController: _videoController,
				autoPlay: configuration?.autoPlay ?? false,
				aspectRatio: configuration?.aspectRatio,
			);
		}
	}

	Future<void> initialize() async {
		if (!_initialized) {
			await _videoController.initialize();
			_initialized = true;
		}
	}

	void addEventsListener(void Function(dynamic) listener) {}
	Future<void> pause() async => _videoController.pause();
	Future<void> play() async => _videoController.play();
	void dispose() {
		try {
			_chewieController?.dispose();
		} catch (_) {}
		try {
			_videoController.dispose();
		} catch (_) {}
	}

	ChewieController? get chewieController => _chewieController;
}

class BetterPlayer extends StatefulWidget {
	final BetterPlayerController? controller;
	const BetterPlayer({Key? key, this.controller}) : super(key: key);
	@override
	State<BetterPlayer> createState() => _BetterPlayerState();
}

class _BetterPlayerState extends State<BetterPlayer> {
	@override
	Widget build(BuildContext context) {
		final cc = widget.controller?.chewieController;
		if (cc == null) return SizedBox.shrink();
		return Chewie(controller: cc);
	}
}
