import 'dart:math' as math;

/// Helper para construir la ventana de análisis de sueño de 10 horas.
///
/// Los [minuto] de las pulsaciones se tratan como minutos relativos desde
/// el inicio de la ventana de recogida de datos (no desde la medianoche).
/// Para el eje X de la gráfica se convierten a horas reloj usando [horaInicio].
class SleepWindow {
  final int startMinutes; // Minutos desde medianoche (ej. 22:30 → 1350)
  final int endMinutes; // startMinutes + 600 (puede superar 1440)

  const SleepWindow({required this.startMinutes, required this.endMinutes});

  static const int windowDuration = 600; // 10 horas en minutos

  /// Devuelve true si [minuto] (relativo, 0-based desde la recogida)
  /// cae dentro de los primeros [windowDuration] minutos.
  bool containsRelativeMinuto(int minuto) {
    return minuto >= 0 && minuto <= windowDuration;
  }

  /// Convierte un [minuto] relativo (0-600) a la hora de reloj real.
  /// Ej: minuto=30 + startMinutes=1350 → 1380 → "23:00"
  String relativeMinutoToClockString(int minuto) {
    final totalMins = (startMinutes + minuto) % 1440;
    final h = totalMins ~/ 60;
    final m = totalMins % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  /// Hora de inicio como string "HH:mm"
  String get startClockString {
    final h = startMinutes ~/ 60;
    final m = startMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  /// Hora de fin como string "HH:mm"
  String get endClockString {
    final totalMins = endMinutes % 1440;
    final h = totalMins ~/ 60;
    final m = totalMins % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

class SleepWindowHelper {
  static const int _hourBlockMinutes = 60;

  /// Parsea "HH:mm" a minutos desde medianoche. Devuelve null si inválido.
  static int? parseHoraToMinutes(String? horaStr) {
    if (horaStr == null || horaStr.trim().isEmpty) return null;
    final parts = horaStr.trim().split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return h * 60 + m;
  }

  /// Construye una ventana de 10 horas a partir de [startMinutes].
  static SleepWindow buildWindow(int startMinutes) {
    return SleepWindow(
      startMinutes: startMinutes,
      endMinutes: startMinutes + SleepWindow.windowDuration,
    );
  }

  /// Filtra pulsaciones dejando sólo las que caben en la ventana de 10 horas.
  /// Los [minuto] se tratan como minutos relativos (0 = inicio de recogida).
  static List<Map<String, dynamic>> filterPulsaciones(
    List<dynamic> pulsaciones,
    SleepWindow window,
  ) {
    final filtradas = pulsaciones
        .where((p) {
          final minuto = int.tryParse(p['minuto'].toString()) ?? -1;
          return window.containsRelativeMinuto(minuto);
        })
        .map((p) => Map<String, dynamic>.from(p as Map))
        .toList();

    filtradas.sort((a, b) {
      final ma = int.tryParse(a['minuto'].toString()) ?? 0;
      final mb = int.tryParse(b['minuto'].toString()) ?? 0;
      return ma.compareTo(mb);
    });

    return filtradas;
  }

  /// Convierte pulsaciones crudas a bloques horarios reales.
  ///
  /// - Usa agregación robusta por mediana dentro de cada bloque.
  /// - Mantiene huecos sin dato para que UI/algoritmo los manejen explícitamente.
  /// - Añade interpolación lineal acotada para visualización/análisis temporal.
  static List<HourlyHeartRateBlock> buildHourlyBlocks(
    List<Map<String, dynamic>> pulsaciones, {
    SleepWindow? sleepWindow,
  }) {
    final ordenadas = List<Map<String, dynamic>>.from(pulsaciones)
      ..sort((a, b) {
        final ma = int.tryParse(a['minuto'].toString()) ?? 0;
        final mb = int.tryParse(b['minuto'].toString()) ?? 0;
        return ma.compareTo(mb);
      });

    if (ordenadas.isEmpty) {
      if (sleepWindow != null) {
        final bloques = <HourlyHeartRateBlock>[];
        for (int start = 0;
            start < SleepWindow.windowDuration;
            start += _hourBlockMinutes) {
          bloques.add(HourlyHeartRateBlock(
            blockStartMinute: start,
            blockDurationMinutes: _hourBlockMinutes,
            bpm: null,
            interpolatedBpm: null,
          ));
        }
        return bloques;
      }
      return const [];
    }

    int startMinute = 0;
    int endMinuteExclusive = SleepWindow.windowDuration;

    if (sleepWindow == null) {
      final minRaw = int.tryParse(ordenadas.first['minuto'].toString()) ?? 0;
      final maxRaw = int.tryParse(ordenadas.last['minuto'].toString()) ?? 0;
      startMinute = (minRaw ~/ _hourBlockMinutes) * _hourBlockMinutes;
      endMinuteExclusive =
          (((maxRaw ~/ _hourBlockMinutes) + 1) * _hourBlockMinutes)
              .clamp(startMinute + _hourBlockMinutes, startMinute + 24 * 60);
    }

    final Map<int, List<double>> valoresPorBloque = {};
    for (final item in ordenadas) {
      final minuto = int.tryParse(item['minuto'].toString());
      final valor = double.tryParse(item['valor'].toString());
      if (minuto == null || valor == null) continue;
      if (valor < 30 || valor > 220) continue;
      if (minuto < startMinute || minuto >= endMinuteExclusive) continue;

      final bucketStart =
          ((minuto - startMinute) ~/ _hourBlockMinutes) * _hourBlockMinutes +
              startMinute;
      valoresPorBloque.putIfAbsent(bucketStart, () => []).add(valor);
    }

    final bloques = <HourlyHeartRateBlock>[];
    for (int blockStart = startMinute;
        blockStart < endMinuteExclusive;
        blockStart += _hourBlockMinutes) {
      final valores = valoresPorBloque[blockStart] ?? const <double>[];
      final bpmMediana = valores.isEmpty ? null : _median(valores);
      bloques.add(HourlyHeartRateBlock(
        blockStartMinute: blockStart,
        blockDurationMinutes: _hourBlockMinutes,
        bpm: bpmMediana,
        interpolatedBpm: null,
      ));
    }

    final sinPicos = _smoothOutlierSpikes(bloques);
    return _withInterpolation(sinPicos);
  }

  static List<HourlyHeartRateBlock> _smoothOutlierSpikes(
    List<HourlyHeartRateBlock> blocks,
  ) {
    if (blocks.length < 3) return List<HourlyHeartRateBlock>.from(blocks);

    final copy = List<HourlyHeartRateBlock>.from(blocks);
    for (int i = 1; i < copy.length - 1; i++) {
      final prev = copy[i - 1].bpm;
      final cur = copy[i].bpm;
      final next = copy[i + 1].bpm;
      if (prev == null || cur == null || next == null) continue;

      final baseline = _median([prev, next]);
      final dev = (cur - baseline).abs();
      final neighDiff = (prev - next).abs();

      // Si los vecinos son estables y el punto central se dispara,
      // corregimos al valor robusto local.
      if (neighDiff <= 5 && dev >= 12) {
        copy[i] = copy[i].copyWith(bpm: baseline);
      }
    }

    return copy;
  }

  static List<HourlyHeartRateBlock> _withInterpolation(
    List<HourlyHeartRateBlock> blocks,
  ) {
    final copy = List<HourlyHeartRateBlock>.from(blocks);

    int i = 0;
    while (i < copy.length) {
      if (copy[i].bpm != null) {
        i++;
        continue;
      }

      int gapStart = i;
      while (i < copy.length && copy[i].bpm == null) {
        i++;
      }
      final gapEnd = i - 1;

      final leftIndex = gapStart - 1;
      final rightIndex = i;

      final hasLeft = leftIndex >= 0 && copy[leftIndex].bpm != null;
      final hasRight = rightIndex < copy.length && copy[rightIndex].bpm != null;

      if (!hasLeft || !hasRight) {
        // Sin ancla completa: mantenemos nulos (sin inventar extremos).
        continue;
      }

      final left = copy[leftIndex].bpm!;
      final right = copy[rightIndex].bpm!;
      final gapLen = gapEnd - gapStart + 1;

      // Interpolación lineal para huecos internos.
      for (int k = 1; k <= gapLen; k++) {
        final t = k / (gapLen + 1);
        final v = left + (right - left) * t;
        final idx = gapStart + k - 1;
        copy[idx] = copy[idx].copyWith(interpolatedBpm: v);
      }
    }

    return copy;
  }

  /// Calcula las fases del sueño a partir de las pulsaciones filtradas,
  /// usando un estimador temporal más robusto (baseline + tendencias +
  /// estabilidad + contexto de la noche).
  static Map<String, double> calculatePhasesFromPulsaciones(
    List<Map<String, dynamic>> pulsaciones,
  ) {
    final bloques = buildHourlyBlocks(pulsaciones);
    return calculatePhasesFromHourlyBlocks(bloques);
  }

  /// Calcula fases sobre bloques horarios (1 bloque = 1h por defecto).
  static Map<String, double> calculatePhasesFromHourlyBlocks(
    List<HourlyHeartRateBlock> blocks,
  ) {
    if (blocks.length < 2) {
      return {'awake': 0.0, 'light': 0.0, 'deep': 0.0, 'rem': 0.0};
    }

    final series = blocks
        .map((b) => b.displayBpm)
        .whereType<double>()
        .toList(growable: false);
    if (series.length < 2) {
      return {'awake': 0.0, 'light': 0.0, 'deep': 0.0, 'rem': 0.0};
    }

    final baseline = _percentile(series, 0.20);
    final medianHr = _median(series);
    final blockHours = blocks.first.blockDurationMinutes / 60.0;
    final total = math.max(1, blocks.length - 1);

    final etapas = <String>[];
    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final hr = block.displayBpm;
      if (hr == null) {
        etapas.add('light');
        continue;
      }

      final prev = i > 0 ? blocks[i - 1].displayBpm : hr;
      final next = i < blocks.length - 1 ? blocks[i + 1].displayBpm : hr;
      final slope = (hr - (prev ?? hr));
      final localVar =
          ((hr - (prev ?? hr)).abs() + (hr - (next ?? hr)).abs()) / 2.0;
      final progress = i / total;

      final veryHigh = hr >= (medianHr + 14);
      final highAndRising = hr >= (baseline + 16) || slope >= 8;

      final lowHr = hr <= (baseline + 2.0);
      final stable = localVar <= 4.0;
      final deepWindow = progress <= 0.65;

      final remHr = hr >= (baseline + 4.0) && hr <= (baseline + 12.0);
      final remWindow = progress >= 0.25;
      final remDynamic = localVar >= 2.5 || slope.abs() >= 3.0;

      // Los valores interpolados sirven para continuidad visual pero no deben
      // disparar fases intensas con la misma confianza.
      final isSynthetic = !block.hasRealData;

      final awakeByTransition =
          (slope >= 10 && hr >= baseline + 10) || localVar >= 8;
      final deepCandidate = lowHr && stable && deepWindow && !isSynthetic;
      final remCandidate = remHr && remWindow && remDynamic;

      if (veryHigh || highAndRising || awakeByTransition) {
        etapas.add('awake');
      } else if (deepCandidate) {
        etapas.add('deep');
      } else if (remCandidate) {
        etapas.add('rem');
      } else {
        etapas.add('light');
      }
    }

    var suavizadas = _temporalStageSmoothing(etapas);
    suavizadas = _rebalanceStagesWithArchitecture(
      blocks: blocks,
      stages: suavizadas,
      baseline: baseline,
      medianHr: medianHr,
    );

    double awake = 0, light = 0, deep = 0, rem = 0;
    for (final stage in suavizadas) {
      switch (stage) {
        case 'awake':
          awake += blockHours;
          break;
        case 'deep':
          deep += blockHours;
          break;
        case 'rem':
          rem += blockHours;
          break;
        default:
          light += blockHours;
          break;
      }
    }

    return {'awake': awake, 'light': light, 'deep': deep, 'rem': rem};
  }

  static List<String> _temporalStageSmoothing(List<String> stages) {
    if (stages.length < 3) return List<String>.from(stages);

    final out = List<String>.from(stages);

    // Elimina bloques aislados (A-B-A => A-A-A).
    for (int i = 1; i < out.length - 1; i++) {
      if (out[i - 1] == out[i + 1] && out[i] != out[i - 1]) {
        out[i] = out[i - 1];
      }
    }

    return out;
  }

  static List<String> _rebalanceStagesWithArchitecture({
    required List<HourlyHeartRateBlock> blocks,
    required List<String> stages,
    required double baseline,
    required double medianHr,
  }) {
    if (blocks.isEmpty || blocks.length != stages.length) {
      return List<String>.from(stages);
    }

    final out = List<String>.from(stages);
    final n = out.length;

    // 1) REM temprano no fisiológico: primeros 90 min -> ligero.
    for (int i = 0; i < n; i++) {
      final minute = blocks[i].blockStartMinute;
      if (minute < 90 && out[i] == 'rem') {
        out[i] = 'light';
      }
    }

    // 2) Deep tardío improbable: último 20% -> ligero salvo FC muy baja estable.
    final lateStart = (n * 0.8).floor();
    for (int i = lateStart; i < n; i++) {
      if (out[i] != 'deep') continue;
      final hr = blocks[i].displayBpm;
      final prev = i > 0 ? blocks[i - 1].displayBpm : hr;
      final next = i < n - 1 ? blocks[i + 1].displayBpm : hr;
      final localVar = hr == null
          ? 99.0
          : ((hr - (prev ?? hr)).abs() + (hr - (next ?? hr)).abs()) / 2.0;
      final veryLowStable =
          hr != null && hr <= baseline + 0.5 && localVar <= 2.5;
      if (!veryLowStable) {
        out[i] = 'light';
      }
    }

    // 3) Si no hay deep, forzar detección mínima en primer 60% con criterios fuertes.
    final hasDeep = out.any((s) => s == 'deep');
    if (!hasDeep) {
      final candidates = <int>[];
      final endEarly = math.max(1, (n * 0.6).ceil());
      for (int i = 0; i < endEarly; i++) {
        final b = blocks[i];
        final hr = b.displayBpm;
        if (hr == null || !b.hasRealData) continue;
        final prev = i > 0 ? blocks[i - 1].displayBpm : hr;
        final next = i < n - 1 ? blocks[i + 1].displayBpm : hr;
        final varLocal =
            ((hr - (prev ?? hr)).abs() + (hr - (next ?? hr)).abs()) / 2.0;
        if (hr <= baseline + 2.0 && varLocal <= 3.5) {
          candidates.add(i);
        }
      }

      if (candidates.isNotEmpty) {
        candidates.sort((a, b) {
          final hra = blocks[a].displayBpm ?? 999;
          final hrb = blocks[b].displayBpm ?? 999;
          return hra.compareTo(hrb);
        });

        final promoteCount = candidates.length >= 3 ? 2 : 1;
        for (int k = 0; k < promoteCount; k++) {
          final idx = candidates[k];
          out[idx] = 'deep';
        }
      }
    }

    // 4) Evitar exceso de awake por ruido: si hay >35% awake, degradar awake suaves.
    int awakeCount = out.where((s) => s == 'awake').length;
    final maxAwakeBlocks = (n * 0.35).ceil();
    if (awakeCount > maxAwakeBlocks) {
      final awakeCandidates = <int>[];
      for (int i = 0; i < n; i++) {
        if (out[i] != 'awake') continue;
        final hr = blocks[i].displayBpm;
        if (hr == null) continue;
        if (hr < medianHr + 12) {
          awakeCandidates.add(i);
        }
      }
      for (final idx in awakeCandidates) {
        if (awakeCount <= maxAwakeBlocks) break;
        out[idx] = 'light';
        awakeCount--;
      }
    }

    return _temporalStageSmoothing(out);
  }

  static double _median(List<double> values) {
    if (values.isEmpty) return 0.0;
    final sorted = List<double>.from(values)..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid];
    return (sorted[mid - 1] + sorted[mid]) / 2.0;
  }

  static double _percentile(List<double> values, double p) {
    if (values.isEmpty) return 0.0;
    if (p <= 0) return values.reduce(math.min);
    if (p >= 1) return values.reduce(math.max);

    final sorted = List<double>.from(values)..sort();
    final idx = (sorted.length - 1) * p;
    final lo = idx.floor();
    final hi = idx.ceil();
    if (lo == hi) return sorted[lo];
    final t = idx - lo;
    return sorted[lo] + (sorted[hi] - sorted[lo]) * t;
  }
}

class HourlyHeartRateBlock {
  final int blockStartMinute;
  final int blockDurationMinutes;
  final double? bpm;
  final double? interpolatedBpm;

  const HourlyHeartRateBlock({
    required this.blockStartMinute,
    required this.blockDurationMinutes,
    required this.bpm,
    required this.interpolatedBpm,
  });

  int get blockEndMinuteExclusive => blockStartMinute + blockDurationMinutes;

  bool get hasRealData => bpm != null;

  double? get displayBpm => bpm ?? interpolatedBpm;

  HourlyHeartRateBlock copyWith({
    int? blockStartMinute,
    int? blockDurationMinutes,
    double? bpm,
    bool clearBpm = false,
    double? interpolatedBpm,
    bool clearInterpolatedBpm = false,
  }) {
    return HourlyHeartRateBlock(
      blockStartMinute: blockStartMinute ?? this.blockStartMinute,
      blockDurationMinutes: blockDurationMinutes ?? this.blockDurationMinutes,
      bpm: clearBpm ? null : (bpm ?? this.bpm),
      interpolatedBpm: clearInterpolatedBpm
          ? null
          : (interpolatedBpm ?? this.interpolatedBpm),
    );
  }
}
