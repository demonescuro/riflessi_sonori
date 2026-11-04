class ReflexTestSettings {
  int ripetizioni;
  double intervalloMinimo;
  double intervalloMassimo;

  ReflexTestSettings({
    this.ripetizioni = 10,
    this.intervalloMinimo = 2.0,
    this.intervalloMassimo = 6.0,
  });

  bool get intervalliValidi =>
      intervalloMinimo > 0 &&
      intervalloMassimo >= intervalloMinimo;

  bool get configurazioneValida =>
      ripetizioni > 0 && intervalliValidi;
}