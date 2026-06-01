import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'config_api.dart';
import 'connectivity_service.dart';

class RelojService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static const List<Duration> _retryDelays = [
    Duration(milliseconds: 500),
    Duration(milliseconds: 1500),
    Duration(milliseconds: 3000),
  ];

  static Future<bool> enviarDatosRelojAlBackend({
    required DateTime fecha,
    required List<Map<String, dynamic>> pulsaciones,
    required List<Map<String, dynamic>> fasesSueno,
  }) async {
    if (ConfigApi.usuarioActual == null) {
      debugPrint('[RelojService] usuarioActual es null, abortando envío');
      return false;
    }

    final hayConexion = await ConnectivityService.tieneConexion();
    if (!hayConexion) {
      debugPrint('[RelojService] Sin conexión de red, abortando envío');
      return false;
    }

    const maxIntentos = 3;
    for (int intento = 1; intento <= maxIntentos; intento++) {
      try {
        debugPrint('[RelojService] Enviando datos al backend (intento $intento)...');
        final response = await _dio.post(
          '${ConfigApi.urlServidor}/reloj/ingestar',
          data: {
            'nombre': ConfigApi.usuarioActual,
            'fecha': fecha.toIso8601String().split('T').first,
            'pulsaciones': pulsaciones,
            'fases_sueno': fasesSueno,
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('[RelojService] Datos enviados correctamente (status ${response.statusCode})');
          return true;
        } else {
          debugPrint('[RelojService] Respuesta inesperada: ${response.statusCode}');
        }
      } on DioException catch (e) {
        _logDioError('[RelojService] DioException intento $intento', e);
      } catch (e) {
        debugPrint('[RelojService] Error inesperado intento $intento: $e');
      }

      if (intento < maxIntentos) {
        await Future.delayed(_retryDelays[intento - 1]);
      }
    }

    debugPrint('[RelojService] Envío fallido tras $maxIntentos intentos');
    return false;
  }

  static Future<void> obtenerDatosRelojServidor() async {
    if (ConfigApi.usuarioActual == null) return;

    try {
      final response = await _dio.get(
        '${ConfigApi.urlServidor}/reloj/${ConfigApi.usuarioActual}',
      );
      if (response.statusCode == 200 && response.data != null) {
        ConfigApi.datosRelojCache = response.data;
        debugPrint('[RelojService] Datos del servidor obtenidos correctamente');
      } else {
        debugPrint('[RelojService] obtenerDatosReloj: status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logDioError('[RelojService] Error obteniendo datos del servidor', e);
    } catch (e) {
      debugPrint('[RelojService] Error inesperado obteniendo datos: $e');
    }
  }

  static void _logDioError(String prefix, DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        debugPrint('$prefix: Timeout de conexión');
        break;
      case DioExceptionType.receiveTimeout:
        debugPrint('$prefix: Timeout de recepción');
        break;
      case DioExceptionType.sendTimeout:
        debugPrint('$prefix: Timeout de envío');
        break;
      case DioExceptionType.connectionError:
        debugPrint('$prefix: Error de conexión — ${e.message}');
        break;
      case DioExceptionType.badResponse:
        debugPrint('$prefix: Respuesta de error ${e.response?.statusCode} — ${e.response?.data}');
        break;
      default:
        debugPrint('$prefix: ${e.type} — ${e.message}');
    }
  }
}

