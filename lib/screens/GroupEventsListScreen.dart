import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:higherground/models/Groups.dart';
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

class GroupEventsListScreen extends StatefulWidget {
  static const routeName = "/GroupEventsListScreen";
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
      var data = {
        "groupid": widget.groups!.id!.toString(),
        "month": _selectedDate!.month,
        "year": _selectedDate!.year
      };
      print(data);
      final response = await Utility.getDio().post(
        ApiUrl.FETCH_GROUP_EVENTS,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        title: ListTile(
          title: Text(widget.groups!.title!),
          subtitle: Text(t.groupevents),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TableCalendar(
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
                            markerSize: 40,
                            markerMargin: EdgeInsets.only(bottom: 0),
                            markersAnchor: 1.0,
                            markersOffset: PositionedOffset(top: 0, bottom: 0),
                            markersAlignment: Alignment.center,
                            canMarkersOverflow: true,
                            markerDecoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.red[500]!,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            //todayDecoration: Colors.orange,
                            //selectedDecoration: Colors.orange,
                            todayTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.orange)),
                        headerStyle: HeaderStyle(
                          headerMargin: EdgeInsets.all(10),
                          //leftChevronVisible: false,
                          //rightChevronVisible: false,
                          titleCentered: true,
                          formatButtonDecoration: BoxDecoration(
                            color: Colors.orange,
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
                              )),
                          todayBuilder: (context, date, events) => Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Text(
                                date.day.toString(),
                                //style: TextStyle(color: Colors.white),
                              )),
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
                      Container(
                        height: 50,
                        child: Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 20, 10, 15),
                                child: Text(
                                  t.events,
                                  style: TextStyles.headline(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "serif",
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                      items.length == 0
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 0, 10, 15),
                                child: Text(
                                  "No events for selected month",
                                  style: TextStyles.headline(context).copyWith(
                                    // fontWeight: FontWeight.bold,
                                    // fontFamily: "serif",
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: items.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              padding: EdgeInsets.all(3),
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
    @required this.index,
    @required this.events,
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
        height: 60,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(15, 0, 15, 5),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Container(width: 10),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                                DateFormat('EEE, MMM d, yyyy', 'en_US').format(tempDate),
                                style: TextStyles.caption(context)
                                //.copyWith(color: MyColors.grey_60),
                                ),
                            Spacer(),
                            Text(events!.time!,
                                style: TextStyles.caption(context)
                                //.copyWith(color: MyColors.grey_60),
                                ),
                          ],
                        ),
                        Spacer(),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(events!.title!,
                              maxLines: 1,
                              style: TextStyles.subhead(context).copyWith(
                                  //color: MyColors.grey_80,
                                  fontWeight: FontWeight.w500)),
                        ),
                        Spacer(),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 10,
            ),
            Divider(
              height: 0.1,
              //color: Colors.grey.shade800,
            )
          ],
        ),
      ),
    );
  }
}



