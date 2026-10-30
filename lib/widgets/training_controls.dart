
import 'package:flutter/material.dart';

import '../controllers/training_controller.dart';
import '../models/training_settings.dart';

class TrainingControls extends StatelessWidget {
  final TrainingSettings impostazioni;
  final TrainingController controller;
  final VoidCallback onModifica;

  const TrainingControls({
    super.key,
    required this.impostazioni,
    required this.controller,
    required this.onModifica,
  });

  @override
  Widget build(BuildContext context) {
    final attivo = controller.attivo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            'Allenamento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Ripetizioni per sessione
        const Text('Ripetizioni per sessione'),

        DropdownButton<int>(
          value: impostazioni.ripetizioni,
          isExpanded: true,
          items: [5, 10, 20, 30, 50, 100]
              .map(
                (numero) => DropdownMenuItem<int>(
                  value: numero,
                  child: Text('$numero stimoli'),
                ),
              )
              .toList(),
          onChanged: attivo
              ? null
              : (valore) {
                  if (valore != null) {
                    impostazioni.ripetizioni = valore;
                    onModifica();
                  }
                },
        ),

        const SizedBox(height: 12),

        // Numero di sessioni
        const Text('Numero di sessioni'),

        DropdownButton<int>(
          value: impostazioni.numeroSessioni,
          isExpanded: true,
          items: [1, 2, 3, 4, 5, 10]
              .map(
                (numero) => DropdownMenuItem<int>(
                  value: numero,
                  child: Text('$numero sessioni'),
                ),
              )
              .toList(),
          onChanged: attivo
              ? null
              : (valore) {
                  if (valore != null) {
                    impostazioni.numeroSessioni = valore;
                    onModifica();
                  }
                },
        ),

        // Pausa tra sessioni
        if (impostazioni.numeroSessioni > 1) ...[
          const SizedBox(height: 12),

          Text(
            'Pausa tra sessioni: '
            '${impostazioni.pausaSessioni.round()} secondi',
          ),

          Slider(
            value: impostazioni.pausaSessioni,
            min: 0,
            max: 120,
            divisions: 24,
            onChanged: attivo
                ? null
                : (valore) {
                    impostazioni.pausaSessioni = valore;
                    onModifica();
                  },
          ),
        ],

        const SizedBox(height: 20),

        // Stato dell'allenamento
        if (attivo) ...[
          Text(
            controller.inPausa
                ? 'PAUSA TRA SESSIONI'
                : 'ALLENAMENTO IN CORSO',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: controller.inPausa
                  ? Colors.orangeAccent
                  : Colors.greenAccent,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Sessione ${controller.sessioneCorrente} '
            'di ${impostazioni.numeroSessioni}',
            textAlign: TextAlign.center,
          ),

          Text(
            'Stimoli nella sessione: '
            '${controller.stimoliSessione} / '
            '${impostazioni.ripetizioni}',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),
        ],

        Text(
          'Stimoli totali: '
          '${controller.stimoliEmessi} / '
          '${impostazioni.totaleStimoli}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),

        const SizedBox(height: 16),

        FilledButton.icon(
          onPressed: attivo
              ? null
              : () {
                  controller.avvia(impostazioni);
                },
          icon: const Icon(Icons.play_arrow),
          label: const Text('AVVIA ALLENAMENTO'),
        ),

        const SizedBox(height: 10),

        OutlinedButton.icon(
          onPressed: attivo
              ? () {
                  controller.interrompi();
                }
              : null,
          icon: const Icon(Icons.stop),
          label: const Text('INTERROMPI'),
        ),

        if (controller.errore != null) ...[
          const SizedBox(height: 16),

          Text(
            controller.errore!,
            style: const TextStyle(
              color: Colors.redAccent,
            ),
          ),
        ],
      ],
    );
  }
}
