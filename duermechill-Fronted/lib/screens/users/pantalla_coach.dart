import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:proyecto_intermodular/l10n/app_localizations.dart';
import '../../services/coach_service.dart';
import '../../widgets/mi_drawer.dart';
import '../../services/config_api.dart';

class PantallaCoach extends StatefulWidget {
  const PantallaCoach({super.key});

  @override
  State<PantallaCoach> createState() => _PantallaCoachState();
}

class _PantallaCoachState extends State<PantallaCoach> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _mensajes = [];
  List<Map<String, dynamic>> _listaSesiones = [];
  
  bool _cargando = false;
  String _sessionIdActual = DateTime.now().millisecondsSinceEpoch.toString();

  final String _apiKey = 'AIzaSyAY__gVc96h4z5m0O3hGHQN216IRgiQWv4';
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
    _cargarListaSesiones();
  }

  Future<void> _cargarListaSesiones() async {
    final sesiones = await CoachService.obtenerSesionesCoach();
    setState(() {
      _listaSesiones = sesiones;
    });
  }

  void _iniciarNuevaConversacion() {
    setState(() {
      _sessionIdActual = DateTime.now().millisecondsSinceEpoch.toString();
      _mensajes = [];
    });
    Navigator.pop(context); 
  }

  Future<void> _cargarConversacionAntigua(String sessionId) async {
    Navigator.pop(context); 
    setState(() => _cargando = true);
    
    final mensajesRecuperados = await CoachService.obtenerMensajesSesion(sessionId);
    
    setState(() {
      _sessionIdActual = sessionId;
      _mensajes = mensajesRecuperados;
      _cargando = false;
    });
  }

 Future<void> _enviarPregunta() async {
    if (_controller.text.isEmpty) return;

    final textoUsuario = _controller.text;

    setState(() {
      _mensajes.add({"rol": "user", "texto": textoUsuario});
      _cargando = true;
    });
    _controller.clear();
    
    await CoachService.guardarMensajeCoach("user", textoUsuario, _sessionIdActual); 

    try {
      String nombreUsuario = ConfigApi.usuarioActual ?? "Usuario";
      
      // 1. obtener datos de sueño manual
      String contextoSueno = "El usuario aún no ha registrado datos de sueño manuales hoy.";
      final datos = ConfigApi.datosUsuarioCache;
      if (datos != null) {
        final historial = (datos['historial_registros'] as List?) ?? [];
        if (historial.isNotEmpty) {
          final ultimaNoche = historial.last;
          contextoSueno = "Registro manual de anoche: durmió ${ultimaNoche['horas_dormidas']} horas. "
                          "Calidad: '${ultimaNoche['como_dormido']}'. "
                          "Cansancio al despertar: '${ultimaNoche['cansado']}'. "
                          "Despertares: ${ultimaNoche['despertares']} veces.";
        }
      }

      // 2. obtener datos del smartwach
      String contextoReloj = "No hay datos de reloj inteligente disponibles.";
      final datosReloj = ConfigApi.datosRelojCache;
      if (datosReloj != null) {
        final pulsaciones = (datosReloj['pulsaciones'] as List?) ?? [];
        final ultimoReloj = datosReloj['ultimo_reloj'];

        if (ultimoReloj != null) {
          contextoReloj = "Datos del Smartwatch de la última noche:\n"
              "- Fases del sueño: Despierto: ${ultimoReloj['horas_awake']}h, Ligero: ${ultimoReloj['horas_light']}h, Profundo: ${ultimoReloj['horas_deep']}h, REM: ${ultimoReloj['horas_rem']}h.\n";
              
          if (pulsaciones.isNotEmpty) {
             // Calcular media, max y min de pulsaciones para la IA
             int suma = 0;
             int max = 0;
             int min = 999;
             for(var p in pulsaciones) {
               int val = (p['valor'] is int) ? p['valor'] : int.tryParse(p['valor'].toString()) ?? 0;
               if (val > 0) {
                 suma += val;
                 if(val > max) max = val;
                 if(val < min) min = val;
               }
             }
             int media = pulsaciones.isNotEmpty ? (suma ~/ pulsaciones.length) : 0;
             
             contextoReloj += "- Frecuencia Cardíaca: Media de $media ppm, Mínima de $min ppm, Máxima de $max ppm. ";
          }
        }
      }

      // 3. Ipromt de la ia
      final promptOculto = "Eres DuermeChill AI, un experto coach de higiene del sueño. "
          "Estás hablando con $nombreUsuario. "
          "Tu objetivo es darle consejos breves, amables, empáticos y basados en la ciencia. "
          "INFORMACIÓN PRIVADA DEL USUARIO (úsala solo si es útil para responder a su pregunta actual):\n"
          "1. $contextoSueno\n"
          "2. $contextoReloj\n"
          "PREGUNTA DEL USUARIO: $textoUsuario";
      
      final response = await _model.generateContent([Content.text(promptOculto)]);
      final textoRespuesta = response.text ?? "Vaya, me he quedado dormido y no pude procesar eso. ¿Puedes repetirlo?";
      
      setState(() {
        _mensajes.add({"rol": "bot", "texto": textoRespuesta});
      });
      
      await CoachService.guardarMensajeCoach("bot", textoRespuesta, _sessionIdActual); 
      _cargarListaSesiones(); 
      
    } catch (e) {
      print(" ERROR REAL DE LA IA: $e");
      setState(() {
        _mensajes.add({"rol": "bot", "texto": "Lo siento, tengo problemas para conectarme al servidor ahora mismo. Inténtalo de nuevo más tarde."});
      });
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!; // CARGAMOS EL DICCIONARIO

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(loc.coachTitulo, style: const TextStyle(color: Colors.white)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF6EADD8),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      drawer: const MiDrawer(),
      endDrawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              color: isDark ? const Color(0xFF5A8BAE) : const Color(0xFF6EADD8),
              child: Column(
                children: [
                  const Icon(Icons.forum, color: Colors.white, size: 40),
                  const SizedBox(height: 10),
                  Text(loc.coachConversaciones, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: Color(0xFF6EADD8)),
              title: Text(loc.coachNueva, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              onTap: _iniciarNuevaConversacion,
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _listaSesiones.length,
                itemBuilder: (context, index) {
                  final sesion = _listaSesiones[index];
                  DateTime fecha = DateTime.parse(sesion['fecha']).toLocal();
                  String fechaStr = "${fecha.day}/${fecha.month} - ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";
                  
                  return ListTile(
                    leading: Icon(Icons.chat_bubble_outline, color: isDark ? Colors.white70 : Colors.black54),
                    title: Text(sesion['titulo'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text(fechaStr, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                    tileColor: _sessionIdActual == sesion['session_id'] ? (isDark ? Colors.white10 : Colors.blue.withValues(alpha: 0.1)) : null,
                    onTap: () => _cargarConversacionAntigua(sesion['session_id']),
                  );
                },
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _mensajes.isEmpty 
              ? Center(
                  child: Text(loc.coachVacio, 
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                )
              : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final m = _mensajes[index];
                bool esBot = m['rol'] == 'bot';
                return Align(
                  alignment: esBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: esBot ? (isDark ? Colors.grey[800] : Colors.grey[200]) : const Color(0xFF6EADD8),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      m['texto']!,
                      style: TextStyle(color: esBot ? (isDark ? Colors.white : Colors.black87) : Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_cargando) const LinearProgressIndicator(color: Color(0xFF6EADD8)),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: loc.coachEscribe,
                      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF6EADD8),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _enviarPregunta,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}