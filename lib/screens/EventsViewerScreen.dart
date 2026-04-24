import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Events.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/img.dart';
import 'package:intl/intl.dart';

import 'NoitemScreen.dart';

class EventsViewerScreen extends StatefulWidget {
  static const routeName = '/eventsviewer';

  const EventsViewerScreen({Key? key, this.events}) : super(key: key);
  final Events? events;

  @override
  _BranchesPageBodyState createState() => _BranchesPageBodyState();
}

class _BranchesPageBodyState extends State<EventsViewerScreen> {
  bool isLoading = false;
  bool isError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF2A1720)),
        title: Text(
          t.events,
          style: const TextStyle(
            color: Color(0xFF2A1720),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SingleChildScrollView(
          child: getEventsBody(),
        ),
      ),
    );
  }

  Widget getEventsBody() {
    if (isLoading) {
      return const SizedBox(
        height: 600,
        child: Center(
          child: CupertinoActivityIndicator(radius: 20),
        ),
      );
    } else if (isError || widget.events == null) {
      return SizedBox(
        height: 600,
        child: Center(
          child: NoitemScreen(
            title: t.oops,
            message: t.dataloaderror,
            onClick: () {},
          ),
        ),
      );
    }

    final event = widget.events!;
    final eventDate = DateFormat('EEE, MMM d, yyyy', 'en_US')
        .format(DateFormat('yyyy-MM-dd').parse(event.date!));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8DDE4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title ?? '',
                  style: TextStyles.headline(context).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: const Color(0xFF2A1720),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 210,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      imageUrl: event.thumbnail ?? '',
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: 0.15),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          const Center(child: CupertinoActivityIndicator()),
                      errorWidget: (context, url, error) => Center(
                        child: Image.asset(
                          Img.get('event.jpg'),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(icon: Icons.event_outlined, text: eventDate),
                    _MetaChip(
                      icon: Icons.schedule_rounded,
                      text: event.time ?? '',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8DDE4)),
            ),
            child: HtmlWidget(
              event.details ?? '',
              textStyle: TextStyles.medium(context).copyWith(
                fontSize: 18,
                height: 1.55,
                color: const Color(0xFF3A2A33),
              ),
              factoryBuilder: () => _WidgetFactory(
                webView: true,
                webViewJs: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EAF0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF7A4B63)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF7A4B63),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
