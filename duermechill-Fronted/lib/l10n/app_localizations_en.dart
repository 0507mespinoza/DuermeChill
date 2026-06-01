// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DuermeChill';

  @override
  String get loginUsuario => 'Username:';

  @override
  String get loginPass => 'Password:';

  @override
  String get loginBtn => 'Login';

  @override
  String get loginRegisterBtn => 'Sign Up';

  @override
  String get errorCamposVacios => 'Please fill in all fields';

  @override
  String get errorCredenciales => 'Invalid username or password';

  @override
  String get registroTitulo => 'Sign Up';

  @override
  String get registroNombre => 'Name:';

  @override
  String get registroEdad => 'Age:';

  @override
  String get registroCorreo => 'Email:';

  @override
  String get registroAtras => 'Back';

  @override
  String get registroExito => 'User saved successfully!';

  @override
  String get drawerPremium => 'DuermeChill Premium';

  @override
  String get drawerEditarEncuesta => 'Edit data';

  @override
  String get drawerIdioma => 'Change Language';

  @override
  String get drawerTema => 'Dark Mode';

  @override
  String get drawerCerrar => 'Log Out';

  @override
  String get navYo => 'Me';

  @override
  String get navEstadisticas => 'Statistics';

  @override
  String get navRegistro => 'Record';

  @override
  String get navAlarmas => 'Alarms';

  @override
  String get navCoach => 'Coach';

  @override
  String get perfilTitulo => 'My Profile';

  @override
  String perfilHola(Object nombre) {
    return 'Hello, $nombre!';
  }

  @override
  String get perfilSubtitulo => 'Ready to improve your sleep today?';

  @override
  String get perfilDatosPersonales => 'Personal data';

  @override
  String get perfilEditarContrasena => 'Edit password';

  @override
  String get statsTitulo => 'Your sleep progress';

  @override
  String get statsFiltro7 => '7 days';

  @override
  String get statsFiltro14 => '14 days';

  @override
  String get statsFiltroMes => 'Month';

  @override
  String get statsUltimaNoche => 'Last recorded night';

  @override
  String get statsHoras => 'Hours slept';

  @override
  String get statsCalidad => 'Sleep quality';

  @override
  String get statsCansancio => 'Tiredness level';

  @override
  String get statsDespertares => 'Awakenings';

  @override
  String get statsSinDatos => 'No data';

  @override
  String get registroDatosTitulo => 'Data Record';

  @override
  String get registroDatosSubtitulo => 'Answer the questions honestly';

  @override
  String get regPregunta1 => 'How many hours did you sleep today?';

  @override
  String get regPregunta2 => 'How did you sleep?';

  @override
  String get regPregunta3 => 'How tired do you feel today?';

  @override
  String get regPregunta4 => 'How many times did you wake up at night?';

  @override
  String get btnGuardar => 'Save';

  @override
  String get btnCancelar => 'Cancel';

  @override
  String get alarmasTitulo => 'My Alarms';

  @override
  String get alarmasVacio => 'You have no scheduled alarms.\nTap the + button to create one.';

  @override
  String get alarmaActivada => 'Alarm activated';

  @override
  String get alarmaDesactivada => 'Alarm deactivated';

  @override
  String get alarmaEliminada => 'Alarm deleted';

  @override
  String get btnDeshacer => 'UNDO';

  @override
  String get coachTitulo => 'Coach AI';

  @override
  String get coachVacio => 'Start a new conversation with your Coach';

  @override
  String get coachEscribe => 'Type here...';

  @override
  String get coachConversaciones => 'Your Conversations';

  @override
  String get coachNueva => 'New conversation';

  @override
  String get encuestaSubtitulo => 'Can we know more about you?';

  @override
  String get encuestaQ1 => 'What do you expect from our app?';

  @override
  String get encuestaQ2 => 'How is your typical night?';

  @override
  String get encuestaQ3 => 'What time do you usually go to bed?';

  @override
  String get encuestaQ4 => 'How old are you?';

  @override
  String get encuestaModal1 => 'Expectations';

  @override
  String get encuestaModal2 => 'Your night';

  @override
  String get encuestaModal3 => 'Schedule';

  @override
  String get encuestaModal4 => 'Age';

  @override
  String get encuestaOpc1A => 'Fall asleep faster';

  @override
  String get encuestaOpc1B => 'Improve sleep quality';

  @override
  String get encuestaOpc1C => 'Regulate my life';

  @override
  String get encuestaOpc2A => 'I sleep quite well';

  @override
  String get encuestaOpc2B => 'Normal sleep';

  @override
  String get encuestaOpc2C => 'I don\'t sleep enough';

  @override
  String get encuestaOpc2D => 'I\'m not sure';

  @override
  String get encuestaOpc3A => '21:00 - 22:00';

  @override
  String get encuestaOpc3B => '22:00 - 23:00';

  @override
  String get encuestaOpc3C => '23:00 - 00:00';

  @override
  String get encuestaOpc3D => 'Later';

  @override
  String get encuestaOpc4A => '18-25';

  @override
  String get encuestaOpc4B => '26-40';

  @override
  String get encuestaOpc4C => '41-60';

  @override
  String get encuestaOpc4D => '+60';

  @override
  String get editarEncuestaTitulo => 'Edit survey data';

  @override
  String get editarEncuestaSeccionUsuario => 'User data';

  @override
  String get editarEncuestaSeccionPrimera => 'First survey';

  @override
  String get editarEncuestaNombre => 'Name';

  @override
  String get editarEncuestaCorreo => 'Email';

  @override
  String get editarEncuestaEdad => 'Age';

  @override
  String get editarEncuestaSeguridad => 'Security';

  @override
  String get editarEncuestaExpectativa => 'Expectation';

  @override
  String get editarEncuestaNoche => 'Night';

  @override
  String get editarEncuestaHora => 'Sleep time (HH:mm)';

  @override
  String get editarEncuestaEdadPrimera => 'Survey age';

  @override
  String get editarEncuestaGuardarCambios => 'Save changes';

  @override
  String get editarEncuestaGuardando => 'Saving...';

  @override
  String get editarEncuestaCampoObligatorio => 'This field is required';

  @override
  String get editarEncuestaErrorGuardar => 'Could not save. Please review your data and try again.';

  @override
  String get editarEncuestaExito => 'Data updated successfully.';

  @override
  String get editarContrasenaTitulo => 'Edit password';

  @override
  String get editarContrasenaActual => 'Current password';

  @override
  String get editarContrasenaNueva => 'New password';

  @override
  String get editarContrasenaConfirmar => 'Confirm new password';

  @override
  String get editarContrasenaGuardar => 'Save password';

  @override
  String get editarContrasenaGuardando => 'Saving...';

  @override
  String get editarContrasenaCampoObligatorio => 'This field is required';

  @override
  String get editarContrasenaMinima => 'Password must be at least 6 characters';

  @override
  String get editarContrasenaNoCoinciden => 'Passwords do not match';

  @override
  String get editarContrasenaError => 'Could not update password. Check your current password.';

  @override
  String get editarContrasenaExito => 'Password updated successfully.';

  @override
  String get statsSinDatosSueno => 'No sleep data recorded';

  @override
  String get statsSinDatosPeriodo => 'No data for this period';

  @override
  String get statsDatosReloj => 'Smartwatch data';

  @override
  String get statsSinPulso => 'No heart rate data.\nSync Google Fit.';

  @override
  String get statsDatosPulsaciones => 'Heart rate data';

  @override
  String get statsBtnSincronizar => 'Sync watch';

  @override
  String get statsBtnSincronizando => 'Syncing...';

  @override
  String get statsFasesSueno => 'Sleep phases';

  @override
  String get statsDespierto => 'Awake';

  @override
  String get statsSuenoLigero => 'Light sleep';

  @override
  String get statsSuenoProfundo => 'Deep sleep';

  @override
  String get statsRem => 'REM';

  @override
  String get statsTablaHora => 'Time';

  @override
  String get statsTablaPulso => 'Heart Rate';

  @override
  String statsYMas(Object cantidad) {
    return '... and $cantidad more';
  }
}
