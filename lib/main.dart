import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/user_profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final provider = UserProfileProvider();
  await provider.loadFromPrefs();

  runApp(UIUCGPACalculatorApp(profileProvider: provider));
}

class UIUCGPACalculatorApp extends StatefulWidget {
  final UserProfileProvider profileProvider;

  const UIUCGPACalculatorApp({super.key, required this.profileProvider});

  @override
  State<UIUCGPACalculatorApp> createState() => _UIUCGPACalculatorAppState();
}

class _UIUCGPACalculatorAppState extends State<UIUCGPACalculatorApp> {
  @override
  void initState() {
    super.initState();
    widget.profileProvider.addListener(_onProviderChange);
  }

  @override
  void dispose() {
    widget.profileProvider.removeListener(_onProviderChange);
    super.dispose();
  }

  void _onProviderChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ProfileProviderScope(
      provider: widget.profileProvider,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: widget.profileProvider.themeMode,
        home: const SplashScreen(),
      ),
    );
  }
}

/// Simple InheritedWidget to expose UserProfileProvider down the tree
class ProfileProviderScope extends InheritedWidget {
  final UserProfileProvider provider;

  const ProfileProviderScope({
    super.key,
    required this.provider,
    required super.child,
  });

  static UserProfileProvider of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ProfileProviderScope>();
    assert(scope != null, 'No ProfileProviderScope found in context');
    return scope!.provider;
  }

  @override
  bool updateShouldNotify(ProfileProviderScope oldWidget) =>
      provider != oldWidget.provider;
}
