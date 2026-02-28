import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/constants/colors.dart';
import 'core/providers/providers.dart' show kDemoMode;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: NexusColors.bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Firebase & Hive disabled in demo mode.
  // Re-enable by setting kDemoMode = false in providers.dart,
  // then un-commenting the lines below.
  if (!kDemoMode) {
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // await Hive.initFlutter();
  }

  runApp(
    const ProviderScope(
      child: NexusApp(),
    ),
  );
}

class NexusApp extends ConsumerWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'NEXUS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: NexusColors.bg,
        colorScheme: const ColorScheme.dark(
          background: NexusColors.bg,
          surface: NexusColors.surface,
          primary: NexusColors.cyan,
          secondary: NexusColors.violet,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      routerConfig: router,
    );
  }
}
