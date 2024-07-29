import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleAPI;
import 'package:http/io_client.dart' show IOClient, IOStreamedResponse;
import 'package:http/http.dart' show BaseRequest, Response;
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AppointmentPage extends StatefulWidget {
  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  List<GoogleAPI.Event> _events = [];

  Future<void> getGoogleEventsData() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final GoogleAPIClient httpClient = GoogleAPIClient(googleAuth.accessToken!);
        final GoogleAPI.CalendarApi calendarApi = GoogleAPI.CalendarApi(httpClient);
        final GoogleAPI.Events calEvents = await calendarApi.events.list("primary");
        final List<GoogleAPI.Event> appointments = <GoogleAPI.Event>[];

        if (calEvents.items != null) {
          final now = DateTime.now();
          for (int i = 0; i < calEvents.items!.length; i++) {
            final GoogleAPI.Event event = calEvents.items![i];
            if (event.start == null) {
              continue;
            }
            final eventStart = event.start!.dateTime ?? event.start!.date;
            if (eventStart!.isAfter(now)) {
              appointments.add(event);
            }
          }
        }

        setState(() {
          _events = appointments.take(3).toList();
        });
      }
    } catch (e) {
      print('Error fetching events: $e');
      // Handle error fetching events
    }
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> upcomingEventWidgets = [];

    if (_events.isEmpty) {
      upcomingEventWidgets.add(
        Center(child: CircularProgressIndicator()),
      );
    } else {
      for (int i = 0; i < _events.length && i < 3; i++) {
        final GoogleAPI.Event event = _events[i];
        if (event.start == null) {
          continue;
        }
        upcomingEventWidgets.add(
          ListTile(
            title: Text(event.summary ?? 'No Title'),
            subtitle: Text(
              'Starts: ${event.start!.dateTime?.toLocal() ?? event.start!.date ?? 'Unknown'}',
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Google Calendar Events'),
      ),
      body: ListView(
        children: upcomingEventWidgets.isEmpty
            ? [Center(child: CircularProgressIndicator())]
            : upcomingEventWidgets,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await getGoogleEventsData();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class GoogleDataSource extends CalendarDataSource {
  GoogleDataSource({required List<GoogleAPI.Event>? events}) {
    appointments = events;
  }

  @override
  DateTime getStartTime(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.start?.date ?? event.start!.dateTime!.toLocal();
  }

// Implement other overrides (getEndTime, isAllDay, getLocation, getNotes, getSubject) similarly
// ...
}

class GoogleAPIClient extends IOClient {
  final String accessToken;

  GoogleAPIClient(this.accessToken) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers['Authorization'] = 'Bearer $accessToken');

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url, headers: headers!..addAll({'Authorization': 'Bearer $accessToken'}));
}
