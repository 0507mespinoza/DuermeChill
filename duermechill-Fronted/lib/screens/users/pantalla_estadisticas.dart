import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:proyecto_intermodular/l10n/app_localizations.dart';
import '../../models/sync_state.dart';
import '../../services/config_api.dart';
import '../../services/connectivity_service.dart';
import '../../services/datos_service.dart';
import '../../services/health_service.dart';
import '../../services/reloj_service.dart';
import '../../widgets/mi_drawer.dart';
import '../../widgets/sync_status_banner.dart';
import '../../widgets/health_debug_panel.dart';

// TODO: Asegúrate de importar los archivos donde estén definidos SleepWindow, SleepWindowHelper y HourlyHeartRateBlock si tu compilador los pide.

class PantallaEstadisticas extends StatefulWidget {
  const PantallaEstadisticas({super.key});

  @override
  State<PantallaEstadisticas> createState() => _PantallaEstadisticasState();
}

class _PantallaEstadisticasState extends State<PantallaEstadisticas> {
  late Future<void> _cargaDatosFuture;
  SyncState _syncState = const SyncState(SyncStatus.idle);

  @override
  void initState() {
    super.initState();
    _cargaDatosFuture = _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await DatosService.sincronizarDatosDesdeServidor();
    await RelojService.obtenerDatosRelojServidor();
  }

  Future<void> _sincronizarDesdeReloj() async {
    setState(() => _syncState = const SyncState(SyncStatus.syncing));

    final hayConexion = await ConnectivityService.tieneConexion();
    if (!hayConexion) {
      setState(() => _syncState = const SyncState(SyncStatus.noConnection,
          'Sin conexión a Internet. Comprueba tu red e inténtalo de nuevo.'));
      return;
    }

    final capError = await HealthService.verificarCapacidades();
    if (capError != null) {
      switch (capError.result) {
        case HealthSyncResult.healthConnectNotInstalled:
          setState(() => _syncState = SyncState(
              SyncStatus.healthConnectNotInstalled, capError.message));
          return;
        case HealthSyncResult.noPermissions:
          setState(() => _syncState =
              SyncState(SyncStatus.noPermissions, capError.message));
          return;
        default:
          setState(
              () => _syncState = SyncState(SyncStatus.error, capError.message));
          return;
      }
    }

    final syncError = await HealthService.sincronizarDesdeGoogleFitDetallado();
    if (syncError != null) {
      switch (syncError.result) {
        case HealthSyncResult.noPermissions:
          setState(() => _syncState =
              SyncState(SyncStatus.noPermissions, syncError.message));
          return;
        case HealthSyncResult.noData:
          setState(() =>
              _syncState = SyncState(SyncStatus.noData, syncError.message));
          return;
        case HealthSyncResult.healthConnectNotInstalled:
          setState(() => _syncState = SyncState(
              SyncStatus.healthConnectNotInstalled, syncError.message));
          return;
        case HealthSyncResult.networkError:
          setState(() => _syncState =
              SyncState(SyncStatus.noConnection, syncError.message));
          return;
        default:
          setState(() =>
              _syncState = SyncState(SyncStatus.error, syncError.message));
          return;
      }
    }

    await RelojService.obtenerDatosRelojServidor();
    setState(() => _syncState = const SyncState(
        SyncStatus.success, 'Datos sincronizados correctamente.'));
  }

  Future<void> _pedirPermisosHealthConnect() async {
    setState(() => _syncState = const SyncState(SyncStatus.syncing));
    final granted = await HealthService.abrirPantallaPermisosYVerificar();
    if (!granted) {
      setState(() => _syncState = const SyncState(SyncStatus.noPermissions,
          'Permisos de salud no concedidos. Abre Health Connect y permite el acceso a DuermeChill.'));
      return;
    }
    await _sincronizarDesdeReloj();
  }

  int _filtroHistorial = 0; 

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!; 
    
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600; 
    final padding = isMobile ? 12.0 : 16.0;
    final chartHeight = isMobile ? 200.0 : 250.0;
    final heartRateChartHeight = isMobile ? 220.0 : 280.0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6EADD8),
        title: Text(loc.navEstadisticas,
            style: TextStyle(fontSize: isMobile ? 18 : 22, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      drawer: const MiDrawer(),
      body: FutureBuilder(
        future: _cargaDatosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6EADD8)));
          }

          final datosUsuario = ConfigApi.datosUsuarioCache;
          final reloj = ConfigApi.datosRelojCache ?? {};
          final List pulsacionesRaw = (reloj['pulsaciones'] as List<dynamic>?) ?? [];
          final List fasesRelojRaw = (reloj['fases_sueno'] as List<dynamic>?) ?? [];
              
          final List historial = (datosUsuario?['historial_registros'] as List?) ?? [];
          final ultimoRegistro = historial.isNotEmpty ? historial.last : null;

          dynamic sleepWindow; 

          final List<Map<String, dynamic>> pulsaciones = pulsacionesRaw
                  .map((p) => Map<String, dynamic>.from(p as Map))
                  .toList();

          final hourlyBlocks = pulsaciones; 
          final fasesReloj = _parseSleepPhasesFromBackend(fasesRelojRaw);

          final bool backendTieneFases = fasesReloj.values.any((h) => h > 0);
          final bool backendTieneDetalladas = (fasesReloj['deep'] ?? 0) > 0 || (fasesReloj['rem'] ?? 0) > 0;

          final horasAwake = fasesReloj['awake'] ?? 0.0;
          final horasLight = fasesReloj['light'] ?? 0.0;
          final horasDeep = fasesReloj['deep'] ?? 0.0;
          final horasRem = fasesReloj['rem'] ?? 0.0;

          final String estadoFases = _buildSleepSourceStatus(
            backendTieneFases: backendTieneFases,
            backendTieneDetalladas: backendTieneDetalladas,
            hayPulsaciones: pulsaciones.isNotEmpty,
          );

          final horasDormidas = ultimoRegistro != null ? '${ultimoRegistro['horas_dormidas']}h' : loc.statsSinDatos;
          final calidadSueno = ultimoRegistro != null ? ultimoRegistro['como_dormido'] : loc.statsSinDatos;
          final nivelCansancio = ultimoRegistro != null ? ultimoRegistro['cansado'] : loc.statsSinDatos;
          final despertares = ultimoRegistro != null ? '${ultimoRegistro['despertares']}' : loc.statsSinDatos;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: isMobile
                ? _buildMobileLayout(isDark, loc, historial, hourlyBlocks, sleepWindow, horasAwake, horasLight, horasDeep, horasRem, estadoFases, horasDormidas, calidadSueno, nivelCansancio, despertares, chartHeight, heartRateChartHeight)
                : _buildTabletLayout(isDark, loc, historial, hourlyBlocks, sleepWindow, horasAwake, horasLight, horasDeep, horasRem, estadoFases, horasDormidas, calidadSueno, nivelCansancio, despertares, chartHeight, heartRateChartHeight),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(bool isDark, AppLocalizations loc, List historial, List<dynamic> hourlyBlocks, dynamic sleepWindow, double horasAwake, double horasLight, double horasDeep, double horasRem, String estadoFases, String horasDormidas, dynamic calidadSueno, dynamic nivelCansancio, String despertares, double chartHeight, double heartRateChartHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(loc.statsTitulo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2A3F54))),
        const SizedBox(height: 12),
        SizedBox(height: chartHeight, child: _buildUserSleepChart(historial, isDark, loc)),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFilterButton(loc.statsFiltro7, 0, isDark),
            _buildFilterButton(loc.statsFiltro14, 1, isDark),
            _buildFilterButton(loc.statsFiltroMes, 2, isDark),
          ],
        ),
        const SizedBox(height: 16),
        Text(loc.statsUltimaNoche, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2A3F54))),
        const SizedBox(height: 10),
        _tarjetaEstadistica(loc.statsHoras, horasDormidas, Icons.bedtime, Colors.indigo, isDark),
        _tarjetaEstadistica(loc.statsCalidad, calidadSueno.toString(), Icons.star_border, Colors.teal, isDark),
        _tarjetaEstadistica(loc.statsCansancio, nivelCansancio.toString(), Icons.battery_alert, Colors.orange, isDark),
        _tarjetaEstadistica(loc.statsDespertares, despertares, Icons.notifications_active, Colors.deepPurple, isDark),
        const SizedBox(height: 24),
        Text(loc.statsDatosReloj, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2A3F54))),
        const SizedBox(height: 12),
        SizedBox(height: heartRateChartHeight, child: _buildHeartRateChart(hourlyBlocks, sleepWindow, isDark, loc)),
        const SizedBox(height: 14),
        Text(loc.statsDatosPulsaciones, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2A3F54))),
        const SizedBox(height: 10),
        _buildHeartRateTable(hourlyBlocks, sleepWindow, isDark, loc),
        const SizedBox(height: 14),
        SyncStatusBanner(state: _syncState, onRetry: _sincronizarDesdeReloj, onOpenSettings: _pedirPermisosHealthConnect),
        ElevatedButton.icon(
          onPressed: _syncState.isLoading ? null : _sincronizarDesdeReloj,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF5A8BAE) : const Color(0xFF6EADD8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 48),
          ),
          icon: _syncState.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white))) : const Icon(Icons.sync),
          label: Text(_syncState.isLoading ? loc.statsBtnSincronizando : loc.statsBtnSincronizar),
        ),
        const SizedBox(height: 14),
        if (ConfigApi.mostrarDiagnosticoSalud) const HealthDebugPanel(),
        if (ConfigApi.mostrarDiagnosticoSalud) const SizedBox(height: 14),
        Text(loc.statsFasesSueno, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2A3F54))),
        const SizedBox(height: 6),
        _buildSleepDataSourceIndicator(estadoFases, isDark),
        const SizedBox(height: 10),
        _buildSleepPhasesTable(horasAwake, horasLight, horasDeep, horasRem, isDark, loc),
      ],
    );
  }

  Widget _buildTabletLayout(bool isDark, AppLocalizations loc, List historial, List<dynamic> hourlyBlocks, dynamic sleepWindow, double horasAwake, double horasLight, double horasDeep, double horasRem, String estadoFases, String horasDormidas, dynamic calidadSueno, dynamic nivelCansancio, String despertares, double chartHeight, double heartRateChartHeight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(loc.statsTitulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2A3F54))),
                const SizedBox(height: 12),
                SizedBox(height: chartHeight, child: _buildUserSleepChart(historial, isDark, loc)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFilterButton(loc.statsFiltro7, 0, isDark),
                    _buildFilterButton(loc.statsFiltro14, 1, isDark),
                    _buildFilterButton(loc.statsFiltroMes, 2, isDark),
                  ],
                ),
                const SizedBox(height: 16),
                Text(loc.statsUltimaNoche, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2A3F54))),
                const SizedBox(height: 10),
                _tarjetaEstadistica(loc.statsHoras, horasDormidas, Icons.bedtime, Colors.indigo, isDark),
                _tarjetaEstadistica(loc.statsCalidad, calidadSueno.toString(), Icons.star_border, Colors.teal, isDark),
                _tarjetaEstadistica(loc.statsCansancio, nivelCansancio.toString(), Icons.battery_alert, Colors.orange, isDark),
                _tarjetaEstadistica(loc.statsDespertares, despertares, Icons.notifications_active, Colors.deepPurple, isDark),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: heartRateChartHeight, child: _buildHeartRateChart(hourlyBlocks, sleepWindow, isDark, loc)),
                const SizedBox(height: 14),
                Text(loc.statsDatosPulsaciones, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2A3F54))),
                const SizedBox(height: 10),
                _buildHeartRateTable(hourlyBlocks, sleepWindow, isDark, loc),
                const SizedBox(height: 14),
                SyncStatusBanner(state: _syncState, onRetry: _sincronizarDesdeReloj, onOpenSettings: _pedirPermisosHealthConnect),
                ElevatedButton.icon(
                  onPressed: _syncState.isLoading ? null : _sincronizarDesdeReloj,
                  style: ElevatedButton.styleFrom(backgroundColor: isDark ? const Color(0xFF5A8BAE) : const Color(0xFF6EADD8), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  icon: _syncState.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white))) : const Icon(Icons.sync),
                  label: Text(_syncState.isLoading ? loc.statsBtnSincronizando : loc.statsBtnSincronizar),
                ),
                const SizedBox(height: 14),
                if (ConfigApi.mostrarDiagnosticoSalud) const HealthDebugPanel(),
                if (ConfigApi.mostrarDiagnosticoSalud) const SizedBox(height: 14),
                Text(loc.statsFasesSueno, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2A3F54))),
                const SizedBox(height: 6),
                _buildSleepDataSourceIndicator(estadoFases, isDark),
                const SizedBox(height: 10),
                _buildSleepPhasesTable(horasAwake, horasLight, horasDeep, horasRem, isDark, loc),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label, int index, bool isDark) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => setState(() => _filtroHistorial = index),
          style: ElevatedButton.styleFrom(
            backgroundColor: _filtroHistorial == index ? const Color(0xFF6EADD8) : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]),
            foregroundColor: _filtroHistorial == index ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            elevation: _filtroHistorial == index ? 4 : 0,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildUserSleepChart(List historial, bool isDark, AppLocalizations loc) {
    if (historial.isEmpty) return Center(child: Text(loc.statsSinDatosSueno, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)));
    final filteredData = _filtrarHistorial(historial, _filtroHistorial);
    if (filteredData.isEmpty) return Center(child: Text(loc.statsSinDatosPeriodo, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)));

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < filteredData.length; i++) {
      final double horas = double.tryParse(filteredData[i]['horas_dormidas'].toString()) ?? 0.0;
      barGroups.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: horas, color: const Color(0xFF6EADD8), width: 12)]));
    }

    return BarChart(BarChartData(
      barGroups: barGroups,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text(_getDateLabel(filteredData[value.toInt()]), style: TextStyle(fontSize: 9, color: isDark ? Colors.white70 : Colors.black87)))),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (value, meta) => Text('${value.toInt()}h', style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black87)))),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: true, horizontalInterval: 2, drawVerticalLine: false),
      borderData: FlBorderData(show: true, border: Border.all(color: isDark ? Colors.white24 : Colors.black12)),
    ));
  }

  List<dynamic> _filtrarHistorial(List historial, int filtro) {
    final now = DateTime.now();
    List<dynamic> filtered = [];
    for (var item in historial) {
      try {
        final fecha = DateTime.parse(item['fecha'] ?? '');
        final diff = now.difference(fecha).inDays;
        switch (filtro) {
          case 0: if (diff >= 0 && diff < 7) filtered.add(item); break;
          case 1: if (diff >= 0 && diff < 14) filtered.add(item); break;
          case 2: if (diff >= 0 && diff < 30) filtered.add(item); break;
        }
      } catch (e) { }
    }
    return filtered;
  }

  String _getDateLabel(dynamic registro) {
    try {
      final fecha = DateTime.parse(registro['fecha'] ?? '');
      return '${fecha.day}/${fecha.month}';
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildHeartRateChart(List<dynamic> blocks, dynamic sleepWindow, bool isDark, AppLocalizations loc) {
    if (blocks.isEmpty) {
      return Card(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(padding: const EdgeInsets.all(20.0), child: Center(child: Text(loc.statsSinPulso, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54), textAlign: TextAlign.center))),
      );
    }

    final lineSpots = <FlSpot>[];
    double minY = double.infinity, maxY = -double.infinity;

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final bpm = double.tryParse(block['bpm']?.toString() ?? '') ?? 0.0;
      if (bpm > 0) {
        lineSpots.add(FlSpot(i.toDouble(), bpm));
        if (bpm < minY) minY = bpm;
        if (bpm > maxY) maxY = bpm;
      }
    }
    
    if (lineSpots.isEmpty) return Container();
    
    final minGraph = (minY - 10).clamp(40, 200).toDouble();
    final maxGraph = (maxY + 20).clamp(80, 140).toDouble();

    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 12, 12, 8),
        child: LineChart(LineChartData(
          minX: 0, maxX: (lineSpots.length - 1).toDouble(), minY: minGraph, maxY: maxGraph,
          lineBarsData: [
            LineChartBarData(
              spots: lineSpots, isCurved: true, color: const Color(0xFF6EADD8), barWidth: 3, dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF6EADD8).withOpacity(0.18)),
            )
          ],
          titlesData: FlTitlesData(
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black87)))),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, horizontalInterval: 10, drawVerticalLine: false),
          borderData: FlBorderData(show: true, border: Border.all(color: isDark ? Colors.white24 : Colors.black12)),
        )),
      ),
    );
  }

  Widget _buildHeartRateTable(List<dynamic> blocks, dynamic sleepWindow, bool isDark, AppLocalizations loc) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final fontSize = isMobile ? 12.0 : 14.0;

    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
        child: Column(
          children: [
            Table(
              columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
              border: TableBorder.symmetric(inside: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
              children: [
                TableRow(children: [
                  Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(loc.statsTablaHora, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, fontSize: fontSize))),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(loc.statsTablaPulso, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, fontSize: fontSize))),
                ]),
                if (blocks.isEmpty)
                  TableRow(children: [
                    Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text('--:--', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: fontSize))),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text('-- bpm', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: fontSize))),
                  ])
                else
                  ...blocks.take(isMobile ? 3 : 5).map((block) {
                    final bpm = double.tryParse(block['bpm']?.toString() ?? '')?.round() ?? '--';
                    return TableRow(children: [
                      Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Text('N/A', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: fontSize))),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Text('$bpm bpm', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: fontSize))),
                    ]);
                  }),
              ],
            ),
            if (blocks.length > (isMobile ? 3 : 5))
              Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(loc.statsYMas((blocks.length - (isMobile ? 3 : 5)).toString()), style: TextStyle(fontSize: isMobile ? 10 : 12, color: isDark ? Colors.white54 : Colors.black54))),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepPhasesTable(double awake, double light, double deep, double rem, bool isDark, AppLocalizations loc) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final fontSize = isMobile ? 12.0 : 14.0;

    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
        child: Table(
          columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
          border: TableBorder.symmetric(inside: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
          children: [
            _buildRow(loc.statsDespierto, '${awake.toStringAsFixed(1)}h', isDark, fontSize),
            _buildRow(loc.statsSuenoLigero, '${light.toStringAsFixed(1)}h', isDark, fontSize),
            _buildRow(loc.statsSuenoProfundo, '${deep.toStringAsFixed(1)}h', isDark, fontSize),
            _buildRow(loc.statsRem, '${rem.toStringAsFixed(1)}h', isDark, fontSize),
          ],
        ),
      ),
    );
  }

  TableRow _buildRow(String label, String value, bool isDark, double fontSize) {
    return TableRow(children: [
      Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: fontSize))),
      Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87, fontSize: fontSize))),
    ]);
  }

  Map<String, double> _parseSleepPhasesFromBackend(List fasesRelojRaw) {
    final fases = {'awake': 0.0, 'light': 0.0, 'deep': 0.0, 'rem': 0.0};
    for (final item in fasesRelojRaw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final fase = map['fase']?.toString().toLowerCase();
      final horas = double.tryParse(map['horas']?.toString() ?? '0') ?? 0.0;
      if (fase != null && fases.containsKey(fase)) {
        fases[fase] = (fases[fase] ?? 0) + horas;
      }
    }
    return fases;
  }

  String _buildSleepSourceStatus({required bool backendTieneFases, required bool backendTieneDetalladas, required bool hayPulsaciones}) {
    if (backendTieneDetalladas) return 'Fuente: reloj/Health Connect (fases reales completas).';
    if (backendTieneFases) return 'Fuente: reloj con fases básicas; deep/rem pueden venir como 0.';
    if (hayPulsaciones) return 'Fuente: estimación por pulsaciones (fallback).';
    return 'Sin datos del reloj suficientes para fases de sueño.';
  }

  Widget _buildSleepDataSourceIndicator(String text, bool isDark) {
    final esFallback = text.toLowerCase().contains('fallback');
    final esCompleto = text.toLowerCase().contains('reales completas');

    final Color fondo = esCompleto ? const Color(0xFF2E7D32).withOpacity(0.12) : esFallback ? const Color(0xFFED6C02).withOpacity(0.12) : const Color(0xFF1976D2).withOpacity(0.12);
    final Color borde = esCompleto ? const Color(0xFF2E7D32) : esFallback ? const Color(0xFFED6C02) : const Color(0xFF1976D2);
    final IconData icono = esCompleto ? Icons.verified : esFallback ? Icons.info_outline : Icons.sensors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(10), border: Border.all(color: borde.withOpacity(0.5))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 16, color: borde),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87))),
        ],
      ),
    );
  }

  Widget _tarjetaEstadistica(String titulo, String valor, IconData icono, Color color, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icono, color: color)),
        title: Text(titulo, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white70 : Colors.black54)),
        subtitle: Text(valor, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      ),
    );
  }
}