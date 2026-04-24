import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Events.dart';
import 'package:higherground/models/Groups.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/screens/EventsViewerScreen.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'NoitemScreen.dart';

class GroupEventsListScreen extends StatefulWidget {
  static const routeName = '/GroupEventsListScreen';
  final Groups? groups;

  GroupEventsListScreen({this.groups});

  @override
  _EventsListScreenState createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<GroupEventsListScreen> {
  Map<DateTime, List<dynamic>>? _events;
  List<dynamic>? _selectedEvents;
  DateTime? _focusedDate;
  DateTime? _selectedDate;
  bool isLoading = true;
  bool isError = false;
  List<Events> items = [];

  Future<void> loadItems() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = {
        'groupid': widget.groups!.id!.toString(),
        'month': _selectedDate!.month,
        'year': _selectedDate!.year,
      };
      final response = await Utility.getDio().post(
        ApiUrl.FETCH_GROUP_EVENTS,
        data: jsonEncode({'data': data}),
      );

      if (response.statusCode == 200) {
        final dynamic res = jsonDecode(response.data);
        final List<Events> fetched = parseEvents(res);
        _events!.clear();
        for (final element in fetched) {
          _events!.putIfAbsent(DateTime.parse(element.date!), () => [element]);
        }

        setState(() {
          isLoading = false;
          isError = false;
          items = fetched;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (exception) {
      print(exception);
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final onlyDate = DateTime(day.year, day.month, day.day);
    return _events![onlyDate] ?? [];
  }

  static List<Events> parseEvents(dynamic res) {
    final parsed = res['events'].cast<Map<String, dynamic>>();
    return parsed.map<Events>((json) => Events.fromJson(json)).toList();
  }

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedEvents = [];
    _selectedDate = DateTime.now();
    _focusedDate = DateTime.now();
    Future.delayed(Duration.zero, () {
      loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        surfaceTintColor: Colors.transparent,
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            widget.groups!.title!,
            style: const TextStyle(
              color: Color(0xFF2A1720),
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            t.groupevents,
            style: const TextStyle(color: Color(0xFF7D7079)),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 20))
          : isError
              ? NoitemScreen(
                  title: t.oops,
                  message: t.dataloaderror,
                  onClick: loadItems,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7F375E), Color(0xFFA84978)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.groups_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Group Calendar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Tap highlighted dates to view event details.',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE8DDE4)),
                        ),
                        child: TableCalendar(
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month',
                          },
                          firstDay: DateTime.utc(2010, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: _focusedDate!,
                          locale: 'en_US',
                          eventLoader: _getEventsForDay,
                          calendarFormat: CalendarFormat.month,
                          calendarStyle: CalendarStyle(
                            markerSize: 34,
                            markerMargin: const EdgeInsets.only(bottom: 0),
                            markersAnchor: 1.0,
                            markersOffset: const PositionedOffset(top: 0, bottom: 0),
                            markersAlignment: Alignment.center,
                            canMarkersOverflow: true,
                            markerDecoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFCF4E45)),
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                            ),
                            defaultTextStyle: const TextStyle(color: Color(0xFF23141D)),
                            weekendTextStyle: const TextStyle(color: Color(0xFF23141D)),
                            outsideTextStyle: const TextStyle(color: Color(0xFFB4A8B1)),
                            todayTextStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFB06B1B),
                            ),
                          ),
                          headerStyle: HeaderStyle(
                            headerMargin: const EdgeInsets.all(10),
                            titleCentered: true,
                            titleTextStyle: const TextStyle(
                              color: Color(0xFF23141D),
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                            formatButtonDecoration: BoxDecoration(
                              color: const Color(0xFF8F3E88),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            formatButtonTextStyle: const TextStyle(color: Colors.white),
                            formatButtonShowsNext: false,
                          ),
                          startingDayOfWeek: StartingDayOfWeek.sunday,
                          onDaySelected: (selectedDay, focusedDay) {
                            if (!isSameDay(_selectedDate, selectedDay)) {
                              setState(() {
                                _focusedDate = focusedDay;
                                _selectedDate = selectedDay;
                              });
                            }
                            final event = _getEventsForDay(selectedDay);
                            if (event.isNotEmpty) {
                              final selectedEvent = event[0] as Events;
                              Navigator.of(context).pushNamed(
                                EventsViewerScreen.routeName,
                                arguments: ScreenArguements(
                                  position: 0,
                                  items: selectedEvent,
                                  itemsList: [],
                                ),
                              );
                            }
                          },
                          onPageChanged: (date) {
                            if (date.month != _selectedDate!.month) {
                              setState(() {
                                _selectedDate = date;
                                _focusedDate = date;
                              });
                              loadItems();
                            }
                          },
                          calendarBuilders: CalendarBuilders(
                            selectedBuilder: (context, date, events) => Container(
                              margin: const EdgeInsets.all(4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: MyColors.mainC0lor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                date.day.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            todayBuilder: (context, date, events) => Container(
                              margin: const EdgeInsets.all(4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD58E),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                date.day.toString(),
                                style: const TextStyle(
                                  color: Color(0xFF7A4A0D),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ..._selectedEvents!.map(
                        (event) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            height: MediaQuery.of(context).size.height / 20,
                            width: MediaQuery.of(context).size.width / 2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Center(
                              child: Text(
                                event,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            Text(
                              t.events,
                              style: TextStyles.headline(context).copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: const Color(0xFF23141D),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EAF0),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${items.length}',
                                style: const TextStyle(
                                  color: Color(0xFF7A6B75),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      items.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(6),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFFE8DDE4)),
                                ),
                                child: Text(
                                  t.noevents,
                                  textAlign: TextAlign.center,
                                  style: TextStyles.subhead(context).copyWith(
                                    fontSize: 14,
                                    color: const Color(0xFF7A6B75),
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: items.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(top: 4),
                              itemBuilder: (BuildContext context, int index) {
                                return ItemTile(events: items[index], index: index);
                              },
                            ),
                    ],
                  ),
                ),
    );
  }
}

class ItemTile extends StatelessWidget {
  final Events? events;
  final int? index;

  const ItemTile({
    Key? key,
    required this.index,
    required this.events,
  })  : assert(index != null),
        assert(events != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final tempDate = DateFormat('yyyy-MM-dd').parse(events!.date!);
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          EventsViewerScreen.routeName,
          arguments: ScreenArguements(
            position: 0,
            items: events,
            itemsList: [],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8DDE4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF5EAF1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.event_note_rounded,
                color: Color(0xFF8F3E88),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          DateFormat('EEE, MMM d, yyyy', 'en_US').format(tempDate),
                          style: TextStyles.caption(context).copyWith(
                            color: const Color(0xFF7A6B75),
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      Text(
                        events!.time!,
                        style: TextStyles.caption(context).copyWith(
                          color: const Color(0xFF7A6B75),
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    events!.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.subhead(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF23141D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF8D8089),
            ),
          ],
        ),
      ),
    );
  }
}
