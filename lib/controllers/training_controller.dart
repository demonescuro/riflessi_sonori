
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/training_settings.dart';
import '../services/audio_service.dart';

class TrainingController extends ChangeNotifier {
  final AudioService _audio = AudioService();
  final Random _random = Random();

  Timer? _timer;
  Completer<void>? _attesa;

  int _sessioneOperativa = 0;
  bool _chiuso = false;
  bool _attivo = false;
  bool _inPausa = false;

  int _sessioneCorrente = 0;
  int _stimoliSessione = 0;
  int _stimoliEmessi = 0;

  String? _errore;

  bool get attivo => _attivo;
  bool get inPausa => _inPausa;

  int get sessioneCorrente => _sessioneCorrente;
  int get stimoliSessione => _stimoliSessione;
  int get stimoliEmessi => _stimoliEmessi;

  String? get errore => _errore;

  void _aggiorna() {
    if (!_chiuso) notifyListeners();
  }

  Future<void> _aspetta(Duration durata) {
    final attesa = Completer<void>();
    _attesa = attesa;

    _timer = Timer(durata, () {
      if (!attesa.isCompleted) {
        attesa.complete();
      }
    });

    return attesa.future;
  }

  void _annullaAttesa() {
    _timer?.cancel();
    _timer = null;

    final attesa = _attesa;
    _attesa = null;

    if (attesa != null && !attesa.isCompleted) {
      attesa.complete();
    }
  }

  Future<void> avvia(TrainingSettings impostazioni) async {
    if (_attivo || _chiuso) return;

    if (!impostazioni.configurazioneValida) {
      _errore = 'Impostazioni non valide.';
      _aggiorna();
      return;
    }

    final operazione = ++_sessioneOperativa;

    _attivo = true;
    _inPausa = false;
    _sessioneCorrente = 0;
    _stimoliSessione = 0;
    _stimoliEmessi = 0;
    _errore = null;

    _aggiorna();

    try {
      for (var sessione = 1;
          sessione <= impostazioni.numeroSessioni;
          sessione++) {
        if (!_attivo || operazione != _sessioneOperativa) return;

        _sessioneCorrente = sessione;
        _stimoliSessione = 0;
        _inPausa = false;
        _aggiorna();

        for (var i = 0; i < impostazioni.ripetizioni; i++) {
          if (!_attivo || operazione != _sessioneOperativa) return;

          final secondi = impostazioni.intervalloMinimo +
              _random.nextDouble() *
                  (impostazioni.intervalloMassimo -
                      impostazioni.intervalloMinimo);

          await _aspetta(
            Duration(microseconds: (secondi * 1000000).round()),
          );

          _attesa = null;
          _timer = null;

          if (!_attivo || operazione != _sessioneOperativa) return;

          await _audio.riproduciStimolo(impostazioni);

          if (!_attivo || operazione != _sessioneOperativa) return;

          _stimoliSessione++;
          _stimoliEmessi++;

          _aggiorna();
        }

        // Pausa soltanto se esiste una sessione successiva.
        if (sessione < impostazioni.numeroSessioni) {
          _inPausa = true;
          _aggiorna();

          await _aspetta(
            Duration(
              milliseconds: (impostazioni.pausaSessioni * 1000).round(),
            ),
          );

          _attesa = null;
          _timer = null;

          if (!_attivo || operazione != _sessioneOperativa) return;
        }
      }
    } catch (e) {
      if (operazione == _sessioneOperativa) {
        _errore = 'Errore durante l\'allenamento: $e';
      }
    } finally {
      if (operazione == _sessioneOperativa) {
        _attivo = false;
        _inPausa = false;
        _annullaAttesa();
        _aggiorna();
      }
    }
  }

  Future<void> interrompi() async {
    if (!_attivo || _chiuso) return;

    _sessioneOperativa++;
    _attivo = false;
    _inPausa = false;

    _annullaAttesa();
    _aggiorna();

    await _audio.interrompi();
  }

  Future<void> provaSuono(TrainingSettings impostazioni) async {
    if (_attivo || _chiuso) return;

    try {
      _errore = null;
      await _audio.riproduciStimolo(impostazioni);
    } catch (e) {
      _errore = 'Impossibile riprodurre il suono: $e';
      _aggiorna();
    }
  }

  @override
  void dispose() {
    _chiuso = true;
    _sessioneOperativa++;
    _attivo = false;
    _inPausa = false;

    _annullaAttesa();

    unawaited(_audio.chiudi());

    super.dispose();
  }
}
