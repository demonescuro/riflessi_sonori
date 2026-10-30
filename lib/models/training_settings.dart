enum SuonoAllenamento {
  bip,
  click,
  fischio,
  metallico,
  elettronico,
}

class TrainingSettings {
  double intervalloMinimo;
  double intervalloMassimo;

  int ripetizioni;
  int numeroSessioni;
  double pausaSessioni;

  double volume;
  int frequenza;
  int durataSuonoMs;

  SuonoAllenamento suonoSelezionato;
  String? percorsoAudio;

  TrainingSettings({
    this.intervalloMinimo = 2.0,
    this.intervalloMassimo = 6.0,
    this.ripetizioni = 20,
    this.numeroSessioni = 1,
    this.pausaSessioni = 30.0,
    this.volume = 0.8,
    this.frequenza = 880,
    this.durataSuonoMs = 180,
    this.suonoSelezionato = SuonoAllenamento.bip,
    this.percorsoAudio,
  });

  bool get usaAudioImportato => percorsoAudio != null;

  int get totaleStimoli => ripetizioni * numeroSessioni;

  bool get intervalliValidi =>
      intervalloMinimo > 0 &&
      intervalloMassimo >= intervalloMinimo;

  bool get configurazioneValida =>
      intervalliValidi &&
      ripetizioni > 0 &&
      numeroSessioni > 0 &&
      pausaSessioni >= 0 &&
      volume >= 0 &&
      volume <= 1 &&
      frequenza > 0 &&
      durataSuonoMs > 0;
}