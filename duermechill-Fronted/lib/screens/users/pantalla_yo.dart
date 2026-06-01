import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/l10n/app_localizations.dart';
import 'package:proyecto_intermodular/services/config_api.dart';
import 'package:proyecto_intermodular/widgets/mi_drawer.dart';

class PantallaYo extends StatefulWidget {
  const PantallaYo({super.key});

  @override
  State<PantallaYo> createState() => _PantallaYoState();
}

class _PantallaYoState extends State<PantallaYo> {
  @override
  Widget build(BuildContext context) {
    String nombreUsuario = ConfigApi.usuarioActual ?? "Usuario";
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!; // CARGAMOS EL DICCIONARIO

    final screenSize = MediaQuery.of(context).size;
    final avatarRadius = screenSize.width > 600 ? 80.0 : (screenSize.width > 400 ? 60.0 : 50.0);
    final titleFontSize = screenSize.width > 600 ? 36.0 : (screenSize.width > 400 ? 30.0 : 24.0);
    final subtitleFontSize = screenSize.width > 400 ? 16.0 : 14.0;

    return Scaffold(
      backgroundColor: Colors.transparent, 
      appBar: AppBar(
        backgroundColor: const Color(0xFF6EADD8),
        title: Text(loc.perfilTitulo, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const MiDrawer(), 
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: avatarRadius, 
                backgroundColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0), 
                child: Icon(Icons.person, size: avatarRadius * 1.2, color: Colors.white)
              ),
              SizedBox(height: screenSize.height > 800 ? 30 : 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  loc.perfilHola(nombreUsuario), // TRADUCCIÓN DINÁMICA
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: titleFontSize, color: isDark ? Colors.white : const Color(0xFF2A3F54), fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(height: screenSize.height > 800 ? 15 : 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  loc.perfilSubtitulo, 
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: subtitleFontSize, color: isDark ? Colors.white70 : Colors.black54)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}