import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:proyecto_intermodular/services/datos_service.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart'; 
import 'config_api.dart';
import 'session_service.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '298655901757-65krjh1buj6gf8d7kl5locoqvhj2sgfh.apps.googleusercontent.com',
  );

  static Future<bool> registrarUsuario(String nombre, String edad, String correo, String contrasena) async {
    try {
      final respuesta = await http.post(
        Uri.parse('${ConfigApi.urlServidor}/registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nombre': nombre, 'edad': int.tryParse(edad.trim()) ?? 0, 'correo': correo, 'contrasena': contrasena}),
      );
      return respuesta.statusCode == 200;
    } catch (e) {
      debugPrint("Error en registro: $e");
      return false;
    }
  }

  static Future<bool> iniciarSesion(String nombre, String contrasena) async {
    try {
      final respuesta = await http.post(
        Uri.parse('${ConfigApi.urlServidor}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nombre': nombre, 'contrasena': contrasena}),
      );

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        ConfigApi.usuarioActual = datos['usuario']['nombre'];

        final valorAdmin = datos['usuario']['is_admin'];
        ConfigApi.esAdmin = (valorAdmin == true || valorAdmin == 1);

        final valorOnboarding = datos['usuario']['onboarding_completed'] ?? datos['usuario']['encuesta_completada'];
        ConfigApi.encuestaCompletada = (valorOnboarding == 1 || valorOnboarding == true);
        ConfigApi.sleepStartTime = datos['usuario']['sleep_start_time']?.toString();

        await SessionService.guardarSesion(
          usuario: ConfigApi.usuarioActual!,
          onboardingCompleted: ConfigApi.onboardingCompletado,
          sleepStartTime: ConfigApi.sleepStartTime,
        );

        await DatosService.sincronizarDatosDesdeServidor();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error en login: $e");
      return false;
    }
  }

  static Future<bool> iniciarSesionConGoogle() async {
    try {
      // 1. Abre la ventana de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false; // El usuario canceló

      // 2. Obtiene las credenciales
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // 3. Envía el token al Backend para verificarlo y registrar al usuario
      final respuesta = await http.post(
        Uri.parse('${ConfigApi.urlServidor}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': googleAuth.idToken,
          'email': googleUser.email,
          'nombre': googleUser.displayName ?? 'Usuario Google',
        }),
      );

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        ConfigApi.usuarioActual = datos['usuario']['nombre'];
        
        var valorEncuesta = datos['usuario']['onboarding_completed'] ?? datos['usuario']['encuesta_completada'];
        ConfigApi.encuestaCompletada = (valorEncuesta == 1 || valorEncuesta == true);
        ConfigApi.sleepStartTime = datos['usuario']['sleep_start_time']?.toString();

        await SessionService.guardarSesion(
          usuario: ConfigApi.usuarioActual!,
          onboardingCompleted: ConfigApi.onboardingCompletado,
          sleepStartTime: ConfigApi.sleepStartTime,
        );
        
        await DatosService.sincronizarDatosDesdeServidor();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error en Google Sign-In: $e');
      return false;
    }
  }

  static Future<bool> restaurarSesionLocal() async {
    final sesion = await SessionService.leerSesion();
    if (sesion == null) return false;

    ConfigApi.usuarioActual = sesion['usuario']?.toString();
    if (ConfigApi.usuarioActual == null || ConfigApi.usuarioActual!.trim().isEmpty) {
      return false;
    }

    ConfigApi.encuestaCompletada = sesion['onboarding_completed'] == true;
    ConfigApi.sleepStartTime = sesion['sleep_start_time']?.toString();

    // Refresco defensivo desde backend para evitar estados locales obsoletos.
    await DatosService.sincronizarDatosDesdeServidor();

    await SessionService.guardarSesion(
      usuario: ConfigApi.usuarioActual!,
      onboardingCompleted: ConfigApi.onboardingCompletado,
      sleepStartTime: ConfigApi.sleepStartTime,
    );
    return true;
  }

  static Future<void> establecerSesionTrasRegistro(String usuario) async {
    ConfigApi.usuarioActual = usuario;
    ConfigApi.encuestaCompletada = false;
    ConfigApi.sleepStartTime = null;
    await SessionService.guardarSesion(
      usuario: usuario,
      onboardingCompleted: false,
      sleepStartTime: null,
    );
  }

  static Future<void> cerrarSesion() async {
    ConfigApi.usuarioActual = null;
    ConfigApi.encuestaCompletada = false;
    ConfigApi.sleepStartTime = null;
    ConfigApi.datosUsuarioCache = null;
    ConfigApi.datosRelojCache = null;
    
    await SessionService.limpiarSesion();
    
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint("Error al cerrar sesión de Google: $e");
    }
  }

  static Future<bool> cambiarContrasena({
    required String contrasenaActual,
    required String contrasenaNueva,
  }) async {
    final nombre = ConfigApi.usuarioActual;
    if (nombre == null || nombre.trim().isEmpty) return false;

    try {
      final respuesta = await http.put(
        Uri.parse('${ConfigApi.urlServidor}/usuario/${Uri.encodeComponent(nombre)}/contrasena'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contrasena_actual': contrasenaActual,
          'contrasena_nueva': contrasenaNueva,
        }),
      );
      return respuesta.statusCode == 200;
    } catch (e) {
      debugPrint('Error cambiando contraseña: $e');
      return false;
    }
  }
}