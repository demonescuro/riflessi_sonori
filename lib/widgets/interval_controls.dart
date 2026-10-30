
import 'package:flutter/material.dart';

import '../models/training_settings.dart';

class IntervalControls extends StatelessWidget {
  final TrainingSettings impostazioni;
  final bool attivo;
  final VoidCallback onModifica;

  const IntervalControls({
    super.key,
    required this.impostazioni,
    required this.attivo,
    required this.onModifica,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            'Intervalli casuali',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Text(
          'Minimo: '
          '${impostazioni.intervalloMinimo.toStringAsFixed(1)} s',
        ),

        Slider(
          value: impostazioni.intervalloMinimo,
          min: 0.5,
          max: 10,
          divisions: 19,
          onChanged: attivo
              ? null
              : (valore) {
                  impostazioni.intervalloMinimo = valore;

                  if (impostazioni.intervalloMinimo >
                      impostazioni.intervalloMassimo) {
                    impostazioni.intervalloMassimo = valore;
                  }

                  onModifica();
                },
        ),

        Text(
          'Massimo: '
          '${impostazioni.intervalloMassimo.toStringAsFixed(1)} s',
        ),

        Slider(
          value: impostazioni.intervalloMassimo,
          min: 0.5,
          max: 20,
          divisions: 39,
          onChanged: attivo
              ? null
              : (valore) {
                  impostazioni.intervalloMassimo = valore;

                  if (impostazioni.intervalloMassimo <
                      impostazioni.intervalloMinimo) {
                    impostazioni.intervalloMinimo = valore;
                  }

                  onModifica();
                },
        ),
      ],
    );
  }
}
