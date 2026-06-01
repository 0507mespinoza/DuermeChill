// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'DuermeChill';

  @override
  String get loginUsuario => 'Usuario:';

  @override
  String get loginPass => 'Contraseña:';

  @override
  String get loginBtn => 'Iniciar sesión';

  @override
  String get loginRegisterBtn => 'Registrarse';

  @override
  String get errorCamposVacios => 'Por favor, rellena todos los campos';

  @override
  String get errorCredenciales => 'Usuario o contraseña incorrectos';

  @override
  String get registroTitulo => 'Registro';

  @override
  String get registroNombre => 'Nombre:';

  @override
  String get registroEdad => 'Edad:';

  @override
  String get registroCorreo => 'Correo:';

  @override
  String get registroAtras => 'Atrás';

  @override
  String get registroExito => '¡Usuario guardado correctamente!';

  @override
  String get drawerPremium => 'DuermeChill Premium';

  @override
  String get drawerEditarEncuesta => 'Editar datos';

  @override
  String get drawerIdioma => 'Cambiar Idioma';

  @override
  String get drawerTema => 'Modo Oscuro';

  @override
  String get drawerCerrar => 'Cerrar Sesión';

  @override
  String get navYo => 'Yo';

  @override
  String get navEstadisticas => 'Estadísticas';

  @override
  String get navRegistro => 'Registro';

  @override
  String get navAlarmas => 'Alarmas';

  @override
  String get navCoach => 'Coach';

  @override
  String get perfilTitulo => 'Mi Perfil';

  @override
  String perfilHola(Object nombre) {
    return '¡Hola, $nombre!';
  }

  @override
  String get perfilSubtitulo => '¿Listo para mejorar tu sueño hoy?';

  @override
  String get perfilDatosPersonales => 'Datos personales';

  @override
  String get perfilEditarContrasena => 'Editar contraseña';

  @override
  String get statsTitulo => 'Tu progreso de sueño';

  @override
  String get statsFiltro7 => '7 días';

  @override
  String get statsFiltro14 => '14 días';

  @override
  String get statsFiltroMes => 'Mes';

  @override
  String get statsUltimaNoche => 'Última noche registrada';

  @override
  String get statsHoras => 'Horas dormidas';

  @override
  String get statsCalidad => 'Calidad del sueño';

  @override
  String get statsCansancio => 'Nivel de cansancio';

  @override
  String get statsDespertares => 'Despertares';

  @override
  String get statsSinDatos => 'Sin datos';

  @override
  String get registroDatosTitulo => 'Registro de datos';

  @override
  String get registroDatosSubtitulo => 'Responde las preguntas con total sinceridad';

  @override
  String get regPregunta1 => '¿Cuántas horas has dormido hoy?';

  @override
  String get regPregunta2 => '¿Cómo has dormido?';

  @override
  String get regPregunta3 => '¿Qué tan cansado te sientes hoy?';

  @override
  String get regPregunta4 => '¿Cuántas veces te despertaste por la noche?';

  @override
  String get btnGuardar => 'Guardar';

  @override
  String get btnCancelar => 'Cancelar';

  @override
  String get alarmasTitulo => 'Mis Alarmas';

  @override
  String get alarmasVacio => 'No tienes alarmas programadas.\nToca el botón + para crear una.';

  @override
  String get alarmaActivada => 'Alarma activada';

  @override
  String get alarmaDesactivada => 'Alarma desactivada';

  @override
  String get alarmaEliminada => 'Alarma eliminada';

  @override
  String get btnDeshacer => 'DESHACER';

  @override
  String get coachTitulo => 'Coach AI';

  @override
  String get coachVacio => 'Inicia una nueva conversación con tu Coach';

  @override
  String get coachEscribe => 'Escribe aquí...';

  @override
  String get coachConversaciones => 'Tus Conversaciones';

  @override
  String get coachNueva => 'Nueva conversación';

  @override
  String get encuestaSubtitulo => '¿Podemos saber más sobre ti?';

  @override
  String get encuestaQ1 => '¿Qué esperas de nuestra aplicación?';

  @override
  String get encuestaQ2 => '¿Cómo es tu noche típica?';

  @override
  String get encuestaQ3 => '¿A qué hora te sueles ir a la cama?';

  @override
  String get encuestaQ4 => '¿Qué edad tienes?';

  @override
  String get encuestaModal1 => 'Expectativas';

  @override
  String get encuestaModal2 => 'Tu noche';

  @override
  String get encuestaModal3 => 'Horario';

  @override
  String get encuestaModal4 => 'Edad';

  @override
  String get encuestaOpc1A => 'Dormirme más rápido';

  @override
  String get encuestaOpc1B => 'Mejorar calidad del sueño';

  @override
  String get encuestaOpc1C => 'Regular mi vida';

  @override
  String get encuestaOpc2A => 'Duermo bastante bien';

  @override
  String get encuestaOpc2B => 'Sueño normal';

  @override
  String get encuestaOpc2C => 'No duermo lo suficiente';

  @override
  String get encuestaOpc2D => 'No estoy seguro';

  @override
  String get encuestaOpc3A => '21:00 - 22:00';

  @override
  String get encuestaOpc3B => '22:00 - 23:00';

  @override
  String get encuestaOpc3C => '23:00 - 00:00';

  @override
  String get encuestaOpc3D => 'Más tarde';

  @override
  String get encuestaOpc4A => '18-25';

  @override
  String get encuestaOpc4B => '26-40';

  @override
  String get encuestaOpc4C => '41-60';

  @override
  String get encuestaOpc4D => '+60';

  @override
  String get editarEncuestaTitulo => 'Editar datos de la encuesta';

  @override
  String get editarEncuestaSeccionUsuario => 'Datos del usuario';

  @override
  String get editarEncuestaSeccionPrimera => 'Primera encuesta';

  @override
  String get editarEncuestaNombre => 'Nombre';

  @override
  String get editarEncuestaCorreo => 'Correo';

  @override
  String get editarEncuestaEdad => 'Edad';

  @override
  String get editarEncuestaSeguridad => 'Seguridad';

  @override
  String get editarEncuestaExpectativa => 'Expectativa';

  @override
  String get editarEncuestaNoche => 'Noche';

  @override
  String get editarEncuestaHora => 'Hora de sueño (HH:mm)';

  @override
  String get editarEncuestaEdadPrimera => 'Edad de encuesta';

  @override
  String get editarEncuestaGuardarCambios => 'Guardar cambios';

  @override
  String get editarEncuestaGuardando => 'Guardando...';

  @override
  String get editarEncuestaCampoObligatorio => 'Este campo es obligatorio';

  @override
  String get editarEncuestaErrorGuardar => 'No se pudo guardar. Revisa los datos e inténtalo de nuevo.';

  @override
  String get editarEncuestaExito => 'Datos actualizados correctamente.';

  @override
  String get editarContrasenaTitulo => 'Editar contraseña';

  @override
  String get editarContrasenaActual => 'Contraseña actual';

  @override
  String get editarContrasenaNueva => 'Nueva contraseña';

  @override
  String get editarContrasenaConfirmar => 'Confirmar nueva contraseña';

  @override
  String get editarContrasenaGuardar => 'Guardar contraseña';

  @override
  String get editarContrasenaGuardando => 'Guardando...';

  @override
  String get editarContrasenaCampoObligatorio => 'Este campo es obligatorio';

  @override
  String get editarContrasenaMinima => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get editarContrasenaNoCoinciden => 'Las contraseñas no coinciden';

  @override
  String get editarContrasenaError => 'No se pudo actualizar la contraseña. Revisa tu contraseña actual.';

  @override
  String get editarContrasenaExito => 'Contraseña actualizada correctamente.';

  @override
  String get statsSinDatosSueno => 'Sin datos de sueño registrados';

  @override
  String get statsSinDatosPeriodo => 'Sin datos para este período';

  @override
  String get statsDatosReloj => 'Datos del reloj inteligente';

  @override
  String get statsSinPulso => 'Sin datos de pulso.\nSincroniza Google Fit.';

  @override
  String get statsDatosPulsaciones => 'Datos de pulsaciones';

  @override
  String get statsBtnSincronizar => 'Sincronizar reloj';

  @override
  String get statsBtnSincronizando => 'Sincronizando...';

  @override
  String get statsFasesSueno => 'Fases del sueño';

  @override
  String get statsDespierto => 'Despierto';

  @override
  String get statsSuenoLigero => 'Sueño ligero';

  @override
  String get statsSuenoProfundo => 'Sueño profundo';

  @override
  String get statsRem => 'REM';

  @override
  String get statsTablaHora => 'Hora';

  @override
  String get statsTablaPulso => 'Pulsaciones';

  @override
  String statsYMas(Object cantidad) {
    return '... y $cantidad más';
  }
}
