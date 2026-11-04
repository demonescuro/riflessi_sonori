import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class RiflessiSonoriApp extends StatelessWidget {
  const RiflessiSonoriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riflessi Sonori',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.chiaro,
      home: const HomeScreen(),
    );
  }
}