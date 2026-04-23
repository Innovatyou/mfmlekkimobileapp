import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:higherground/models/LiveStreams.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class LiveFacebookPlayer extends StatefulWidget {
  final LiveStreams media;
  LiveFacebookPlayer({Key? key, required this.media}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<LiveFacebookPlayer>
    with WidgetsBindingObserver {
  bool webView = true;
  bool webViewJs = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    print("i am a facebook player");
    return HtmlWidget(
      widget.media.streamUrl!,
      factoryBuilder: () => _WidgetFactory(
        webView: webView,
        webViewJs: webViewJs,
      ),
    );
  }
}

class _WidgetFactory extends WidgetFactory {
  @override
  final bool webView;

  @override
  final bool webViewJs;

  _WidgetFactory({
    required this.webView,
    required this.webViewJs,
  });
}


