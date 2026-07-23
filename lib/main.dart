import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:d_c_i_teacher_app/auth/firebase_auth/auth_util.dart';
import 'package:d_c_i_teacher_app/auth/firebase_auth/firebase_user_provider.dart';

import 'package:d_c_i_teacher_app/backend/firebase/firebase_config.dart';
import 'package:d_c_i_teacher_app/backend/services/app_router.dart';
import 'package:d_c_i_teacher_app/backend/services/notification_service.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  try {
    await initFirebase();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  try {
    // Initialize Notifications
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Notification initialization failed: $e');
  }

  // Initialize Crashlytics
  if (!kIsWeb) {
    try {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    } catch (e) {
      debugPrint('Crashlytics initialization failed: $e');
    }
  }

  try {
    await FlutterFlowTheme.initialize();
  } catch (e) {
    debugPrint('FlutterFlowTheme initialization failed: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class MyAppState extends ConsumerState<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  ThemeMode get themeMode => _themeMode;

  late Stream<BaseAuthUser> userStream;

  @override
  void initState() {
    super.initState();
    userStream = dciTeacherAppFirebaseUserStream()
      ..listen((user) => safeSetState(() => currentUser = user));
    jwtTokenStream.listen((_) {});
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Deshmukh Coaching Institute',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      routerConfig: router,
    );
  }
}
