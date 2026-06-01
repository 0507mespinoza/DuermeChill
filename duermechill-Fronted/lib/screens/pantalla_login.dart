import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/config_api.dart';
import 'admin/pantalla_admin.dart';
import '../widgets/entrada_de_texto.dart';
import 'pantalla_de_registro.dart';
import 'pantalla_principal.dart';
import 'users/pantalla_encuesta.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _controladorUsuario = TextEditingController();
  final _controladorContrasena = TextEditingController();
  bool _cargandoGoogle = false;

  void _intentarLogin(AppLocalizations loc) async {
    String usuario = _controladorUsuario.text;
    String contrasena = _controladorContrasena.text;

    if (usuario.isEmpty || contrasena.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.errorCamposVacios)));
      return;
    }

    bool exito = await AuthService.iniciarSesion(usuario, contrasena);

    if (!mounted) return;

    if (exito) {
      if (ConfigApi.esAdmin) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PantallaAdmin()));
      } else if (ConfigApi.onboardingCompletado) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PantallaPrincipal()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PantallaEncuesta()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.errorCredenciales)));
    }
  }

  // Boton google
  void _intentarLoginConGoogle() async {
    setState(() => _cargandoGoogle = true);
    
    bool exito = await AuthService.iniciarSesionConGoogle();
    
    if (!mounted) return;
    setState(() => _cargandoGoogle = false);

    if (exito) {
      if (ConfigApi.onboardingCompletado || ConfigApi.encuestaCompletada) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PantallaPrincipal()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PantallaEncuesta()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de conexión con Google / Backend")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width > 600 ? 60.0 : (screenSize.width > 400 ? 40.0 : 24.0);
    final titleFontSize = screenSize.width > 600 ? 56.0 : (screenSize.width > 400 ? 50.0 : 40.0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Locale nuevoIdioma = ConfigApi.idiomaActual.value.languageCode == 'es' ? const Locale('en') : const Locale('es');
                      ConfigApi.cambiarIdioma(nuevoIdioma);
                    },
                    icon: const Icon(Icons.language, color: Colors.grey),
                    label: Text(ConfigApi.idiomaActual.value.languageCode.toUpperCase(), style: const TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  loc.appTitle,
                  style: TextStyle(fontSize: titleFontSize, color: const Color(0xFF3498DB), fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 50),
                EntradaDeTexto(textoIndicador: loc.loginUsuario, controlador: _controladorUsuario),
                EntradaDeTexto(textoIndicador: loc.loginPass, controlador: _controladorContrasena, ocultarTexto: true),
                const SizedBox(height: 20),
                
                // Boton login normal
                SizedBox(
                  width: 200, 
                  child: ElevatedButton(
                    onPressed: () => _intentarLogin(loc),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF5A8BAE) : const Color(0xFF333333),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(loc.loginBtn, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 15),
                
                Row(
                  children: [
                    Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black26)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("o", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                    ),
                    Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black26)),
                  ],
                ),
                const SizedBox(height: 15),

                // Boton login con google
                SizedBox(
                  width: 200,
                  child: OutlinedButton.icon(
                    onPressed: _cargandoGoogle ? null : _intentarLoginConGoogle,
                    icon: _cargandoGoogle 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_Color_Icon.svg',
                            height: 20,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 30),
                          ),
                    label: Text(
                      'Google', 
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16)
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(color: isDark ? Colors.white38 : Colors.black26),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // BOTÓN REGISTRO
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaDeRegistro()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFF222222), 
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(loc.loginRegisterBtn, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}