import 'dart:math';
import 'dart:typed_data';

class ToneGenerator {
  static Uint8List generaWav({
    required int frequenza,
    required int durataMs,
  }) {
    const sampleRate = 44100;
    const canali = 1;
    const bitPerCampione = 16;

    if (frequenza <= 0 || durataMs <= 0) {
      throw ArgumentError('Frequenza e durata devono essere positive.');
    }

    final numeroCampioni = (sampleRate * durataMs / 1000).round();
    final dimensioneDati = numeroCampioni * 2;

    final dati = ByteData(44 + dimensioneDati);

    void scriviStringa(int posizione, String valore) {
      for (var i = 0; i < valore.length; i++) {
        dati.setUint8(posizione + i, valore.codeUnitAt(i));
      }
    }

    // Intestazione del file WAV.
    scriviStringa(0, 'RIFF');
    dati.setUint32(4, 36 + dimensioneDati, Endian.little);
    scriviStringa(8, 'WAVE');

    scriviStringa(12, 'fmt ');
    dati.setUint32(16, 16, Endian.little);
    dati.setUint16(20, 1, Endian.little);
    dati.setUint16(22, canali, Endian.little);
    dati.setUint32(24, sampleRate, Endian.little);
    dati.setUint32(
      28,
      sampleRate * canali * bitPerCampione ~/ 8,
      Endian.little,
    );
    dati.setUint16(32, canali * bitPerCampione ~/ 8, Endian.little);
    dati.setUint16(34, bitPerCampione, Endian.little);

    scriviStringa(36, 'data');
    dati.setUint32(40, dimensioneDati, Endian.little);

    // Generazione dell'onda sinusoidale.
    for (var i = 0; i < numeroCampioni; i++) {
      final tempo = i / sampleRate;

      // Dissolvenza iniziale e finale per evitare clic.
      final fadeIn = min(1.0, i / 300);
      final fadeOut = min(1.0, (numeroCampioni - i) / 500);
      final ampiezza = 0.75 * min(fadeIn, fadeOut);

      final campione = (
        sin(2 * pi * frequenza * tempo) *
        ampiezza *
        32767
      ).round();

      dati.setInt16(44 + i * 2, campione, Endian.little);
    }

    return dati.buffer.asUint8List();
  }
}