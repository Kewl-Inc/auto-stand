import 'package:auto_stand/services/google_calendar.dart';
import 'package:auto_stand/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:auto_stand/models/models.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class GoogleCalendarHome extends StatefulWidget {
  const GoogleCalendarHome({super.key});

  @override
  State<GoogleCalendarHome> createState() => _GoogleCalendarHomeState();
}

class _GoogleCalendarHomeState extends State<GoogleCalendarHome> {
  final Logger _logger = Logger();
  final GoogleCalendarService _calendarService = GoogleCalendarService();

  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  bool _isLoading = false;
  List<CalendarEvent> _events = [];
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    final signedIn = await _calendarService.isSignedIn();
    setState(() {
      _currentUser = _calendarService.currentUser;
      _isAuthorized = signedIn;
    });
    if (signedIn) {
      _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Kewl Proto'),
        actions: [
          if (_currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _isLoading ? null : _signOut,
              tooltip: 'Sign Out',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    // If user is not signed in or not authorized, show Google Sign-In widget
    if (_currentUser == null || !_isAuthorized) {
      return GoogleSignInWidget(
        currentUser: _currentUser,
        isAuthorized: _isAuthorized,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onSignIn: _signIn,
        onSignOut: _signOut,
        onRequestPermissions: _requestPermissions,
      );
    }

    // If user is signed in and authorized, show calendar events
    return CalendarEventsWidget(
      events: _events,
      selectedDate: _selectedDate,
      onDateChanged: _handleDateChange,
      onRefresh: _loadEvents,
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_currentUser == null || !_isAuthorized) {
      return null;
    }

    return FloatingActionButton(
      onPressed: _loadEvents,
      tooltip: 'Refresh Events',
      child: const Icon(Icons.refresh),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _logger.d('Starting sign-in process...');
      final success = await _calendarService.signIn();
      _logger.d('Sign-in result: $success');

      if (success) {
        setState(() {
          _currentUser = _calendarService.currentUser;
          _errorMessage = '';
        });
        _logger.d('Successfully signed in: ${_currentUser?.email}');
      } else {
        setState(() {
          _errorMessage = 'Sign-in was cancelled or failed. Please try again.';
        });
        _logger.d('Sign-in failed or was cancelled');
      }
    } catch (e) {
      _logger.d('Sign-in error: $e');
      setState(() {
        _errorMessage = 'Sign-in error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _logger.d('Starting sign-out process...');
      await _calendarService.signOut();
      setState(() {
        _currentUser = null;
        _isAuthorized = false;
        _events = [];
        _errorMessage = '';
      });
      _logger.d('Sign-out completed successfully');
    } catch (e) {
      _logger.d('Sign-out error: $e');
      setState(() {
        _errorMessage = 'Sign-out error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (_currentUser == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _logger.d('Requesting calendar permissions...');
      final events = await _calendarService.getEventsForDate(_selectedDate);
      setState(() {
        _events = events;
        _isAuthorized = true;
        _errorMessage = '';
      });
      _logger.d('Calendar permissions granted, loaded ${events.length} events');
    } catch (e) {
      _logger.d('Failed to request permissions: $e');
      setState(() {
        _errorMessage = 'Failed to request permissions: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEvents() async {
    if (!_isAuthorized) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final events = await _calendarService.getEventsForDate(_selectedDate);
      setState(() {
        _events = events;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load events: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleDateChange() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadEvents();
    }
  }
}
