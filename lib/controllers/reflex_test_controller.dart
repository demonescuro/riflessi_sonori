import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/reflex_test_settings.dart';
import '../models/training_settings.dart';
import '../services/audio_service.dart';

enum StatoTestRiflessi {
  pronto,
  attesa,
  segnale,
  risultato,
  completato,
}

class ReflexTestController extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  final Random _casuale = Random();
  final Stopwatch _cronometro = Stopwatch();

  Timer? _timer;

  ReflexTestSettings? _impostazioniTest;
  TrainingSettings? _impostazioniSuono;

  StatoTestRiflessi stato = StatoTestRiflessi.pronto;

  int ripetizioneCorrente = 0;
  int tocchiAnticipati = 0;
  int? ultimoTempoMs;
  bool ultimoToccoAnticipato = false;

  final List<int> _tempiRisposta = [];

  bool get attivo =>
      stato == StatoTestRiflessi.attesa ||
      stato == StatoTestRiflessi.segnale ||
      stato == StatoTestRiflessi.risultato;

  bool get segnaleAttivo => stato == StatoTestRiflessi.segnale;

  List<int> get tempiRisposta => List.unmodifiable(_tempiRisposta);

  int? get migliorTempoMs {
    if (_tempiRisposta.isEmpty) return null;
    return _tempiRisposta.reduce(min);
  }

  int? get mediaTempoMs {
    if (_tempiRisposta.isEmpty) return null;

    final totale = _tempiRisposta.reduce((a, b) => a + b);
    return (totale / _tempiRisposta.length).round();
  }

  void avvia(
    ReflexTestSettings impostazioniTest,
    TrainingSettings impostazioniSuono,
  ) {
    if (!impostazioniTest.configurazioneValida) return;

    _timer?.cancel();

    _impostazioniTest = impostazioniTest;
    _impostazioniSuono = impostazioniSuono;

    ripetizioneCorrente = 0;
    tocchiAnticipati = 0;
    ultimoTempoMs = null;
    ultimoToccoAnticipato = false;
    _tempiRisposta.clear();

    _programmaProssimoSegnale();
  }

  void registraTocco() {
    if (stato == StatoTestRiflessi.attesa) {
      ultimoToccoAnticipato = true;
      tocchiAnticipati++;
      stato = StatoTestRiflessi.risultato;
      notifyListeners();

      _timer = Timer(
        const Duration(milliseconds: 900),
        _programmaProssimoSegnale,
      );
      return;
    }

    if (stato != StatoTestRiflessi.segnale) return;

    _cronometro.stop();

    ultimoToccoAnticipato = false;
    ultimoTempoMs = _cronometro.elapsedMilliseconds;
    _tempiRisposta.add(ultimoTempoMs!);

    stato = StatoTestRiflessi.risultato;
    notifyListeners();

    if (ripetizioneCorrente >= _impostazioniTest!.ripetizioni) {
      stato = StatoTestRiflessi.completato;
      notifyListeners();
      return;
    }

    _timer = Timer(
      const Duration(milliseconds: 900),
      _programmaProssimoSegnale,
    );
  }

  void interrompi() {
    _timer?.cancel();
    _cronometro.stop();

    stato = StatoTestRiflessi.pronto;
    notifyListeners();

    unawaited(_audioService.interrompi());
  }

  void _programmaProssimoSegnale() {
    final impostazioni = _impostazioniTest;

    if (impostazioni == null) return;

    stato = StatoTestRiflessi.attesa;
    notifyListeners();

    final intervallo =
        impostazioni.intervalloMinimo +
        _casuale.nextDouble() *
            (impostazioni.intervalloMassimo -
                impostazioni.intervalloMinimo);

    _timer = Timer(
      Duration(milliseconds: (intervallo * 1000).round()),
      _emettiSegnale,
    );
  }

  void _emettiSegnale() {
    ripetizioneCorrente++;
    stato = StatoTestRiflessi.segnale;
    ultimoToccoAnticipato = false;

    _cronometro
      ..reset()
      ..start();

    notifyListeners();

    final impostazioniSuono = _impostazioniSuono;
    if (impostazioniSuono != null) {
      unawaited(
        _audioService.riproduciStimolo(impostazioniSuono),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cronometro.stop();
    unawaited(_audioService.chiudi());
    super.dispose();
  }
}