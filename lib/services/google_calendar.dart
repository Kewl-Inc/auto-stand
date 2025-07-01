import 'dart:io';

import 'package:auto_stand/models/models.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar_api;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GoogleCalendarService implements CalendarServiceInterface {
  final Logger _logger = Logger();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      calendar_api.CalendarApi.calendarReadonlyScope,
      'email',
      'profile',
    ],
    clientId: _getClientId(),
  );

  @override
  Future<bool> isAvailable() async {
    return await isSignedIn();
  }

  @override
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    if (currentUser == null) {
      throw Exception('Not signed in to Google Calendar');
    }

    final googleUser = await _googleSignIn.signInSilently();
    if (googleUser == null) {
      throw Exception('Google user not available');
    }
    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    if (accessToken == null) {
      throw Exception('No Google access token');
    }

    final client = _GoogleAuthClient(accessToken);
    final calendar = calendar_api.CalendarApi(client);

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final events = await calendar.events.list(
      'primary',
      timeMin: startOfDay.toUtc(),
      timeMax: endOfDay.toUtc(),
      singleEvents: true,
      orderBy: 'startTime',
    );

    return (events.items ?? [])
        .where((event) => event.start != null)
        .map(CalendarEvent.fromGoogleEvent)
        .toList();
  }

  @override
  Future<List<CalendarEvent>> getEventsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (currentUser == null) {
      throw Exception('Not signed in to Google Calendar');
    }

    final googleUser = await _googleSignIn.signInSilently();
    if (googleUser == null) {
      throw Exception('Google user not available');
    }
    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    if (accessToken == null) {
      throw Exception('No Google access token');
    }

    final client = _GoogleAuthClient(accessToken);
    final calendar = calendar_api.CalendarApi(client);

    final events = await calendar.events.list(
      'primary',
      timeMin: startDate.toUtc(),
      timeMax: endDate.toUtc(),
      singleEvents: true,
      orderBy: 'startTime',
    );

    return (events.items ?? [])
        .where((event) => event.start != null)
        .map(CalendarEvent.fromGoogleEvent)
        .toList();
  }

  Future<bool> isSignedIn() async {
    final googleUser = await _googleSignIn.signInSilently();
    final signedIn = googleUser != null;
    _logger.d('isSignedIn: $signedIn');
    return signedIn;
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<bool> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.d('User cancelled sign-in');
        return false;
      }

      _logger.d('Sign-in completed');
      return true;
    } catch (e) {
      _logger.e('Error signing in: $e');
      try {
        await _googleSignIn.signOut();
      } catch (signOutError) {
        _logger.e('Error signing out from Google Sign-In: $signOutError');
      }
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      _logger.e('Error signing out: $e');
    }
  }

  static String? _getClientId() {
    if (kIsWeb) {
      return '1064271066268-5l1u9ucbrrpd851gmq4cdtgrq2ulo4sc.apps.googleusercontent.com';
    } else if (Platform.isIOS || Platform.isMacOS) {
      return '1064271066268-23obc97p98vvsto6ibs4cn55dpnlmq0o.apps.googleusercontent.com';
    } else {
      // Android doesn't require client ID
      return null;
    }
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _client = http.Client();
  _GoogleAuthClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _client.send(request);
  }
}
