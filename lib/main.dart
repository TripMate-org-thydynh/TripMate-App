import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('vi'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    // Watch for theme changes to rebuild the MaterialApp
    _themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripMate',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: TripMateTheme.lightTheme,
      darkTheme: TripMateTheme.darkTheme,
      themeMode: _themeProvider.themeMode,
      home: SplashScreen(
        isDarkMode: _themeProvider.isDarkMode,
        onThemeToggle: () {
          setState(() {
            _themeProvider.toggleTheme();
          });
        },
      ),
    );
  }
}
