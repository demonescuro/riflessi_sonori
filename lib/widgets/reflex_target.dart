import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class ReflexTarget extends StatefulWidget {
  final bool segnaleAttivo;
  final bool abilitato;
  final VoidCallback onTap;

  const ReflexTarget({
    super.key,
    required this.segnaleAttivo,
    required this.abilitato,
    required this.onTap,
  });

  @override
  State<ReflexTarget> createState() => _ReflexTargetState();
}

class _ReflexTargetState extends State<ReflexTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animazione;

  Timer? _timerPressione;
  bool _premuto = false;

  @override
  void initState() {
    super.initState();

    _animazione = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    if (widget.segnaleAttivo) {
      _animazione.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ReflexTarget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.segnaleAttivo && !oldWidget.segnaleAttivo) {
      _animazione.repeat(reverse: true);
    }

    if (!widget.segnaleAttivo && oldWidget.segnaleAttivo) {
      _animazione
        ..stop()
        ..value = 0;
    }
  }

  void _registraTocco(TapDownDetails dettagli) {
    if (!widget.abilitato) return;

    _timerPressione?.cancel();

    setState(() {
      _premuto = true;
    });

    // Il tempo viene registrato al contatto del dito con lo schermo,
    // senza attendere che il dito venga sollevato.
    widget.onTap();

    _timerPressione = Timer(
      const Duration(milliseconds: 100),
      () {
        if (!mounted) return;

        setState(() {
          _premuto = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _timerPressione?.cancel();
    _animazione.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colori = Theme.of(context).colorScheme;

    final coloreBordo = widget.segnaleAttivo
        ? colori.secondary
        : colori.primary.withValues(alpha: 0.72);

    final coloreTesto = widget.segnaleAttivo
        ? colori.secondary
        : colori.primary;

    return AnimatedBuilder(
      animation: _animazione,
      builder: (context, child) {
        final pulsazione = widget.segnaleAttivo
            ? 1 + (_animazione.value * 0.045)
            : 1.0;

        final pressione = _premuto ? 0.94 : 1.0;

        return Transform.scale(
          scale: pulsazione * pressione,
          child: child,
        );
      },
      child: SizedBox(
        width: 240,
        height: 240,
        child: Semantics(
          button: true,
          label: 'Tap here',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _registraTocco,
            child: CustomPaint(
              painter: _CerchioTratteggiatoPainter(
                colore: coloreBordo,
                spessore: widget.segnaleAttivo ? 5 : 3,
                illuminato: widget.segnaleAttivo,
                intensitaLuce: _animazione.value,
              ),
              child: Center(
                child: Text(
                  'TAP\nHERE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: coloreTesto,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                    height: 1.05,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CerchioTratteggiatoPainter extends CustomPainter {
  final Color colore;
  final double spessore;
  final bool illuminato;
  final double intensitaLuce;

  const _CerchioTratteggiatoPainter({
    required this.colore,
    required this.spessore,
    required this.illuminato,
    required this.intensitaLuce,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final raggio = (size.shortestSide / 2) - 13;

    final rettangolo = Rect.fromCircle(
      center: centro,
      radius: raggio,
    );

    if (illuminato) {
      final alone = Paint()
        ..color = colore.withValues(
          alpha: 0.20 + (intensitaLuce * 0.20),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = spessore + 14
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          12,
        );

      canvas.drawCircle(
        centro,
        raggio,
        alone,
      );
    }

    final pennello = Paint()
      ..color = colore
      ..style = PaintingStyle.stroke
      ..strokeWidth = spessore
      ..strokeCap = StrokeCap.round;

    const numeroTratti = 34;
    const rapportoTratto = 0.56;

    final angoloCompleto = (2 * math.pi) / numeroTratti;
    final angoloTratto = angoloCompleto * rapportoTratto;

    for (var i = 0; i < numeroTratti; i++) {
      final inizio = (i * angoloCompleto) - (math.pi / 2);

      canvas.drawArc(
        rettangolo,
        inizio,
        angoloTratto,
        false,
        pennello,
      );
    }
  }

  @override
  bool shouldRepaint(_CerchioTratteggiatoPainter oldDelegate) {
    return oldDelegate.colore != colore ||
        oldDelegate.spessore != spessore ||
        oldDelegate.illuminato != illuminato ||
        oldDelegate.intensitaLuce != intensitaLuce;
  }
}