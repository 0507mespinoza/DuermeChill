import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/l10n/app_localizations.dart';
import '../../services/auth_service.dart';

class PantallaEditarContrasena extends StatefulWidget {
  const PantallaEditarContrasena({super.key});

  @override
  State<PantallaEditarContrasena> createState() => _PantallaEditarContrasenaState();
}

class _PantallaEditarContrasenaState extends State<PantallaEditarContrasena> {
  final _formKey = GlobalKey<FormState>();
  final _actualCtrl = TextEditingController();
  final _nuevaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();

  bool _guardando = false;

  @override
  void dispose() {
    _actualCtrl.dispose();
    _nuevaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final loc = AppLocalizations.of(context)!;
    if (_guardando || !_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    final ok = await AuthService.cambiarContrasena(
      contrasenaActual: _actualCtrl.text.trim(),
      contrasenaNueva: _nuevaCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _guardando = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.editarContrasenaError)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.editarContrasenaExito)),
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
        title: Text(loc.editarContrasenaTitulo, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _campo(
                    label: loc.editarContrasenaActual,
                    controller: _actualCtrl,
                    isDark: isDark,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return loc.editarContrasenaCampoObligatorio;
                      }
                      return null;
                    },
                  ),
                  _campo(
                    label: loc.editarContrasenaNueva,
                    controller: _nuevaCtrl,
                    isDark: isDark,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return loc.editarContrasenaCampoObligatorio;
                      }
                      if (value.trim().length < 6) {
                        return loc.editarContrasenaMinima;
                      }
                      return null;
                    },
                  ),
                  _campo(
                    label: loc.editarContrasenaConfirmar,
                    controller: _confirmarCtrl,
                    isDark: isDark,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return loc.editarContrasenaCampoObligatorio;
                      }
                      if (value.trim() != _nuevaCtrl.text.trim()) {
                        return loc.editarContrasenaNoCoinciden;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _guardando ? null : _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6EADD8),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      ),
                      child: Text(
                        _guardando ? loc.editarContrasenaGuardando : loc.editarContrasenaGuardar,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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

  Widget _campo({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        validator: validator,
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
      ),
    );
  }
}
