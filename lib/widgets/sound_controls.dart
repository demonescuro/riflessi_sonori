import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../models/training_settings.dart';

class SoundControls extends StatelessWidget {
  final TrainingSettings impostazioni;
  final bool attivo;
  final VoidCallback onModifica;
  final VoidCallback onProvaSuono;

  const SoundControls({
    super.key,
    required this.impostazioni,
    required this.attivo,
    required this.onModifica,
    required this.onProvaSuono,
  });

  String _nomeSuono(SuonoAllenamento suono) {
    switch (suono) {
      case SuonoAllenamento.bip:
        return 'Bip sintetico';
      case SuonoAllenamento.click:
        return 'Click secco';
      case SuonoAllenamento.fischio:
        return 'Fischio acuto';
      case SuonoAllenamento.metallico:
        return 'Colpo metallico';
      case SuonoAllenamento.elettronico:
        return 'Segnale elettronico';
    }
  }

  Future<void> _scegliAudio(BuildContext context) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.audio,
      );

      if (file == null) return;

      if (file.path == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Impossibile leggere il file selezionato.',
              ),
            ),
          );
        }
        return;
      }

      if (!context.mounted) return;

      impostazioni.percorsoAudio = file.path;
      onModifica();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audio selezionato: ${file.name}'),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante la selezione: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioImportato = impostazioni.usaAudioImportato;
    final usaBip = !audioImportato &&
        impostazioni.suonoSelezionato == SuonoAllenamento.bip;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            'Suono',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Text(
          audioImportato
              ? 'Sorgente: audio personalizzato'
              : 'Sorgente: libreria offline',
        ),

        const SizedBox(height: 12),

        const Text('Suono della libreria'),

        DropdownButton<SuonoAllenamento>(
          value: impostazioni.suonoSelezionato,
          isExpanded: true,
          items: SuonoAllenamento.values.map((suono) {
            return DropdownMenuItem<SuonoAllenamento>(
              value: suono,
              child: Text(_nomeSuono(suono)),
            );
          }).toList(),
          onChanged: attivo
              ? null
              : (valore) {
                  if (valore == null) return;

                  impostazioni.suonoSelezionato = valore;
                  impostazioni.percorsoAudio = null;
                  onModifica();
                },
        ),

        Text(
          audioImportato
              ? 'Per usare la libreria, scegli un suono oppure '
                  'premi TORNA ALLA LIBRERIA.'
              : 'Lo stesso suono verrà usato per tutte le '
                  'ripetizioni e tutte le sessioni.',
          style: const TextStyle(fontSize: 13),
        ),

        const SizedBox(height: 16),

        if (usaBip) ...[
          Text('Frequenza: ${impostazioni.frequenza} Hz'),

          DropdownButton<int>(
            value: impostazioni.frequenza,
            isExpanded: true,
            items: const [
              DropdownMenuItem(
                value: 600,
                child: Text('Bip medio'),
              ),
              DropdownMenuItem(
                value: 880,
                child: Text('Bip acuto'),
              ),
              DropdownMenuItem(
                value: 1200,
                child: Text('Bip molto acuto'),
              ),
            ],
            onChanged: attivo
                ? null
                : (valore) {
                    if (valore == null) return;

                    impostazioni.frequenza = valore;
                    onModifica();
                  },
          ),

          Text(
            'Durata del bip: ${impostazioni.durataSuonoMs} ms',
          ),

          Slider(
            value: impostazioni.durataSuonoMs.toDouble(),
            min: 80,
            max: 800,
            divisions: 18,
            onChanged: attivo
                ? null
                : (valore) {
                    impostazioni.durataSuonoMs = valore.round();
                    onModifica();
                  },
          ),

          const SizedBox(height: 8),
        ],

        Text(
          'Volume: ${(impostazioni.volume * 100).round()}%',
        ),

        Slider(
          value: impostazioni.volume,
          min: 0,
          max: 1,
          divisions: 20,
          onChanged: attivo
              ? null
              : (valore) {
                  impostazioni.volume = valore;
                  onModifica();
                },
        ),

        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: attivo
              ? null
              : () => _scegliAudio(context),
          icon: const Icon(Icons.audio_file),
          label: const Text('IMPORTA AUDIO'),
        ),

        if (audioImportato) ...[
          const SizedBox(height: 8),

          Text(
            'File selezionato: '
            '${impostazioni.percorsoAudio!.split(RegExp(r'[/\\]')).last}',
            style: const TextStyle(fontSize: 13),
          ),

          TextButton.icon(
            onPressed: attivo
                ? null
                : () {
                    impostazioni.percorsoAudio = null;
                    onModifica();
                  },
            icon: const Icon(Icons.restore),
            label: const Text('TORNA ALLA LIBRERIA'),
          ),
        ],

        const SizedBox(height: 8),

        OutlinedButton.icon(
          onPressed: attivo ? null : onProvaSuono,
          icon: const Icon(Icons.volume_up),
          label: const Text('PROVA SUONO'),
        ),
      ],
    );
  }
}