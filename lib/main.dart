import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/quote_feed_screen.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const WizScrollApp());
  } catch (e, stackTrace) {
    // Print error visibly so it shows in Chrome DevTools console (F12)
    debugPrint('╔══════════════════════════════════════════');
    debugPrint('║ STARTUP ERROR: $e');
    debugPrint('║ Stack: $stackTrace');
    debugPrint('╚══════════════════════════════════════════');
    // Still show something on screen
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Startup error:\n$e',
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ));
  }
}

class WizScrollApp extends StatelessWidget {
  const WizScrollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WizScroll',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const CustomScrollBehavior(),
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFB39DDB),
          surface: Colors.black,
        ),
      ),
      home: const QuoteFeedScreen(),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  const CustomScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
