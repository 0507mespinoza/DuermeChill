import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/l10n/app_localizations.dart';
import 'package:proyecto_intermodular/screens/users/pantalla_yo.dart'; 
import 'users/pantalla_estadisticas.dart';
import 'users/pantalla_registro_datos.dart';
import 'users/pantalla_alarmas.dart';
import 'users/pantalla_coach.dart'; 

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _selectedIndex = 0;
  Key _statsKey = UniqueKey();

  void _onTabTapped(int index) {
    if (index == 1 && _selectedIndex != 1) {
      // Al volver a estadísticas, forzar recarga de datos
      _statsKey = UniqueKey();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!; 

    return Scaffold(

      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const PantallaYo(),
          PantallaEstadisticas(key: _statsKey),
          const PantallaRegistroDatos(),
          const PantallaAlarmas(),
          const PantallaCoach(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, 
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        selectedItemColor: const Color(0xFF6EADD8),
        unselectedItemColor: isDark ? Colors.white54 : Colors.black54,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: loc.navYo),
          BottomNavigationBarItem(icon: const Icon(Icons.bar_chart), label: loc.navEstadisticas),
          BottomNavigationBarItem(icon: const Icon(Icons.description), label: loc.navRegistro),
          BottomNavigationBarItem(icon: const Icon(Icons.alarm), label: loc.navAlarmas),
          BottomNavigationBarItem(icon: const Icon(Icons.psychology), label: loc.navCoach), 
        ],
      ),
    );
  }
}