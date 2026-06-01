import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/l10n/app_localizations.dart';
import 'pantalla_editar_contrasena.dart';
import '../../services/datos_service.dart';

class PantallaEditarEncuesta extends StatefulWidget {
  const PantallaEditarEncuesta({super.key});

  @override
  State<PantallaEditarEncuesta> createState() => _PantallaEditarEncuestaState();
}

class _PantallaEditarEncuestaState extends State<PantallaEditarEncuesta> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _expectativaController = TextEditingController();
  final TextEditingController _nocheController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _edadEncuestaController = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  String _nombreOriginal = '';

  @override
  void initState() {
    super.initState();
    _cargarDatosActuales();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _edadController.dispose();
    _expectativaController.dispose();
    _nocheController.dispose();
    _horaController.dispose();
    _edadEncuestaController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosActuales() async {
    setState(() => _cargando = true);
    final datos = await DatosService.obtenerPerfilEditable();

    if (!mounted) return;

    if (datos != null) {
      _nombreController.text = datos['nombre']?.toString() ?? '';
      _correoController.text = datos['correo']?.toString() ?? '';
      _edadController.text = datos['edad']?.toString() ?? '';
      _expectativaController.text = datos['expectativa']?.toString() ?? '';
      _nocheController.text = datos['noche']?.toString() ?? '';
      _horaController.text = datos['hora']?.toString() ?? '';
      _edadEncuestaController.text = datos['edadEncuesta']?.toString() ?? '';
      _nombreOriginal = _nombreController.text.trim();
    }

    setState(() => _cargando = false);
  }

  Future<void> _guardarCambios() async {
    if (_guardando || !_formKey.currentState!.validate()) return;
    final loc = AppLocalizations.of(context)!;

    setState(() => _guardando = true);

    final ok = await DatosService.guardarEdicionUsuarioYEncuesta(
      nombreActual: _nombreOriginal,
      nuevoNombre: _nombreController.text.trim(),
      correo: _correoController.text.trim(),
      edad: _edadController.text.trim(),
      expectativa: _expectativaController.text.trim(),
      noche: _nocheController.text.trim(),
      hora: _horaController.text.trim(),
      edadEncuesta: _edadEncuestaController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _guardando = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.editarEncuestaErrorGuardar)),
      );
      return;
    }

    _nombreOriginal = _nombreController.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.editarEncuestaExito)),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6EADD8),
        title: Text(loc.editarEncuestaTitulo, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          loc.editarEncuestaSeccionUsuario,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF2A3F54),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _campo(loc.editarEncuestaNombre, _nombreController, isDark, loc: loc),
                        _campo(loc.editarEncuestaCorreo, _correoController, isDark, loc: loc),
                        _campo(loc.editarEncuestaEdad, _edadController, isDark, loc: loc, keyboardType: TextInputType.number),
                        const SizedBox(height: 8),
                        Text(
                          loc.editarEncuestaSeguridad,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF2A3F54),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          child: ListTile(
                            leading: const Icon(Icons.lock_outline, color: Color(0xFF6EADD8)),
                            title: Text(
                              loc.perfilEditarContrasena,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PantallaEditarContrasena()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          loc.editarEncuestaSeccionPrimera,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF2A3F54),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _campo(loc.editarEncuestaExpectativa, _expectativaController, isDark, loc: loc),
                        _campo(loc.editarEncuestaNoche, _nocheController, isDark, loc: loc),
                        _campo(loc.editarEncuestaHora, _horaController, isDark, loc: loc),
                        _campo(loc.editarEncuestaEdadPrimera, _edadEncuestaController, isDark, loc: loc, keyboardType: TextInputType.number),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _guardando ? null : _guardarCambios,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6EADD8),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            _guardando ? loc.editarEncuestaGuardando : loc.editarEncuestaGuardarCambios,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController controller,
    bool isDark, {
    required AppLocalizations loc,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          filled: true,
          fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE9EDF1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return loc.editarEncuestaCampoObligatorio;
          }
          return null;
        },
      ),
    );
  }
}
