import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/l10n/app_localizations.dart';
import '../../services/datos_service.dart';
import '../pantalla_principal.dart';

class PantallaEncuesta extends StatefulWidget {
  const PantallaEncuesta({super.key});

  @override
  State<PantallaEncuesta> createState() => _PantallaEncuestaState();
}

class _PantallaEncuestaState extends State<PantallaEncuesta> {
  String? r1;
  String? r2;
  String? r3;
  String? r4;

  void _seleccionarOpcion(String titulo, List<String> opciones, Function(String) alSeleccionar) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black)),
              const Divider(),
              ...opciones.map((opc) => ListTile(
                title: Text(opc, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                onTap: () {
                  alSeleccionar(opc);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!; // CARGAMOS EL DICCIONARIO

    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width > 600 ? 60.0 : (screenSize.width > 400 ? 40.0 : 24.0);
    final titleFontSize = screenSize.width > 600 ? 56.0 : (screenSize.width > 400 ? 50.0 : 40.0);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            children: [
              Text(loc.appTitle, style: TextStyle(fontSize: titleFontSize, color: const Color(0xFF6EADD8))),
              const SizedBox(height: 20),
              Text(loc.encuestaSubtitulo, style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.black54)),
              SizedBox(height: screenSize.height > 800 ? 40 : 25),
              
              _burbuja(r1 ?? loc.encuestaQ1, () => _seleccionarOpcion(loc.encuestaModal1, [loc.encuestaOpc1A, loc.encuestaOpc1B, loc.encuestaOpc1C], (val) => setState(() => r1 = val)), isDark),
              _burbuja(r2 ?? loc.encuestaQ2, () => _seleccionarOpcion(loc.encuestaModal2, [loc.encuestaOpc2A, loc.encuestaOpc2B, loc.encuestaOpc2C, loc.encuestaOpc2D], (val) => setState(() => r2 = val)), isDark),
              _burbuja(r3 ?? loc.encuestaQ3, () => _seleccionarOpcion(loc.encuestaModal3, [loc.encuestaOpc3A, loc.encuestaOpc3B, loc.encuestaOpc3C, loc.encuestaOpc3D], (val) => setState(() => r3 = val)), isDark),
              _burbuja(r4 ?? loc.encuestaQ4, () => _seleccionarOpcion(loc.encuestaModal4, [loc.encuestaOpc4A, loc.encuestaOpc4B, loc.encuestaOpc4C, loc.encuestaOpc4D], (val) => setState(() => r4 = val)), isDark),
              
              SizedBox(height: screenSize.height > 800 ? 50 : 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context), 
                      child: Text(loc.btnCancelar, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 16))
                    ),
                  ),
                  SizedBox(width: screenSize.width > 400 ? 16 : 8),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () async {
                        final ok = await DatosService.guardarDatosEncuesta({
                          "expectativa": r1 ?? loc.encuestaQ1, 
                          "noche": r2 ?? loc.encuestaQ2, 
                          "hora": r3 ?? loc.encuestaQ3, 
                          "edad": r4 ?? loc.encuestaQ4
                        });
                        if (!context.mounted) return;
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No se pudo guardar la encuesta. Inténtalo de nuevo.')),
                          );
                          return;
                        }
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PantallaPrincipal()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF333333),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(loc.btnGuardar, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _burbuja(String texto, VoidCallback accion, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: accion,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFCCCCCC),
            borderRadius: BorderRadius.circular(30)
          ),
          child: Text(texto, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
        ),
      ),
    );
  }
}