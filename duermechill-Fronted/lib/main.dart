import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:firebase_core/firebase_core.dart'; 
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:proyecto_intermodular/l10n/app_localizations.dart';
import 'package:alarm/alarm.dart'; 

import 'screens/pantalla_login.dart';
import 'screens/pantalla_principal.dart';
import 'screens/users/pantalla_encuesta.dart';
import 'services/auth_service.dart';
import 'services/config_api.dart'; 

void main() async {
  // 1. Asegurar que los widgets están listos antes de arrancar servicios externos
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inicializar Firebase dependiendo de si es Web o Android
  if (kIsWeb) {
    // Configuración específica para Web
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCuB5qyqwFN0i5lfDCwlq6x5-P1zNgipc8",
        appId: "1:298655901757:web:d610ca19a7f132d8172254",
        messagingSenderId: "298655901757",
        projectId: "proyectointermodular-536a5",
      ),
    );
  } else {
    // Configuración para Android 
    await Firebase.initializeApp();
  }

  // 3. Inicializar las alarmas ANTES de cargar los datos de la app
  if (!kIsWeb) {
    await Alarm.init();

    // Redirigimos el flujo nativo hacia nuestra emisora global
    try {
      Alarm.ringStream.stream.listen((alarmSettings) {
        ConfigApi.emisoraAlarmas.add(alarmSettings);
      });
    } catch (e) {
      debugPrint("El stream de alarmas ya estaba escuchándose: $e");
    }
  }

  // 4. Cargar configuración de la app
  ConfigApi.cargarDatosGenerales();
  
  // 5. Arrancar la interfaz
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios de idioma
    return ValueListenableBuilder<Locale>(
      valueListenable: ConfigApi.idiomaActual,
      builder: (context, localeValue, _) {
        // Escucha los cambios de tema oscuro
        return ValueListenableBuilder<bool>(
          valueListenable: ConfigApi.isDarkMode,
          builder: (context, isDark, child) {
            return MaterialApp(
              title: 'DuermeChill',
              debugShowCheckedModeBanner: false,
              locale: localeValue, // IDIOMA ACTIVO
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('es'),
                Locale('en'),
              ],
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              theme: ThemeData.light().copyWith(
                primaryColor: const Color(0xFF6EADD8),
                scaffoldBackgroundColor: Colors.white,
              ),
              darkTheme: ThemeData.dark().copyWith(
                primaryColor: const Color(0xFF6EADD8),
                scaffoldBackgroundColor: const Color(0xFF121212),
                cardColor: const Color(0xFF1E1E1E),
              ),
              home: const _BootstrapPantalla(),
            );
          },
        );
      }
    );
  }
}

class _BootstrapPantalla extends StatefulWidget {
  const _BootstrapPantalla();

  @override
  State<_BootstrapPantalla> createState() => _BootstrapPantallaState();
}

class _BootstrapPantallaState extends State<_BootstrapPantalla> {
  late Future<Widget> _destino;

  @override
  void initState() {
    super.initState();
    _destino = _resolverDestinoInicial();
  }

  Future<Widget> _resolverDestinoInicial() async {
    final sesionRestaurada = await AuthService.restaurarSesionLocal();
    if (!sesionRestaurada) return const PantallaLogin();
    return ConfigApi.debeMostrarOnboarding
        ? const PantallaEncuesta()
        : const PantallaPrincipal();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _destino,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF6EADD8)),
            ),
          );
        }
        return snapshot.data ?? const PantallaLogin();
      },
    );
  }
}