import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'DuermeChill'**
  String get appTitle;

  /// No description provided for @loginUsuario.
  ///
  /// In en, this message translates to:
  /// **'Username:'**
  String get loginUsuario;

  /// No description provided for @loginPass.
  ///
  /// In en, this message translates to:
  /// **'Password:'**
  String get loginPass;

  /// No description provided for @loginBtn.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginBtn;

  /// No description provided for @loginRegisterBtn.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get loginRegisterBtn;

  /// No description provided for @errorCamposVacios.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get errorCamposVacios;

  /// No description provided for @errorCredenciales.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get errorCredenciales;

  /// No description provided for @registroTitulo.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registroTitulo;

  /// No description provided for @registroNombre.
  ///
  /// In en, this message translates to:
  /// **'Name:'**
  String get registroNombre;

  /// No description provided for @registroEdad.
  ///
  /// In en, this message translates to:
  /// **'Age:'**
  String get registroEdad;

  /// No description provided for @registroCorreo.
  ///
  /// In en, this message translates to:
  /// **'Email:'**
  String get registroCorreo;

  /// No description provided for @registroAtras.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get registroAtras;

  /// No description provided for @registroExito.
  ///
  /// In en, this message translates to:
  /// **'User saved successfully!'**
  String get registroExito;

  /// No description provided for @drawerPremium.
  ///
  /// In en, this message translates to:
  /// **'DuermeChill Premium'**
  String get drawerPremium;

  /// Drawer option to open user and survey edit screen
  ///
  /// In en, this message translates to:
  /// **'Edit data'**
  String get drawerEditarEncuesta;

  /// No description provided for @drawerIdioma.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get drawerIdioma;

  /// No description provided for @drawerTema.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get drawerTema;

  /// No description provided for @drawerCerrar.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get drawerCerrar;

  /// No description provided for @navYo.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navYo;

  /// No description provided for @navEstadisticas.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navEstadisticas;

  /// No description provided for @navRegistro.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get navRegistro;

  /// No description provided for @navAlarmas.
  ///
  /// In en, this message translates to:
  /// **'Alarms'**
  String get navAlarmas;

  /// No description provided for @navCoach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get navCoach;

  /// No description provided for @perfilTitulo.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get perfilTitulo;

  /// No description provided for @perfilHola.
  ///
  /// In en, this message translates to:
  /// **'Hello, {nombre}!'**
  String perfilHola(Object nombre);

  /// No description provided for @perfilSubtitulo.
  ///
  /// In en, this message translates to:
  /// **'Ready to improve your sleep today?'**
  String get perfilSubtitulo;

  /// Personal data section title in profile screen
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get perfilDatosPersonales;

  /// Option to navigate to password edit screen
  ///
  /// In en, this message translates to:
  /// **'Edit password'**
  String get perfilEditarContrasena;

  /// No description provided for @statsTitulo.
  ///
  /// In en, this message translates to:
  /// **'Your sleep progress'**
  String get statsTitulo;

  /// No description provided for @statsFiltro7.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get statsFiltro7;

  /// No description provided for @statsFiltro14.
  ///
  /// In en, this message translates to:
  /// **'14 days'**
  String get statsFiltro14;

  /// No description provided for @statsFiltroMes.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get statsFiltroMes;

  /// No description provided for @statsUltimaNoche.
  ///
  /// In en, this message translates to:
  /// **'Last recorded night'**
  String get statsUltimaNoche;

  /// No description provided for @statsHoras.
  ///
  /// In en, this message translates to:
  /// **'Hours slept'**
  String get statsHoras;

  /// No description provided for @statsCalidad.
  ///
  /// In en, this message translates to:
  /// **'Sleep quality'**
  String get statsCalidad;

  /// No description provided for @statsCansancio.
  ///
  /// In en, this message translates to:
  /// **'Tiredness level'**
  String get statsCansancio;

  /// No description provided for @statsDespertares.
  ///
  /// In en, this message translates to:
  /// **'Awakenings'**
  String get statsDespertares;

  /// No description provided for @statsSinDatos.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get statsSinDatos;

  /// No description provided for @registroDatosTitulo.
  ///
  /// In en, this message translates to:
  /// **'Data Record'**
  String get registroDatosTitulo;

  /// No description provided for @registroDatosSubtitulo.
  ///
  /// In en, this message translates to:
  /// **'Answer the questions honestly'**
  String get registroDatosSubtitulo;

  /// No description provided for @regPregunta1.
  ///
  /// In en, this message translates to:
  /// **'How many hours did you sleep today?'**
  String get regPregunta1;

  /// No description provided for @regPregunta2.
  ///
  /// In en, this message translates to:
  /// **'How did you sleep?'**
  String get regPregunta2;

  /// No description provided for @regPregunta3.
  ///
  /// In en, this message translates to:
  /// **'How tired do you feel today?'**
  String get regPregunta3;

  /// No description provided for @regPregunta4.
  ///
  /// In en, this message translates to:
  /// **'How many times did you wake up at night?'**
  String get regPregunta4;

  /// No description provided for @btnGuardar.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnGuardar;

  /// No description provided for @btnCancelar.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancelar;

  /// No description provided for @alarmasTitulo.
  ///
  /// In en, this message translates to:
  /// **'My Alarms'**
  String get alarmasTitulo;

  /// No description provided for @alarmasVacio.
  ///
  /// In en, this message translates to:
  /// **'You have no scheduled alarms.\nTap the + button to create one.'**
  String get alarmasVacio;

  /// No description provided for @alarmaActivada.
  ///
  /// In en, this message translates to:
  /// **'Alarm activated'**
  String get alarmaActivada;

  /// No description provided for @alarmaDesactivada.
  ///
  /// In en, this message translates to:
  /// **'Alarm deactivated'**
  String get alarmaDesactivada;

  /// No description provided for @alarmaEliminada.
  ///
  /// In en, this message translates to:
  /// **'Alarm deleted'**
  String get alarmaEliminada;

  /// No description provided for @btnDeshacer.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get btnDeshacer;

  /// No description provided for @coachTitulo.
  ///
  /// In en, this message translates to:
  /// **'Coach AI'**
  String get coachTitulo;

  /// No description provided for @coachVacio.
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation with your Coach'**
  String get coachVacio;

  /// No description provided for @coachEscribe.
  ///
  /// In en, this message translates to:
  /// **'Type here...'**
  String get coachEscribe;

  /// No description provided for @coachConversaciones.
  ///
  /// In en, this message translates to:
  /// **'Your Conversations'**
  String get coachConversaciones;

  /// No description provided for @coachNueva.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get coachNueva;

  /// No description provided for @encuestaSubtitulo.
  ///
  /// In en, this message translates to:
  /// **'Can we know more about you?'**
  String get encuestaSubtitulo;

  /// No description provided for @encuestaQ1.
  ///
  /// In en, this message translates to:
  /// **'What do you expect from our app?'**
  String get encuestaQ1;

  /// No description provided for @encuestaQ2.
  ///
  /// In en, this message translates to:
  /// **'How is your typical night?'**
  String get encuestaQ2;

  /// No description provided for @encuestaQ3.
  ///
  /// In en, this message translates to:
  /// **'What time do you usually go to bed?'**
  String get encuestaQ3;

  /// No description provided for @encuestaQ4.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get encuestaQ4;

  /// No description provided for @encuestaModal1.
  ///
  /// In en, this message translates to:
  /// **'Expectations'**
  String get encuestaModal1;

  /// No description provided for @encuestaModal2.
  ///
  /// In en, this message translates to:
  /// **'Your night'**
  String get encuestaModal2;

  /// No description provided for @encuestaModal3.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get encuestaModal3;

  /// No description provided for @encuestaModal4.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get encuestaModal4;

  /// No description provided for @encuestaOpc1A.
  ///
  /// In en, this message translates to:
  /// **'Fall asleep faster'**
  String get encuestaOpc1A;

  /// No description provided for @encuestaOpc1B.
  ///
  /// In en, this message translates to:
  /// **'Improve sleep quality'**
  String get encuestaOpc1B;

  /// No description provided for @encuestaOpc1C.
  ///
  /// In en, this message translates to:
  /// **'Regulate my life'**
  String get encuestaOpc1C;

  /// No description provided for @encuestaOpc2A.
  ///
  /// In en, this message translates to:
  /// **'I sleep quite well'**
  String get encuestaOpc2A;

  /// No description provided for @encuestaOpc2B.
  ///
  /// In en, this message translates to:
  /// **'Normal sleep'**
  String get encuestaOpc2B;

  /// No description provided for @encuestaOpc2C.
  ///
  /// In en, this message translates to:
  /// **'I don\'t sleep enough'**
  String get encuestaOpc2C;

  /// No description provided for @encuestaOpc2D.
  ///
  /// In en, this message translates to:
  /// **'I\'m not sure'**
  String get encuestaOpc2D;

  /// No description provided for @encuestaOpc3A.
  ///
  /// In en, this message translates to:
  /// **'21:00 - 22:00'**
  String get encuestaOpc3A;

  /// No description provided for @encuestaOpc3B.
  ///
  /// In en, this message translates to:
  /// **'22:00 - 23:00'**
  String get encuestaOpc3B;

  /// No description provided for @encuestaOpc3C.
  ///
  /// In en, this message translates to:
  /// **'23:00 - 00:00'**
  String get encuestaOpc3C;

  /// No description provided for @encuestaOpc3D.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get encuestaOpc3D;

  /// No description provided for @encuestaOpc4A.
  ///
  /// In en, this message translates to:
  /// **'18-25'**
  String get encuestaOpc4A;

  /// No description provided for @encuestaOpc4B.
  ///
  /// In en, this message translates to:
  /// **'26-40'**
  String get encuestaOpc4B;

  /// No description provided for @encuestaOpc4C.
  ///
  /// In en, this message translates to:
  /// **'41-60'**
  String get encuestaOpc4C;

  /// No description provided for @encuestaOpc4D.
  ///
  /// In en, this message translates to:
  /// **'+60'**
  String get encuestaOpc4D;

  /// Title of the survey edit screen
  ///
  /// In en, this message translates to:
  /// **'Edit survey data'**
  String get editarEncuestaTitulo;

  /// Header for user data section
  ///
  /// In en, this message translates to:
  /// **'User data'**
  String get editarEncuestaSeccionUsuario;

  /// Header for first survey section
  ///
  /// In en, this message translates to:
  /// **'First survey'**
  String get editarEncuestaSeccionPrimera;

  /// Label for name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editarEncuestaNombre;

  /// Label for email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get editarEncuestaCorreo;

  /// Label for age field
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get editarEncuestaEdad;

  /// Header for security actions inside edit data screen
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get editarEncuestaSeguridad;

  /// Label for survey expectation field
  ///
  /// In en, this message translates to:
  /// **'Expectation'**
  String get editarEncuestaExpectativa;

  /// Label for typical night field
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get editarEncuestaNoche;

  /// Label for sleep time field
  ///
  /// In en, this message translates to:
  /// **'Sleep time (HH:mm)'**
  String get editarEncuestaHora;

  /// Label for survey age field
  ///
  /// In en, this message translates to:
  /// **'Survey age'**
  String get editarEncuestaEdadPrimera;

  /// Text for save changes button
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editarEncuestaGuardarCambios;

  /// Text for button while saving
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get editarEncuestaGuardando;

  /// Validation message when a field is required
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get editarEncuestaCampoObligatorio;

  /// Message shown when save fails
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please review your data and try again.'**
  String get editarEncuestaErrorGuardar;

  /// Message shown when data is saved successfully
  ///
  /// In en, this message translates to:
  /// **'Data updated successfully.'**
  String get editarEncuestaExito;

  /// Password change screen title
  ///
  /// In en, this message translates to:
  /// **'Edit password'**
  String get editarContrasenaTitulo;

  /// Current password field label
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get editarContrasenaActual;

  /// New password field label
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get editarContrasenaNueva;

  /// Confirm new password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get editarContrasenaConfirmar;

  /// Save new password button text
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get editarContrasenaGuardar;

  /// Button text while saving password
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get editarContrasenaGuardando;

  /// Required field validation message
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get editarContrasenaCampoObligatorio;

  /// Minimum password length validation message
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get editarContrasenaMinima;

  /// Validation message when passwords do not match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get editarContrasenaNoCoinciden;

  /// Message shown when password update fails
  ///
  /// In en, this message translates to:
  /// **'Could not update password. Check your current password.'**
  String get editarContrasenaError;

  /// Message shown when password update succeeds
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get editarContrasenaExito;

  /// No description provided for @statsSinDatosSueno.
  ///
  /// In en, this message translates to:
  /// **'No sleep data recorded'**
  String get statsSinDatosSueno;

  /// No description provided for @statsSinDatosPeriodo.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get statsSinDatosPeriodo;

  /// No description provided for @statsDatosReloj.
  ///
  /// In en, this message translates to:
  /// **'Smartwatch data'**
  String get statsDatosReloj;

  /// No description provided for @statsSinPulso.
  ///
  /// In en, this message translates to:
  /// **'No heart rate data.\nSync Google Fit.'**
  String get statsSinPulso;

  /// No description provided for @statsDatosPulsaciones.
  ///
  /// In en, this message translates to:
  /// **'Heart rate data'**
  String get statsDatosPulsaciones;

  /// No description provided for @statsBtnSincronizar.
  ///
  /// In en, this message translates to:
  /// **'Sync watch'**
  String get statsBtnSincronizar;

  /// No description provided for @statsBtnSincronizando.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get statsBtnSincronizando;

  /// No description provided for @statsFasesSueno.
  ///
  /// In en, this message translates to:
  /// **'Sleep phases'**
  String get statsFasesSueno;

  /// No description provided for @statsDespierto.
  ///
  /// In en, this message translates to:
  /// **'Awake'**
  String get statsDespierto;

  /// No description provided for @statsSuenoLigero.
  ///
  /// In en, this message translates to:
  /// **'Light sleep'**
  String get statsSuenoLigero;

  /// No description provided for @statsSuenoProfundo.
  ///
  /// In en, this message translates to:
  /// **'Deep sleep'**
  String get statsSuenoProfundo;

  /// No description provided for @statsRem.
  ///
  /// In en, this message translates to:
  /// **'REM'**
  String get statsRem;

  /// No description provided for @statsTablaHora.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get statsTablaHora;

  /// No description provided for @statsTablaPulso.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get statsTablaPulso;

  /// No description provided for @statsYMas.
  ///
  /// In en, this message translates to:
  /// **'... and {cantidad} more'**
  String statsYMas(Object cantidad);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
