import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_stand/pages/pages.dart';
import 'package:auto_stand/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables (skip on web)
  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      print('Warning: .env file not found. Using fallback configuration.');
    }
  }
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(
    const ProviderScope(
      child: AutoStandApp(),
    ),
  );
}

class AutoStandApp extends ConsumerWidget {
  const AutoStandApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'AutoStand',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/setup',
      builder: (context, state) => const SetupPage(),
    ),
    GoRoute(
      path: '/team/:teamId',
      builder: (context, state) => TeamDashboard(
        teamId: state.pathParameters['teamId']!,
      ),
    ),
    GoRoute(
      path: '/team/:teamId/template',
      builder: (context, state) => TemplateSetupPage(
        teamId: state.pathParameters['teamId']!,
      ),
    ),
    GoRoute(
      path: '/team/:teamId/digest/:date',
      builder: (context, state) => DigestViewPage(
        teamId: state.pathParameters['teamId']!,
        date: DateTime.parse(state.pathParameters['date']!),
      ),
    ),
    GoRoute(
      path: '/update/create',
      builder: (context, state) => const CreateUpdatePage(),
    ),
  ],
);