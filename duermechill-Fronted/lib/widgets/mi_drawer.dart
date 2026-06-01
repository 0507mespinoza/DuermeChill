import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/l10n/app_localizations.dart';
import '/services/config_api.dart';
import '../services/auth_service.dart';
import '../screens/users/pantalla_editar_encuesta.dart';
import '../screens/pantalla_login.dart';

class MiDrawer extends StatelessWidget {
  const MiDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    String nombreUsuario = ConfigApi.usuarioActual ?? "Usuario";
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Guardamos la instancia de traducciones para escribir menos
    final loc = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              // Oscurecemos un pelín la cabecera en modo oscuro si queremos, o lo dejamos fijo.
              color: isDark ? const Color(0xFF5A8BAE) : const Color(0xFF6EADD8), 
            ),
            accountName: Text(nombreUsuario, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            accountEmail: Text(loc.drawerPremium, style: const TextStyle(color: Colors.white70)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
              child: Icon(Icons.person, size: 40, color: isDark ? Colors.white70 : const Color(0xFF6EADD8)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.edit_note, color: isDark ? Colors.white70 : Colors.black54),
            title: Text(
              loc.drawerEditarEncuesta,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PantallaEditarEncuesta()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.language, color: isDark ? Colors.white70 : Colors.black54),
            title: Text(loc.drawerIdioma, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            trailing: Text(ConfigApi.idiomaActual.value.languageCode.toUpperCase(), style: const TextStyle(color: Colors.grey)),
            onTap: () {
              // Botón que alterna el idioma
              Locale nuevoIdioma = ConfigApi.idiomaActual.value.languageCode == 'es' ? const Locale('en') : const Locale('es');
              ConfigApi.cambiarIdioma(nuevoIdioma);
              Navigator.pop(context); // Cierra el menú tras cambiar el idioma
            },
          ),
          
          // NUEVO: Switch para el Modo Oscuro
          ValueListenableBuilder<bool>(
            valueListenable: ConfigApi.isDarkMode,
            builder: (context, modoOscuroActivado, child) {
              return SwitchListTile(
                secondary: Icon(
                  modoOscuroActivado ? Icons.dark_mode : Icons.light_mode, 
                  color: modoOscuroActivado ? Colors.white70 : Colors.black54
                ),
                title: Text(
                  loc.drawerTema, 
                  style: TextStyle(color: modoOscuroActivado ? Colors.white : Colors.black87)
                ),
                activeColor: const Color(0xFF6EADD8), // Color azul cuando está activado
                value: modoOscuroActivado,
                onChanged: (bool nuevoValor) {
                  // Esto cambia la variable y hace que Flutter repinte TODA la app al instante
                  ConfigApi.cambiarTema(nuevoValor);
                },
              );
            }
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(loc.drawerCerrar, style: const TextStyle(color: Colors.redAccent)),
            onTap: () async {
              // Asegurarnos de que el cerrado de sesión (con Google u otros) termine antes de navegar
              await AuthService.cerrarSesion();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const PantallaLogin()), (route) => false);
            },
          ),
        ],
      ),
    );
  }
}