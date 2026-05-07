import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themes/app_theme.dart';
import 'core/navigation/main_navigation.dart';
import 'core/providers/charging_point_provider.dart';
import 'services/notification_service.dart';

void main() {
  runApp(const EVGramaApp());
}

class EVGramaApp extends StatelessWidget {
  const EVGramaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChargingPointProvider()..initializeSampleData(),
      child: MaterialApp(
        title: 'EV-Grama Charge',
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
        home: const MainNavigation(),
        debugShowCheckedModeBanner: false,
        navigatorKey: NotificationService.navigatorKey,
      ),
    );
  }
}
