import 'dart:async'; // Añadido para gestionar la emisora de la alarma
import 'package:alarm/alarm.dart'; // Añadido para los tipos de la alarma
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Sustituye a dart:io y evita errores en Web

class ConfigApi {
  // Emisora de radio global para que el stream no explote en Android al reentrar
  static final StreamController<AlarmSettings> emisoraAlarmas = StreamController<AlarmSettings>.broadcast();

  // Tu IP real para el móvil físico
  static const String _ipMiOrdenador = '172.30.67.89';

  static String get urlServidor {
    if (kIsWeb) {
      // Si ejecutas en Chrome (Web) -> usa localhost
      return 'http://localhost:8080/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Si estás en un móvil físico Android -> usa la IP de tu Wi-Fi
      return 'http://$_ipMiOrdenador:8080/api';
      
      // Si algún día vuelves a usar el EMULADOR de Android, 
      // comenta la línea de arriba y descomenta esta de abajo:
      // return 'http://10.0.2.2:8080/api';
    } else {
      // Por defecto para otras plataformas
      return 'http://localhost:8080/api';
    }
  }

  static String? usuarioActual;
  static bool encuestaCompletada = false;
  static bool esAdmin = false;
  static String? sleepStartTime;
  static bool mostrarDiagnosticoSalud = false; 

  static bool get onboardingCompletado {
    final tieneSleepStart = sleepStartTime != null && sleepStartTime!.trim().isNotEmpty;
    return encuestaCompletada || tieneSleepStart;
  }

  static bool get debeMostrarOnboarding => !onboardingCompletado;

  // Variables reactivas para el diseño y el idioma
  static ValueNotifier<bool> isDarkMode = ValueNotifier(false);
  static ValueNotifier<Locale> idiomaActual = ValueNotifier(const Locale('es')); 

  static Map<String, dynamic>? datosUsuarioCache;
  static Map<String, dynamic>? datosRelojCache;

  static void cargarDatosGenerales() {
    isDarkMode.value = false;
    idiomaActual.value = const Locale('es');
    usuarioActual = null;
    encuestaCompletada = false;
    esAdmin = false;
    sleepStartTime = null;
    mostrarDiagnosticoSalud = false;
  }

  static void cambiarTema(bool oscuro) {
    isDarkMode.value = oscuro;
  }

  static void cambiarIdioma(Locale idioma) {
    idiomaActual.value = idioma;
  }
}