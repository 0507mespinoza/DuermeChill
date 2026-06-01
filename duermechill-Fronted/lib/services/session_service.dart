import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _kUsuario = 'session.usuario';
  static const _kOnboardingCompleted = 'session.onboarding_completed';
  static const _kSleepStartTime = 'session.sleep_start_time';

  static Future<void> guardarSesion({
    required String usuario,
    required bool onboardingCompleted,
    String? sleepStartTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsuario, usuario);
    await prefs.setBool(_kOnboardingCompleted, onboardingCompleted);
    if (sleepStartTime != null && sleepStartTime.trim().isNotEmpty) {
      await prefs.setString(_kSleepStartTime, sleepStartTime);
    } else {
      await prefs.remove(_kSleepStartTime);
    }
  }

  static Future<Map<String, dynamic>?> leerSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final usuario = prefs.getString(_kUsuario);
    if (usuario == null || usuario.trim().isEmpty) return null;

    final onboardingCompleted = prefs.getBool(_kOnboardingCompleted) ?? false;
    final sleepStartTime = prefs.getString(_kSleepStartTime);

    return {
      'usuario': usuario,
      'onboarding_completed': onboardingCompleted,
      'sleep_start_time': sleepStartTime,
    };
  }

  static Future<void> limpiarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUsuario);
    await prefs.remove(_kOnboardingCompleted);
    await prefs.remove(_kSleepStartTime);
  }
}
