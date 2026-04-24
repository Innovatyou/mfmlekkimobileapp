import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/screens/EventsViewerScreen.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'dart:async';
import 'dart:convert';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/models/Events.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'NoitemScreen.dart';
import 'package:intl/intl.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsListScreen extends StatefulWidget {
  static const routeName = "/eventslist";

  @override
  _EventsListScreenState createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
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
      var data = {"month": _selectedDate!.month, "year": _selectedDate!.year};
      print(data);
      final response = await Utility.getDio().post(
        ApiUrl.EVENTS,
        data: jsonEncode({"data": data}),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = jsonDecode(response.data);
        print(res);
        List<Events> _items = parseBranches(res);
        _items.forEach((element) {
          _events!.putIfAbsent(DateTime.parse(element.date!), () => [element]);
        });
        setState(() {
          isLoading = false;
          isError = false;
          items = _items;
        });
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  addEventsdata() {
    items.forEach((element) {
      _events!
          .putIfAbsent(DateTime.parse(element.date!), () => [element.title]);
    });
    setState(() {});
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    //print(_events);
    DateTime onlyDate = DateTime(day.year, day.month, day.day);
    print(onlyDate);
    return _events![onlyDate] ?? [];
  }

  static List<Events> parseBranches(dynamic res) {
    // final res = jsonDecode(responseBody);
    final parsed = res["events"].cast<Map<String, dynamic>>();
    return parsed.map<Events>((json) => Events.fromJson(json)).toList();
  }

  @override
  void initState() {
    super.initState();

    _events = {
      //DateTime.parse('2021-10-22'): ["Hello World"]
    };
    _selectedEvents = [];
    _selectedDate = DateTime.now();
    _focusedDate = DateTime.now();
    Future.delayed(const Duration(milliseconds: 0), () {
      loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        title: Text(
          t.events,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: isLoading
          ? Center(
              child: CupertinoActivityIndicator(
              radius: 20,
            ))
          : isError
              ? NoitemScreen(
                  title: t.oops,
                  message: t.dataloaderror,
                  onClick: () {
                    loadItems();
                  })
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
                                Icons.event_available_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Church Calendar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Tap any highlighted date to open event details.',
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
                        availableCalendarFormats: {
                          CalendarFormat.month: "Month"
                        },
                        firstDay: DateTime.utc(2010, 10, 16),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: _focusedDate!,
                        locale: "en_US",
                        //startDay: ,
                        //endDay: ,

                        //rowHeight: 40.0,
                        //availableGestures: AvailableGestures.none,
                        eventLoader: (day) {
                          return _getEventsForDay(day);
                        },
                        calendarFormat: CalendarFormat.month,

                        calendarStyle: CalendarStyle(
                            //markerDecoration: MyColors.primary,
                            markerSize: 34,
                            markerMargin: EdgeInsets.only(bottom: 0),
                            markersAnchor: 1.0,
                            markersOffset: PositionedOffset(top: 0, bottom: 0),
                            markersAlignment: Alignment.center,
                            canMarkersOverflow: true,
                            markerDecoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFCF4E45),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            //todayDecoration: Colors.orange,
                            //selectedDecoration: Colors.orange,
                            defaultTextStyle:
                              const TextStyle(color: Color(0xFF23141D)),
                            weekendTextStyle:
                              const TextStyle(color: Color(0xFF23141D)),
                            outsideTextStyle:
                              const TextStyle(color: Color(0xFFB4A8B1)),
                            todayTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: const Color(0xFFB06B1B))),
                        headerStyle: HeaderStyle(
                          headerMargin: EdgeInsets.all(10),
                          //leftChevronVisible: false,
                          //rightChevronVisible: false,
                          titleCentered: true,
                          titleTextStyle: const TextStyle(
                            color: Color(0xFF23141D),
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                          formatButtonDecoration: BoxDecoration(
                            color: const Color(0xFF8F3E88),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          formatButtonTextStyle: TextStyle(color: Colors.white),
                          formatButtonShowsNext: false,
                        ),
                        startingDayOfWeek: StartingDayOfWeek.sunday,
                        onDaySelected: (selectedDay, focusedDay) {
                          if (!isSameDay(_selectedDate, selectedDay)) {
                            setState(() {
                              _focusedDate = focusedDay;
                              _selectedDate = selectedDay;
                              // _selectedEvents = _getEventsForDay(selectedDay);
                            });
                          }
                          List<dynamic> _event = _getEventsForDay(selectedDay);
                          print(_event.toString());
                          if (_event.length > 0) {
                            Events _events = (_event[0] as Events);
                            Navigator.of(context)
                                .pushNamed(EventsViewerScreen.routeName,
                                    arguments: ScreenArguements(
                                      position: 0,
                                      items: _events,
                                      itemsList: [],
                                    ));
                          }
                        },
                        onPageChanged: (date) {
                          print("date changed to = " + date.toString());
                          if (date.month != _selectedDate!.month) {
                            setState(() {
                              _selectedDate = date;
                              _focusedDate = date;
                            });
                            loadItems();
                          }
                        },
                        /*onDaySelected: (date, events, holidays) {
                          print(events);
                          if (events.length > 0) {
                            Events _events = (events[0] as Events);
                            Navigator.of(context)
                                .pushNamed(EventsViewerScreen.routeName,
                                    arguments: ScreenArguements(
                                      position: 0,
                                      items: _events,
                                      itemsList: [],
                                    ));
                          }
                          //setState(() {
                          // _selectedEvents = events;
                          // });
                        },*/
                        calendarBuilders: CalendarBuilders(
                          selectedBuilder: (context, date, events) => Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: MyColors.mainC0lor,
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Text(
                                date.day.toString(),
                                style: const TextStyle(color: Colors.white),
                              )),
                          todayBuilder: (context, date, events) => Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFFD58E),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Text(
                                date.day.toString(),
                                style: const TextStyle(
                                  color: Color(0xFF7A4A0D),
                                  fontWeight: FontWeight.w700,
                                ),
                              )),
                        ),
                      ),
                      ),
                      ..._selectedEvents!.map((event) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: MediaQuery.of(context).size.height / 20,
                              width: MediaQuery.of(context).size.width / 2,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey)),
                              child: Center(
                                  child: Text(
                                event,
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              )),
                            ),
                          )),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            Text(
                              'Upcoming Events',
                              style: TextStyles.headline(context).copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: const Color(0xFF23141D),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
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
                      items.length == 0
                          ? Padding(
                              padding: const EdgeInsets.all(6),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: const Color(0xFFE8DDE4)),
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
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              padding: const EdgeInsets.only(top: 4),
                              itemBuilder: (BuildContext context, int index) {
                                return ItemTile(
                                  index: index,
                                  events: items[index],
                                );
                              },
                            )

                      /* Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: EventsListScreenPageBody(
                          key: UniqueKey(),
                          items: items,
                          //date: _selecteddate,
                          //dateTime: selectedDate,
                        ),
                      ),*/
                    ],
                  ),
                ),
    );
  }
}

class EventsListScreenPageBody extends StatefulWidget {
  const EventsListScreenPageBody({
    Key? key,
    this.items,
  }) : super(key: key);
  final List<Events>? items;
  @override
  _BranchesPageBodyState createState() => _BranchesPageBodyState();
}

class _BranchesPageBodyState extends State<EventsListScreenPageBody> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items!.length,
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.all(3),
      itemBuilder: (BuildContext context, int index) {
        return ItemTile(
          index: index,
          events: widget.items![index],
        );
      },
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
    DateTime tempDate = new DateFormat("yyyy-MM-dd").parse(events!.date!);
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(EventsViewerScreen.routeName,
            arguments: ScreenArguements(
              position: 0,
              items: events,
              itemsList: [],
            ));
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
                          DateFormat('EEE, MMM d, yyyy', 'en_US')
                              .format(tempDate),
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



