
import 'package:flutter/material.dart';

import '../controllers/training_controller.dart';
import '../models/training_settings.dart';
import '../widgets/sound_controls.dart';
import '../widgets/interval_controls.dart';
import '../widgets/training_controls.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TrainingSettings impostazioni = TrainingSettings();
  final TrainingController controller = TrainingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_aggiornaSchermata);
  }

  void _aggiornaSchermata() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.removeListener(_aggiornaSchermata);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attivo = controller.attivo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riflessi Sonori'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.graphic_eq, size: 60),

            SoundControls(
              impostazioni: impostazioni,
              attivo: attivo,
              onModifica: () {
                setState(() {});
              },
              onProvaSuono: () {
                controller.provaSuono(impostazioni);
              },
            ),

            IntervalControls(
              impostazioni: impostazioni,
              attivo: attivo,
              onModifica: () {
                setState(() {});
              },
            ),

            TrainingControls(
              impostazioni: impostazioni,
              controller: controller,
              onModifica: () {
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
