import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class RiflessiSonoriApp extends StatelessWidget {
  const RiflessiSonoriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riflessi Sonori',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}