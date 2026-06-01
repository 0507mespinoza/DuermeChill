import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'config_api.dart';
import 'reloj_service.dart';
import 'session_service.dart';

class DatosService {
  static Future<Map<String, dynamic>?> obtenerPerfilEditable() async {
    if (ConfigApi.usuarioActual == null) return null;

    await sincronizarDatosDesdeServidor();

    final cache = ConfigApi.datosUsuarioCache;
    if (cache == null) return null;

    final perfil = cache['perfil'] as Map<String, dynamic>?;
    final encuesta = cache['encuesta'] as Map<String, dynamic>?;

    return {
      'nombre': perfil?['nombre']?.toString() ?? ConfigApi.usuarioActual ?? '',
      'correo': perfil?['correo']?.toString() ?? '',
      'edad': perfil?['edad']?.toString() ?? '',
      'expectativa': encuesta?['expectativa']?.toString() ?? '',
      'noche': encuesta?['noche']?.toString() ?? '',
      'hora': (encuesta?['hora']?.toString() ?? ConfigApi.sleepStartTime ?? ''),
      'edadEncuesta': encuesta?['edad_encuesta']?.toString() ?? '',
    };
  }

  static Future<bool> guardarEdicionUsuarioYEncuesta({
    required String nombreActual,
    required String nuevoNombre,
    required String correo,
    required String edad,
    required String expectativa,
    required String noche,
    required String hora,
    required String edadEncuesta,
  }) async {
    if (ConfigApi.usuarioActual == null) return false;

    final nombreParaActualizar = nombreActual.trim().isEmpty ? ConfigApi.usuarioActual! : nombreActual;
    final edadInt = int.tryParse(edad.trim());

    try {
      final respuestaUsuario = await http.put(
        Uri.parse('${ConfigApi.urlServidor}/usuario/${Uri.encodeComponent(nombreParaActualizar)}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nuevoNombre.trim(),
          'correo': correo.trim(),
          'edad': edadInt,
        }),
      );

      if (respuestaUsuario.statusCode != 200) {
        debugPrint('Error actualizando usuario: status=${respuestaUsuario.statusCode}, body=${respuestaUsuario.body}');
        return false;
      }

      ConfigApi.usuarioActual = nuevoNombre.trim();

      final okEncuesta = await guardarDatosEncuesta({
        'expectativa': expectativa.trim(),
        'noche': noche.trim(),
        'hora': hora.trim(),
        'edad': edadEncuesta.trim().isEmpty ? edad.trim() : edadEncuesta.trim(),
      });

      if (!okEncuesta) return false;

      await sincronizarDatosDesdeServidor();
      return true;
    } catch (e) {
      debugPrint('Error guardando edición de usuario/encuesta: $e');
      return false;
    }
  }

  static Future<void> sincronizarDatosDesdeServidor() async {
    if (ConfigApi.usuarioActual == null) return;
    try {
      final respuesta = await http.get(Uri.parse('${ConfigApi.urlServidor}/usuario/${ConfigApi.usuarioActual}'));
      if (respuesta.statusCode == 200) {
        ConfigApi.datosUsuarioCache = jsonDecode(respuesta.body);

        final encuesta = ConfigApi.datosUsuarioCache?['encuesta'] as Map<String, dynamic>?;
        final sleepStartFromEncuesta = encuesta?['sleep_start_time']?.toString() ?? encuesta?['hora']?.toString();
        final sleepStartFromRoot = ConfigApi.datosUsuarioCache?['sleep_start_time']?.toString();
        ConfigApi.sleepStartTime = (sleepStartFromRoot != null && sleepStartFromRoot.trim().isNotEmpty)
            ? sleepStartFromRoot
            : sleepStartFromEncuesta;

        final onboardingRoot = ConfigApi.datosUsuarioCache?['onboarding_completed'];
        if (onboardingRoot == true || onboardingRoot == 1) {
          ConfigApi.encuestaCompletada = true;
        } else if (ConfigApi.sleepStartTime != null && ConfigApi.sleepStartTime!.trim().isNotEmpty) {
          ConfigApi.encuestaCompletada = true;
        }

        await SessionService.guardarSesion(
          usuario: ConfigApi.usuarioActual!,
          onboardingCompleted: ConfigApi.onboardingCompletado,
          sleepStartTime: ConfigApi.sleepStartTime,
        );
      }
    } catch (e) {
      debugPrint("Error sincronizando: $e");
    }
  }

  static Future<bool> guardarDatosEncuesta(Map<String, String> datos) async {
    if (ConfigApi.usuarioActual == null) return false;
    try {
      datos['nombre'] = ConfigApi.usuarioActual!;
      datos['sleep_start_time'] = datos['hora'] ?? '';

      final respuesta = await http.post(
        Uri.parse('${ConfigApi.urlServidor}/encuesta'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos),
      );

      if (respuesta.statusCode == 200) {
        ConfigApi.encuestaCompletada = true;
        ConfigApi.sleepStartTime = datos['sleep_start_time'];
        await sincronizarDatosDesdeServidor();
        return true;
      }
      debugPrint('Error guardando encuesta: status=${respuesta.statusCode}, body=${respuesta.body}');
      return false;
    } catch (e) {
      debugPrint("Error guardando encuesta: $e");
      return false;
    }
  }

  static Future<void> guardarDatosRegistro(Map<String, String> datos) async {
    if (ConfigApi.usuarioActual == null) return;
    try {
      datos['nombre'] = ConfigApi.usuarioActual!;
      await http.post(
        Uri.parse('${ConfigApi.urlServidor}/registro_diario'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos),
      );
      // Sincronizar tanto datos diarios como del reloj
      await sincronizarDatosDesdeServidor();
      await RelojService.obtenerDatosRelojServidor();
    } catch (e) {
      debugPrint("Error guardando registro: $e");
    }
  }

  static Future<void> guardarAlarmas(List<Map<String, dynamic>> listaAlarmas) async {
    if (ConfigApi.usuarioActual == null) return;
    try {
      List<Map<String, dynamic>> alarmasFormateadas = listaAlarmas.map((a) {
        return {
          'hora': "${a['hora'].hour.toString().padLeft(2, '0')}:${a['hora'].minute.toString().padLeft(2, '0')}",
          'activada': a['activada']
        };
      }).toList();

      await http.post(
        Uri.parse('${ConfigApi.urlServidor}/alarmas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nombre': ConfigApi.usuarioActual, 'alarmas': alarmasFormateadas}),
      );
      await sincronizarDatosDesdeServidor();
    } catch (e) {
      debugPrint("Error guardando alarmas: $e");
    }
  }

  static Future<void> registrarHoraDespertar(DateTime hora) async {
    if (ConfigApi.usuarioActual == null) return;
    
    try {
      // Formateamos la fecha y la hora para enviarla limpia
      final String fechaActual = "${hora.year}-${hora.month.toString().padLeft(2, '0')}-${hora.day.toString().padLeft(2, '0')}";
      final String horaFormateada = "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}";

      final respuesta = await http.post(
        Uri.parse('${ConfigApi.urlServidor}/registro_despertar'), // <- Ojo: Verifica que este endpoint exista en tu backend
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': ConfigApi.usuarioActual,
          'fecha': fechaActual,
          'hora_despertar': horaFormateada,
        }),
      );

      if (respuesta.statusCode == 200) {
        debugPrint("ÉXITO: Hora de despertar ($horaFormateada) guardada en servidor");
        await sincronizarDatosDesdeServidor();
      } else {
        debugPrint("Error del servidor al registrar despertar: status=${respuesta.statusCode}, body=${respuesta.body}");
      }
    } catch (e) {
      debugPrint("Error de conexión guardando hora de despertar: $e");
    }
  }
}