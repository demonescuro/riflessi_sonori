import 'package:flutter/material.dart';

import '../controllers/reflex_test_controller.dart';
import '../models/reflex_test_settings.dart';
import '../models/training_settings.dart';
import 'reflex_target.dart';

class ReflexTestPanel extends StatelessWidget {
  final ReflexTestSettings impostazioniTest;
  final TrainingSettings impostazioniSuono;
  final ReflexTestController controller;
  final VoidCallback onModifica;

  const ReflexTestPanel({
    super.key,
    required this.impostazioniTest,
    required this.impostazioniSuono,
    required this.controller,
    required this.onModifica,
  });

  String _messaggioStato() {
    switch (controller.stato) {
      case StatoTestRiflessi.pronto:
        return 'Imposta il test e premi AVVIA';
      case StatoTestRiflessi.attesa:
        return 'Attendi il segnale';
      case StatoTestRiflessi.segnale:
        return 'TAP NOW!';
      case StatoTestRiflessi.risultato:
        if (controller.ultimoToccoAnticipato) {
          return 'Tocco anticipato';
        }

        return '${controller.ultimoTempoMs} ms';
      case StatoTestRiflessi.completato:
        return 'Test completato';
    }
  }

  Color _coloreStato(BuildContext context) {
    final colori = Theme.of(context).colorScheme;

    if (controller.stato == StatoTestRiflessi.segnale) {
      return colori.secondary;
    }

    if (controller.ultimoToccoAnticipato &&
        controller.stato == StatoTestRiflessi.risultato) {
      return colori.error;
    }

    if (controller.stato == StatoTestRiflessi.risultato ||
        controller.stato == StatoTestRiflessi.completato) {
      return colori.primary;
    }

    return colori.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final attivo = controller.attivo;
    final segnaleAttivo = controller.segnaleAttivo;
    final colori = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            'Test riflessi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const Text(
          'Ripetizioni',
        ),

        DropdownButton<int>(
          value: impostazioniTest.ripetizioni,
          isExpanded: true,
          items: const [5, 10, 15, 20, 30]
              .map(
                (numero) => DropdownMenuItem(
                  value: numero,
                  child: Text('$numero prove'),
                ),
              )
              .toList(),
          onChanged: attivo
              ? null
              : (valore) {
                  if (valore == null) return;

                  impostazioniTest.ripetizioni = valore;
                  onModifica();
                },
        ),

        const SizedBox(height: 8),

        Text(
          'Attesa minima: '
          '${impostazioniTest.intervalloMinimo.toStringAsFixed(1)} s',
        ),

        Slider(
          value: impostazioniTest.intervalloMinimo,
          min: 0.5,
          max: impostazioniTest.intervalloMassimo - 0.5,
          divisions: 22,
          onChanged: attivo
              ? null
              : (valore) {
                  impostazioniTest.intervalloMinimo = valore;
                  onModifica();
                },
        ),

        Text(
          'Attesa massima: '
          '${impostazioniTest.intervalloMassimo.toStringAsFixed(1)} s',
        ),

        Slider(
          value: impostazioniTest.intervalloMassimo,
          min: impostazioniTest.intervalloMinimo + 0.5,
          max: 12,
          divisions: 22,
          onChanged: attivo
              ? null
              : (valore) {
                  impostazioniTest.intervalloMassimo = valore;
                  onModifica();
                },
        ),

        const SizedBox(height: 12),

        Text(
          'Prova ${controller.ripetizioneCorrente} '
          'di ${impostazioniTest.ripetizioni}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        AnimatedScale(
          scale: segnaleAttivo ? 1.04 : 1,
          duration: const Duration(milliseconds: 100),
          child: Center(
            child: ReflexTarget(
              segnaleAttivo: segnaleAttivo,
              abilitato: attivo,
              onTap: controller.registraTocco,
            ),
          ),
        ),

        const SizedBox(height: 14),

        Text(
          _messaggioStato(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _coloreStato(context),
            fontSize: controller.stato == StatoTestRiflessi.risultato ||
                    controller.stato == StatoTestRiflessi.segnale
                ? 27
                : 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _Metrica(
                etichetta: 'ULTIMO',
                valore: controller.ultimoTempoMs == null
                    ? '--'
                    : '${controller.ultimoTempoMs} ms',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Metrica(
                etichetta: 'MIGLIORE',
                valore: controller.migliorTempoMs == null
                    ? '--'
                    : '${controller.migliorTempoMs} ms',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Metrica(
                etichetta: 'MEDIA',
                valore: controller.mediaTempoMs == null
                    ? '--'
                    : '${controller.mediaTempoMs} ms',
              ),
            ),
          ],
        ),

        if (controller.tocchiAnticipati > 0) ...[
          const SizedBox(height: 10),
          Text(
            'Tocchi anticipati: ${controller.tocchiAnticipati}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colori.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],

        const SizedBox(height: 18),

        FilledButton.icon(
          onPressed: attivo
              ? null
              : () {
                  controller.avvia(
                    impostazioniTest,
                    impostazioniSuono,
                  );
                },
          icon: const Icon(Icons.play_arrow),
          label: const Text('AVVIA TEST'),
        ),

        const SizedBox(height: 10),

        OutlinedButton.icon(
          onPressed: attivo ? controller.interrompi : null,
          icon: const Icon(Icons.stop),
          label: const Text('INTERROMPI TEST'),
        ),
      ],
    );
  }
}

class _Metrica extends StatelessWidget {
  final String etichetta;
  final String valore;

  const _Metrica({
    required this.etichetta,
    required this.valore,
  });

  @override
  Widget build(BuildContext context) {
    final colori = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: colori.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colori.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        children: [
          Text(
            etichetta,
            style: TextStyle(
              color: colori.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valore,
            style: TextStyle(
              color: colori.primary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}