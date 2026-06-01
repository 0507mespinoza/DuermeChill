import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/l10n/app_localizations.dart';
import '../../services/config_api.dart';
import '../../services/datos_service.dart';
import '../../widgets/mi_drawer.dart';

class PantallaAlarmas extends StatefulWidget {
  const PantallaAlarmas({super.key});

  @override
  State<PantallaAlarmas> createState() => _PantallaAlarmasState();
}

class _PantallaAlarmasState extends State<PantallaAlarmas> {
  List<Map<String, dynamic>> _alarmas = [];
  bool _cargando = true;
  StreamSubscription<AlarmSettings>? _ringSubscription;

  @override
  void initState() {
    super.initState();
    _cargarAlarmasDesdeServidor();
    
    _ringSubscription = ConfigApi.emisoraAlarmas.stream.listen((alarmSettings) {
      _mostrarPantallaDespertar(alarmSettings.id);
    });
  }

  @override
  void dispose() {
    _ringSubscription?.cancel();
    super.dispose();
  }

  Future<void> _cargarAlarmasDesdeServidor() async {
    await DatosService.sincronizarDatosDesdeServidor(); 
    final datos = ConfigApi.datosUsuarioCache;
    
    if (datos != null && datos['alarmas'] != null) {
      setState(() {
        _alarmas = (datos['alarmas'] as List).map((a) {
          final partesHora = a['hora'].split(':');
          return {
            'hora': TimeOfDay(hour: int.parse(partesHora[0]), minute: int.parse(partesHora[1])),
            'activada': a['activada'],
          };
        }).toList();
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
  }

  // logica del paquete alarma
  DateTime _calcularFechaAlarma(TimeOfDay hora) {
    final ahora = DateTime.now();
    DateTime fechaProgramada = DateTime(ahora.year, ahora.month, ahora.day, hora.hour, hora.minute);
    
    if (fechaProgramada.isBefore(ahora)) {
      fechaProgramada = fechaProgramada.add(const Duration(days: 1));
    }
    return fechaProgramada;
  }

  void _programarAlarmaReal(int id, TimeOfDay hora) async {
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: _calcularFechaAlarma(hora),
      assetAudioPath: 'assets/audio/alarma.mp3',
      loopAudio: true,
      vibrate: true,
      
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: const Duration(seconds: 3),
        volumeEnforced: true,
      ),
      
      notificationSettings: const NotificationSettings(
        title: 'DuermeChill',
        body: '¡Hora de despertarse!',
        stopButton: 'Apagar',
      ),
    );
    
    await Alarm.set(alarmSettings: alarmSettings);
  }

  void _cancelarAlarmaReal(int id) async {
    await Alarm.stop(id);
  }

  void _agregarAlarma() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        _alarmas.add({'hora': selectedTime, 'activada': true});
        _ordenarAlarmas();
      });
      _programarAlarmaReal(_alarmas.length - 1, selectedTime);
      DatosService.guardarAlarmas(_alarmas);
    }
  }

  void _editarAlarma(int index) async {
    TimeOfDay horaActual = _alarmas[index]['hora'];
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: horaActual,
    );

    if (selectedTime != null) {
      setState(() {
        _alarmas[index]['hora'] = selectedTime;
        _alarmas[index]['activada'] = true; 
        _ordenarAlarmas();
      });
      _programarAlarmaReal(index, selectedTime);
      DatosService.guardarAlarmas(_alarmas);
    }
  }

  void _toggleAlarma(int index) {
    bool nuevoEstado = !_alarmas[index]['activada'];
    setState(() {
      _alarmas[index]['activada'] = nuevoEstado;
    });
    
    if (nuevoEstado) {
      _programarAlarmaReal(index, _alarmas[index]['hora']);
    } else {
      _cancelarAlarmaReal(index);
    }
    DatosService.guardarAlarmas(_alarmas);
  }

  void _eliminarAlarma(int index, AppLocalizations loc) {
    final alarmaEliminada = _alarmas[index];
    _cancelarAlarmaReal(index); // Parar por si estaba sonando/programada
    
    setState(() {
      _alarmas.removeAt(index);
    });
    DatosService.guardarAlarmas(_alarmas);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.alarmaEliminada),
        action: SnackBarAction(
          label: loc.btnDeshacer,
          textColor: const Color(0xFF6EADD8),
          onPressed: () {
            setState(() {
              _alarmas.insert(index, alarmaEliminada);
              _ordenarAlarmas();
            });
            if (alarmaEliminada['activada']) {
              _programarAlarmaReal(index, alarmaEliminada['hora']);
            }
            DatosService.guardarAlarmas(_alarmas);
          },
        ),
      ),
    );
  }

  void _ordenarAlarmas() {
    _alarmas.sort((a, b) {
      final horaA = a['hora'] as TimeOfDay;
      final horaB = b['hora'] as TimeOfDay;
      if (horaA.hour != horaB.hour) {
        return horaA.hour.compareTo(horaB.hour);
      }
      return horaA.minute.compareTo(horaB.minute);
    });
  }

  // registro del despertar
  void _mostrarPantallaDespertar(int alarmId) {
    showDialog(
      context: context,
      barrierDismissible: false, // Obliga a pulsar el botón para cerrar
      builder: (context) {
        return AlertDialog(
          title: const Text('¡Buenos días!', textAlign: TextAlign.center),
          content: const Text('Es hora de levantarse. ¿Apagamos la alarma?', textAlign: TextAlign.center),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6EADD8),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () async {
                // 1. Apagar el sonido
                await Alarm.stop(alarmId);
                
                // 2. Registrar la hora exacta actual
                DateTime horaDespertar = DateTime.now();
                
                try {
                  await DatosService.registrarHoraDespertar(horaDespertar);
                } catch (e) {
                  debugPrint("Aún no existe la función registrarHoraDespertar");
                }
                
                // 3. Cerrar la ventana
                if (mounted) Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Hora de despertar registrada con éxito!'))
                );
              },
              child: const Text('Apagar y Registrar', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF6EADD8),
        title: Text(loc.alarmasTitulo, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      drawer: const MiDrawer(),
      body: _cargando 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6EADD8)))
        : _alarmas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_off, size: 80, color: isDark ? Colors.white38 : Colors.black12),
                  const SizedBox(height: 16),
                  Text(loc.alarmasVacio,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.black54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 80), 
              itemCount: _alarmas.length,
              itemBuilder: (context, index) {
                final alarma = _alarmas[index];
                final hora = alarma['hora'] as TimeOfDay;
                final activada = alarma['activada'] as bool;
                final horaStr = '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
                final screenWidth = MediaQuery.of(context).size.width;
                final horaFontSize = screenWidth < 360 ? 24.0 : (screenWidth < 420 ? 28.0 : 32.0);
                
                return Dismissible(
                  key: Key(horaStr + index.toString()), 
                  direction: DismissDirection.endToStart, 
                  background: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white, size: 30),
                  ),
                  onDismissed: (direction) => _eliminarAlarma(index, loc),
                  child: Card(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: activada ? 4 : 1, 
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _editarAlarma(index), 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: Text(
                            horaStr,
                            style: TextStyle(
                              fontSize: horaFontSize, fontWeight: FontWeight.w300, 
                              color: activada ? (isDark ? Colors.white : const Color(0xFF2A3F54)) : (isDark ? Colors.white38 : Colors.black38) 
                            ),
                          ),
                          title: Text(activada ? loc.alarmaActivada : loc.alarmaDesactivada,
                            style: TextStyle(fontSize: 12, color: activada ? const Color(0xFF6EADD8) : Colors.grey),
                          ),
                          trailing: Switch(
                            value: activada,
                            onChanged: (value) => _toggleAlarma(index),
                            activeThumbColor: const Color(0xFF6EADD8),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarAlarma,
        backgroundColor: isDark ? const Color(0xFF5A8BAE) : const Color(0xFF6EADD8),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}