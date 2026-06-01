import 'dart:io' show Platform;

import 'package:health/health.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'config_api.dart';
import 'reloj_service.dart';

enum HealthSyncResult {
  success,
  noPermissions,
  noData,
  healthConnectNotInstalled,
  timeout,
  platformError,
  networkError,
  unknown,
}

class HealthSyncError {
  final HealthSyncResult result;
  final String message;
  final String? details;

  const HealthSyncError({
    required this.result,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'HealthSyncError($result): $message${details != null ? " — $details" : ""}';
}

class HealthService {
  static final Health _health = Health();

  // IMPORTANT: Only request data types available on the running platform.
  // Requesting unsupported types (e.g. SLEEP_IN_BED on Android) can cause
  // permissions to be reported as not granted even when user already accepted.
  static final List<HealthDataType> _healthTypes = _buildSupportedHealthTypes();

  static final List<HealthDataType> _sleepTypes = _healthTypes
      .where((t) => t != HealthDataType.HEART_RATE)
      .toList(growable: false);

  static final List<HealthDataAccess> _readPermissions =
      List<HealthDataAccess>.filled(
    _healthTypes.length,
    HealthDataAccess.READ,
    growable: false,
  );

  static List<HealthDataType> _buildSupportedHealthTypes() {
    final requested = <HealthDataType>[];

    void addIfSupported(HealthDataType type) {
      if (_health.isDataTypeAvailable(type) && !requested.contains(type)) {
        requested.add(type);
      }
    }

    addIfSupported(HealthDataType.HEART_RATE);
    addIfSupported(HealthDataType.SLEEP_AWAKE);
    addIfSupported(HealthDataType.SLEEP_ASLEEP);
    addIfSupported(HealthDataType.SLEEP_IN_BED); // iOS only; skipped on Android.

    for (final maybeType in const [
      'SLEEP_LIGHT',
      'SLEEP_DEEP',
      'SLEEP_REM',
      'SLEEP_SESSION',
      'SLEEP_UNKNOWN',
      'SLEEP_AWAKE_IN_BED',
      'SLEEP_OUT_OF_BED',
    ]) {
      final detected = _tryGetHealthDataType(maybeType);
      if (detected != null) {
        addIfSupported(detected);
      }
    }

    return List<HealthDataType>.unmodifiable(requested);
  }

  static Future<bool> _hasRequiredPermissions() async {
    if (_healthTypes.isEmpty) return false;
    final has = await _health.hasPermissions(
      _healthTypes,
      permissions: _readPermissions,
    );
    return has == true;
  }

  static Future<bool> _requestRequiredPermissions() async {
    if (_healthTypes.isEmpty) return false;
    return _health.requestAuthorization(
      _healthTypes,
      permissions: _readPermissions,
    );
  }

  static Future<bool> _recheckPermissionsWithRetry({
    int maxChecks = 5,
    Duration delay = const Duration(milliseconds: 350),
  }) async {
    for (var i = 0; i < maxChecks; i++) {
      final ok = await _hasRequiredPermissions();
      if (ok) return true;
      if (i < maxChecks - 1) {
        await Future.delayed(delay);
      }
    }
    return false;
  }

  static String _typesToLog(List<HealthDataType> types) =>
      types.map((t) => t.name).join(', ');

  static HealthDataType? _tryGetHealthDataType(String name) {
    try {
      return HealthDataType.values.byName(name);
    } catch (_) {
      return null;
    }
  }

  static int? _extractHeartRateBpm(HealthDataPoint evento) {
    final rawValue = evento.value;
    final Object rawAny = rawValue;

    if (rawAny is num) {
      return rawAny.round();
    }

    final dynamic dynValue = rawValue;

    // health package frequently wraps numeric values in custom classes.
    try {
      final num? numeric = dynValue.numericValue as num?;
      if (numeric != null) return numeric.round();
    } catch (_) {}

    try {
      final maybeJson = dynValue.toJson();
      if (maybeJson is Map) {
        final candidate = maybeJson['numericValue'] ??
            maybeJson['numericalValue'] ??
            maybeJson['value'];
        if (candidate is num) return candidate.round();
        final parsed = double.tryParse(candidate?.toString() ?? '');
        if (parsed != null) return parsed.round();
      }
    } catch (_) {}

    // Last-resort parser for debug-like string representations.
    final text = rawValue.toString();
    final match = RegExp(r'(-?\d+(?:\.\d+)?)').firstMatch(text);
    if (match != null) {
      final parsed = double.tryParse(match.group(1)!);
      if (parsed != null) return parsed.round();
    }

    return null;
  }

  static DateTime _calcularInicioVentana(DateTime now) {
    final sleepStart = ConfigApi.sleepStartTime?.trim();
    if (sleepStart == null || sleepStart.isEmpty || !sleepStart.contains(':')) {
      return now.subtract(const Duration(hours: 48));
    }

    final parts = sleepStart.split(':');
    if (parts.length < 2) {
      return now.subtract(const Duration(hours: 24));
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return now.subtract(const Duration(hours: 24));
    }

    DateTime candidate = DateTime(now.year, now.month, now.day, hour, minute);
    if (candidate.isAfter(now)) {
      candidate = candidate.subtract(const Duration(days: 1));
    }

    return candidate.subtract(const Duration(hours: 2));
  }

  /// Checks if Health Connect SDK is available on this device.
  static Future<bool> isHealthConnectAvailable() async {
    try {
      final status = await _health.getHealthConnectSdkStatus();
      return status == HealthConnectSdkStatus.sdkAvailable;
    } catch (e) {
      debugPrint('[HealthService] isHealthConnectAvailable error: $e');
      return false;
    }
  }

  static Future<bool> solicitarPermisos() async {
    try {
      await _health.configure();
      debugPrint('[HealthService] solicitarPermisos -> tipos: ${_typesToLog(_healthTypes)}');
      final granted = await _requestRequiredPermissions();
      if (granted) return true;
      return await _recheckPermissionsWithRetry();
    } catch (e) {
      debugPrint('[HealthService] Error solicitando permisos: $e');
      return false;
    }
  }

  /// Opens the Health Connect permissions screen so the user can grant access.
  /// Returns true if permissions are granted after the user interacts.
  static Future<bool> abrirPantallaPermisosYVerificar() async {
    try {
      await _health.configure();
      debugPrint('[HealthService] abrirPantallaPermisosYVerificar -> tipos: ${_typesToLog(_healthTypes)}');
      final granted = await _requestRequiredPermissions();
      if (granted) return true;
      // Known plugin behavior: false can be returned even after user grants.
      return await _recheckPermissionsWithRetry();
    } catch (e) {
      debugPrint('[HealthService] abrirPantallaPermisosYVerificar error: $e');
      return false;
    }
  }

  /// Verifies Health Connect is available and permissions are granted.
  /// Returns null on success, or a [HealthSyncError] describing the problem.
  static Future<HealthSyncError?> verificarCapacidades() async {
    debugPrint('[HealthService] Verificando capacidades...');

    final hcAvailable = await isHealthConnectAvailable();
    if (!hcAvailable) {
      debugPrint('[HealthService] Health Connect no instalado');
      return const HealthSyncError(
        result: HealthSyncResult.healthConnectNotInstalled,
        message: 'Health Connect no está instalado en este dispositivo.',
      );
    }

    try {
      await _health.configure();
      debugPrint('[HealthService] Plataforma: ${Platform.operatingSystem}');
      debugPrint('[HealthService] Tipos de permiso requeridos: ${_typesToLog(_healthTypes)}');

      final hasPermissions = await _hasRequiredPermissions();
      if (!hasPermissions) {
        debugPrint('[HealthService] Permisos no concedidos — solicitando...');
        final granted = await _requestRequiredPermissions();
        if (!granted) {
          final recheck = await _recheckPermissionsWithRetry();
          if (!recheck) {
            return const HealthSyncError(
              result: HealthSyncResult.noPermissions,
              message: 'Permisos de salud no concedidos.',
            );
          }
        }
      }
    } on PlatformException catch (e) {
      debugPrint('[HealthService] PlatformException en verificarCapacidades: $e');
      return HealthSyncError(
        result: HealthSyncResult.platformError,
        message: 'Error de plataforma al verificar permisos.',
        details: e.message,
      );
    } catch (e) {
      debugPrint('[HealthService] Error en verificarCapacidades: $e');
      return HealthSyncError(
        result: HealthSyncResult.unknown,
        message: 'Error desconocido al verificar capacidades.',
        details: e.toString(),
      );
    }

    debugPrint('[HealthService] Capacidades verificadas correctamente');
    return null;
  }

  static Future<bool> sincronizarDesdeGoogleFit() async {
    final error = await sincronizarDesdeGoogleFitDetallado();
    return error == null;
  }

  static Future<HealthSyncError?> sincronizarDesdeGoogleFitDetallado() async {
    if (ConfigApi.usuarioActual == null) {
      debugPrint('[HealthService] sincronizar: usuarioActual es null');
      return const HealthSyncError(
        result: HealthSyncResult.unknown,
        message: 'No hay usuario autenticado para sincronizar.',
      );
    }

    debugPrint('[HealthService] Iniciando sincronización BPM...');

    const maxIntentos = 3;
    const delays = [Duration(seconds: 2), Duration(seconds: 2)];

    HealthSyncError? ultimoError;

    for (int intento = 1; intento <= maxIntentos; intento++) {
      try {
        final result = await _intentarSincronizacionDetallada().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            debugPrint('[HealthService] Timeout en intento $intento');
            return const HealthSyncError(
              result: HealthSyncResult.timeout,
              message: 'Tiempo de espera agotado durante la sincronización.',
            );
          },
        );

        if (result == null) {
          debugPrint('[HealthService] Sincronización exitosa en intento $intento');
          return null;
        }

        ultimoError = result;
        debugPrint('[HealthService] Intento $intento fallido: ${result.result} — ${result.message}');

        // Non-retryable functional errors.
        if (result.result == HealthSyncResult.noPermissions ||
            result.result == HealthSyncResult.noData ||
            result.result == HealthSyncResult.healthConnectNotInstalled) {
          return result;
        }
      } on PlatformException catch (e) {
        ultimoError = HealthSyncError(
          result: HealthSyncResult.platformError,
          message: 'Error de plataforma durante la sincronización.',
          details: e.message,
        );
        debugPrint('[HealthService] PlatformException intento $intento: ${e.code} — ${e.message}');
      } catch (e) {
        ultimoError = HealthSyncError(
          result: HealthSyncResult.unknown,
          message: 'Error inesperado durante la sincronización.',
          details: e.toString(),
        );
        debugPrint('[HealthService] Error inesperado intento $intento: $e');
      }

      if (intento < maxIntentos) {
        await Future.delayed(delays[intento - 1]);
      }
    }

    debugPrint('[HealthService] Sincronización fallida tras $maxIntentos intentos');
    return ultimoError ??
        const HealthSyncError(
          result: HealthSyncResult.unknown,
          message: 'No se pudo completar la sincronización.',
        );
  }

  // DIAGNOSTIC GETTERS & METHODS (for debug panel)

  /// Returns the list of health data types currently being requested.
  static List<HealthDataType> getRequestedHealthTypes() => _healthTypes;

  /// Returns the platform name (Android, iOS, etc).
  static String getPlatformName() => Platform.operatingSystem;

  /// Gets the current Health Connect SDK status.
  static Future<String> getHealthConnectSdkStatusText() async {
    try {
      final status = await _health.getHealthConnectSdkStatus();
      return status.toString();
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Checks if each requested type is available on this platform.
  static Map<String, bool> getTypeAvailabilityMap() {
    final map = <String, bool>{};
    for (final type in _healthTypes) {
      map[type.name] = _health.isDataTypeAvailable(type);
    }
    return map;
  }

  /// Checks permissions for each requested type (returns true if all granted).
  static Future<Map<String, bool>> getPermissionStatusMap() async {
    final map = <String, bool>{};
    try {
      for (int i = 0; i < _healthTypes.length; i++) {
        final type = _healthTypes[i];
        final access = _readPermissions[i];
        final hasPermission = await _health.hasPermissions([type], permissions: [access]) ?? false;
        map[type.name] = hasPermission;
      }
    } catch (e) {
      debugPrint('[HealthService] Error en getPermissionStatusMap: $e');
      map['_error'] = false;
    }
    return map;
  }

  static Future<HealthSyncError?> _intentarSincronizacionDetallada() async {
    // requestAuthorization devuelve true si ya están concedidos (sin mostrar diálogo).
    try {
      await _health.configure();
    } catch (e) {
      debugPrint('[HealthService] configure() error: $e');
    }
    final granted = await _requestRequiredPermissions();
    if (!granted) {
      // Known behavior: plugin can return false even after user accepted.
      final recheck = await _recheckPermissionsWithRetry();
      if (!recheck) {
        debugPrint('[HealthService] Permisos no disponibles en _intentarSincronizacion');
        return const HealthSyncError(
          result: HealthSyncResult.noPermissions,
          message: 'Permisos de salud no concedidos.',
        );
      }
    }

    final now = DateTime.now();
    final desde = _calcularInicioVentana(now);
    debugPrint('[HealthService] Ventana de sync: $desde → $now');

    final pulsaciones = await _health.getHealthDataFromTypes(
      types: [HealthDataType.HEART_RATE],
      startTime: desde,
      endTime: now,
    );
    final sleepData = await _health.getHealthDataFromTypes(
      types: _sleepTypes,
      startTime: desde,
      endTime: now,
    );

    debugPrint('[HealthService] Leídos ${pulsaciones.length} registros BPM, ${sleepData.length} registros sueño');

    final pulsacionesUnicas = _health.removeDuplicates(pulsaciones);
    final sleepUnique = _health.removeDuplicates(sleepData);

    // Validate BPM range 30-220 and deduplicate by (minuto, valor)
    final seen = <String>{};
    final datosPulsaciones = <Map<String, dynamic>>[];
    for (final evento in pulsacionesUnicas) {
      final valor = _extractHeartRateBpm(evento) ?? 0;
      if (valor < 30 || valor > 220) {
        debugPrint('[HealthService] BPM fuera de rango ($valor), descartado');
        continue;
      }
      final minuto = evento.dateFrom.difference(desde).inMinutes;
      final minutoClamp = minuto < 0 ? 0 : minuto;
      final key = '$minutoClamp:$valor';
      if (seen.contains(key)) continue;
      seen.add(key);
      datosPulsaciones.add({'minuto': minutoClamp, 'valor': valor});
    }
    debugPrint('[HealthService] ${datosPulsaciones.length} registros BPM válidos tras filtrado');

    final Map<String, double> acumuladoFases = {
      'awake': 0.0,
      'light': 0.0,
      'deep': 0.0,
      'rem': 0.0,
    };

    bool hayFasesDetalladas = false;
    bool hayDuracionSueno = false;
    double horasAsleepGenerico = 0.0;

    for (var evento in sleepUnique) {
      final duracion = evento.dateTo.difference(evento.dateFrom).inMinutes / 60.0;
      if (duracion <= 0) continue;
      hayDuracionSueno = true;

      final tipo = evento.type.name.toUpperCase();

      if (tipo.contains('AWAKE')) {
        acumuladoFases['awake'] = acumuladoFases['awake']! + duracion;
        continue;
      }

      if (tipo.contains('LIGHT')) {
        hayFasesDetalladas = true;
        acumuladoFases['light'] = acumuladoFases['light']! + duracion;
        continue;
      }

      if (tipo.contains('DEEP')) {
        hayFasesDetalladas = true;
        acumuladoFases['deep'] = acumuladoFases['deep']! + duracion;
        continue;
      }

      if (tipo.contains('REM')) {
        hayFasesDetalladas = true;
        acumuladoFases['rem'] = acumuladoFases['rem']! + duracion;
        continue;
      }

      if (tipo.contains('ASLEEP') || tipo.contains('IN_BED')) {
        horasAsleepGenerico += duracion;
      }
    }

    if (!hayFasesDetalladas && horasAsleepGenerico > 0) {
      acumuladoFases['light'] = acumuladoFases['light']! + horasAsleepGenerico;
    }

    if (datosPulsaciones.isEmpty && !hayDuracionSueno) {
      return const HealthSyncError(
        result: HealthSyncResult.noData,
        message: 'No se encontraron datos de pulso o sueño en Health Connect.',
      );
    }

    final fasesSueno = acumuladoFases.entries
        .map((entry) => {'fase': entry.key, 'horas': double.parse(entry.value.toStringAsFixed(2))})
        .toList();

    final enviado = await RelojService.enviarDatosRelojAlBackend(
      fecha: now,
      pulsaciones: datosPulsaciones,
      fasesSueno: fasesSueno,
    );

    if (!enviado) {
      return const HealthSyncError(
        result: HealthSyncResult.networkError,
        message: 'No se pudieron enviar los datos al servidor.',
      );
    }

    debugPrint('[HealthService] Datos enviados al backend correctamente');
    return null;
  }
}
