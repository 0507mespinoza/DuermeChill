import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/entrada_de_texto.dart'; 
import 'users/pantalla_encuesta.dart'; 

class PantallaDeRegistro extends StatefulWidget {
  const PantallaDeRegistro({super.key});

  @override
  State<PantallaDeRegistro> createState() => _PantallaDeRegistroState();
}

class _PantallaDeRegistroState extends State<PantallaDeRegistro> {
  final _controladorNombre = TextEditingController();
  final _controladorEdad = TextEditingController();
  final _controladorCorreo = TextEditingController();
  final _controladorContrasena = TextEditingController();

  Future<void> _guardarUsuario(AppLocalizations loc) async {
    if (_controladorNombre.text.isNotEmpty && _controladorContrasena.text.isNotEmpty) {
      
      bool guardado = await AuthService.registrarUsuario(
        _controladorNombre.text,
        _controladorEdad.text,
        _controladorCorreo.text,
        _controladorContrasena.text,
      );
      
      if (!mounted) return;
      
      if (guardado) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.registroExito)));
        await AuthService.establecerSesionTrasRegistro(_controladorNombre.text);
        if (!mounted) return;
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PantallaEncuesta()),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.errorCamposVacios)));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width > 600 ? 80.0 : (screenSize.width > 400 ? 40.0 : 24.0);
    final titleFontSize = screenSize.width > 600 ? 60.0 : (screenSize.width > 400 ? 55.0 : 45.0);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(loc.registroTitulo, style: TextStyle(fontSize: titleFontSize, color: const Color(0xFF6EADD8), fontWeight: FontWeight.w400), textAlign: TextAlign.center),
                SizedBox(height: screenSize.height > 800 ? 50 : 30),
                EntradaDeTexto(textoIndicador: loc.registroNombre, controlador: _controladorNombre),
                EntradaDeTexto(textoIndicador: loc.registroEdad, controlador: _controladorEdad),
                EntradaDeTexto(textoIndicador: loc.registroCorreo, controlador: _controladorCorreo),
                EntradaDeTexto(textoIndicador: loc.loginPass, controlador: _controladorContrasena, ocultarTexto: true),
                SizedBox(height: screenSize.height > 800 ? 30 : 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(loc.registroAtras, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 16)),
                    ),
                    ElevatedButton(
                      onPressed: () => _guardarUsuario(loc),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF333333),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(loc.loginRegisterBtn, style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}