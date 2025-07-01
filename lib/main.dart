import 'dart:io';

import 'package:base_project/pages/pages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home:
          kIsWeb || Platform.isMacOS
              ? const GoogleCalendarHome()
              : const CalendarSelectionPage(),
    );
  }
}
