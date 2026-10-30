import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

import '../models/training_settings.dart';
import 'tone_generator.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> riproduciStimolo(
    TrainingSettings impostazioni,
  ) async {
    await _player.stop();

    final percorso = impostazioni.percorsoAudio;

    if (percorso != null) {
      await _player.play(
        DeviceFileSource(percorso),
        volume: impostazioni.volume,
      );
      return;
    }

    final suono = impostazioni.suonoSelezionato;
    final Uint8List wav;

    if (suono == SuonoAllenamento.bip) {
      wav = ToneGenerator.generaWav(
        frequenza: impostazioni.frequenza,
        durataMs: impostazioni.durataSuonoMs,
      );
    } else {
      wav = _generaSuono(suono);
    }

    await _player.play(
      BytesSource(wav),
      volume: impostazioni.volume,
    );
  }

  Uint8List _generaSuono(SuonoAllenamento suono) {
    const frequenzaCampionamento = 44100;

    final int durataMs;

    switch (suono) {
      case SuonoAllenamento.bip:
        durataMs = 150;
        break;
      case SuonoAllenamento.click:
        durataMs = 90;
        break;
      case SuonoAllenamento.fischio:
        durataMs = 180;
        break;
      case SuonoAllenamento.metallico:
        durataMs = 220;
        break;
      case SuonoAllenamento.elettronico:
        durataMs = 160;
        break;
    }

    final numeroCampioni =
        frequenzaCampionamento * durataMs ~/ 1000;
    final durataSecondi = durataMs / 1000.0;

    final casuale = math.Random(42);
    final dati = ByteData(44 + numeroCampioni * 2);

    void scriviTesto(int posizione, String testo) {
      for (var i = 0; i < testo.length; i++) {
        dati.setUint8(posizione + i, testo.codeUnitAt(i));
      }
    }

    // WAV PCM mono, 16 bit.
    scriviTesto(0, 'RIFF');
    dati.setUint32(4, 36 + numeroCampioni * 2, Endian.little);
    scriviTesto(8, 'WAVE');
    scriviTesto(12, 'fmt ');
    dati.setUint32(16, 16, Endian.little);
    dati.setUint16(20, 1, Endian.little);
    dati.setUint16(22, 1, Endian.little);
    dati.setUint32(24, frequenzaCampionamento, Endian.little);
    dati.setUint32(
      28,
      frequenzaCampionamento * 2,
      Endian.little,
    );
    dati.setUint16(32, 2, Endian.little);
    dati.setUint16(34, 16, Endian.little);
    scriviTesto(36, 'data');
    dati.setUint32(40, numeroCampioni * 2, Endian.little);

    for (var i = 0; i < numeroCampioni; i++) {
      final t = i / frequenzaCampionamento;
      double campione;

      switch (suono) {
        case SuonoAllenamento.bip:
          campione = math.sin(2 * math.pi * 1000 * t);
          break;

        case SuonoAllenamento.click:
          final rumore = casuale.nextDouble() * 2 - 1;
          final tono = math.sin(2 * math.pi * 1800 * t);

          // Click più udibile, con decadimento meno rapido.
          campione =
              (0.7 * rumore + 0.3 * tono) * math.exp(-t * 55);
          break;

        case SuonoAllenamento.fischio:
          campione =
              math.sin(2 * math.pi * 2400 * t) *
              math.exp(-t * 5);
          break;

        case SuonoAllenamento.metallico:
          final fondamentale = math.sin(2 * math.pi * 900 * t);
          final armonica = math.sin(2 * math.pi * 2137 * t);
          final acuto = math.sin(2 * math.pi * 3671 * t);

          campione =
              (0.55 * fondamentale +
                  0.30 * armonica +
                  0.15 * acuto) *
              math.exp(-t * 22);
          break;

        case SuonoAllenamento.elettronico:
          const frequenzaIniziale = 650.0;
          final velocitaSalita = 1000.0 / durataSecondi;
          final fase = 2 *
              math.pi *
              (frequenzaIniziale * t +
                  0.5 * velocitaSalita * t * t);

          campione =
              (0.8 * math.sin(fase) +
                  0.2 * math.sin(2 * fase)) *
              math.exp(-t * 8);
          break;
      }

      final attacco = (t / 0.001).clamp(0.0, 1.0);
      final rilascio =
          ((durataSecondi - t) / 0.005).clamp(0.0, 1.0);

      final valore = (campione * attacco * rilascio * 0.8)
          .clamp(-1.0, 1.0);

      dati.setInt16(
        44 + i * 2,
        (valore * 32767).round(),
        Endian.little,
      );
    }

    return dati.buffer.asUint8List();
  }

  Future<void> interrompi() async {
    await _player.stop();
  }

  Future<void> chiudi() async {
    await _player.dispose();
  }
}