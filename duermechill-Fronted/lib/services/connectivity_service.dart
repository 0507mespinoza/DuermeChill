import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static Future<bool> tieneConexion() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.isNotEmpty && !result.contains(ConnectivityResult.none);
    } catch (e) {
      debugPrint('[ConnectivityService] Error comprobando conectividad: $e');
      // Fail open — if we can't check, assume connected
      return true;
    }
  }
}
