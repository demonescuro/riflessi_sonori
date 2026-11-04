import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/reflex_test_controller.dart';
import '../controllers/training_controller.dart';
import '../models/reflex_test_settings.dart';
import '../models/training_settings.dart';
import '../widgets/interval_controls.dart';
import '../widgets/reflex_test_panel.dart';
import '../widgets/sound_controls.dart';
import '../widgets/training_controls.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TrainingSettings impostazioni = TrainingSettings();
  final TrainingController controller = TrainingController();

  final ReflexTestSettings impostazioniTest =
      ReflexTestSettings();

  final ReflexTestController controllerTest =
      ReflexTestController();

  Timer? _timerFlash;
  bool _flashAttivo = false;
  bool _segnaleTestPrecedente = false;

  @override
  void initState() {
    super.initState();

    controller.addListener(_aggiornaSchermata);
    controllerTest.addListener(_aggiornaSchermata);
  }

  void _aggiornaSchermata() {
    if (!mounted) return;

    final segnaleAppenaPartito =
        controllerTest.segnaleAttivo &&
        !_segnaleTestPrecedente;

    _segnaleTestPrecedente = controllerTest.segnaleAttivo;

    if (segnaleAppenaPartito) {
      _timerFlash?.cancel();

      setState(() {
        _flashAttivo = true;
      });

      _timerFlash = Timer(
        const Duration(milliseconds: 180),
        () {
          if (!mounted) return;

          setState(() {
            _flashAttivo = false;
          });
        },
      );

      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _timerFlash?.cancel();

    controller.removeListener(_aggiornaSchermata);
    controller.dispose();

    controllerTest.removeListener(_aggiornaSchermata);
    controllerTest.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allenamentoAttivo = controller.attivo;
    final testAttivo = controllerTest.attivo;

    final colori = Theme.of(context).colorScheme;
    final sfondoNormale =
        Theme.of(context).scaffoldBackgroundColor;

    final coloreSfondo = _flashAttivo
        ? colori.secondary.withValues(alpha: 0.28)
        : sfondoNormale;

    return Scaffold(
      backgroundColor: coloreSfondo,
      appBar: AppBar(
        backgroundColor: coloreSfondo,
        title: const Text(
          'Riflessi Sonori',
          style: TextStyle(
            color: Color(0xFF2563EB),
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        color: coloreSfondo,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              28,
            ),
            children: [
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: colori.primary.withValues(
                      alpha: 0.10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.graphic_eq,
                    size: 42,
                    color: colori.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              AbsorbPointer(
                absorbing: testAttivo,
                child: Opacity(
                  opacity: testAttivo ? 0.55 : 1,
                  child: Column(
                    children: [
                      _Pannello(
                        child: SoundControls(
                          impostazioni: impostazioni,
                          attivo: allenamentoAttivo || testAttivo,
                          onModifica: () {
                            setState(() {});
                          },
                          onProvaSuono: () {
                            controller.provaSuono(impostazioni);
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      _Pannello(
                        child: IntervalControls(
                          impostazioni: impostazioni,
                          attivo: allenamentoAttivo || testAttivo,
                          onModifica: () {
                            setState(() {});
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      _Pannello(
                        child: TrainingControls(
                          impostazioni: impostazioni,
                          controller: controller,
                          onModifica: () {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              AbsorbPointer(
                absorbing: allenamentoAttivo,
                child: Opacity(
                  opacity: allenamentoAttivo ? 0.55 : 1,
                  child: _Pannello(
                    child: ReflexTestPanel(
                      impostazioniTest: impostazioniTest,
                      impostazioniSuono: impostazioni,
                      controller: controllerTest,
                      onModifica: () {
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pannello extends StatelessWidget {
  final Widget child;

  const _Pannello({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colori = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        4,
        18,
        18,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colori.primary.withValues(alpha: 0.48),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}