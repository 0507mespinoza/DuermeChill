# Proyecto DuermeChill

Hola Guillermo,

Aquí te dejamos el repositorio oficial de **DuermeChill**. Para que puedas evaluar y probar la aplicación en local sin problemas, hemos preparado esta guía paso a paso con las configuraciones necesarias.

Como la app depende de una base de datos y de un asistente de IA, hay un par de cosillas que configurar tras descargar el código:

## Requisitos Previos
- **Java JDK 17** o superior.
- **Flutter SDK** (versión estable).
- **MySQL Server** (Nosotros hemos usado XAMPP, pero vale cualquiera o Docker).

## 1. Base de Datos (MySQL)
Lo primero es tener el servidor de MySQL encendido en tu equipo.
1. Crea una base de datos vacía llamada `duermechill`.
2. Importa el archivo `duermechill.sql` que hemos dejado en la raíz del proyecto. Ahí están todas las tablas ya creadas y con algunos datos de prueba para que no tengas que empezar de cero.

## ⚙️ 2. Conexión del Backend (Spring Boot)
1. Entra en la carpeta `duermechill-Backend`.
2. Abre el archivo `src/main/resources/application.properties`.
3. Comprueba que el usuario y la contraseña de tu MySQL coinciden con los que hay escritos (por defecto lo hemos dejado en `root` y sin contraseña).
4. Una vez revisado, arranca el servidor con `./mvnw spring-boot:run` (o directamente dándole al "Play" en tu IDE). Verás que se activa en el puerto **8080**.

## 3. Configuración del Frontend (Flutter)
Aquí es donde hay que tener cuidado con las IPs para que todo conecte bien:

* **La IP del Servidor:** Ve a `lib/services/config_api.dart`. Asegúrate de que la variable `urlServidor` apunta a `http://localhost:8080/api` para probarlo en el navegador Chrome. *(Si fueses a usar un emulador de Android, habría que cambiarlo a `10.0.2.2:8080`)*.
* **El Coach IA (Gemini):** Para que el chat de IA funcione, hemos dejado puesta nuestra API Key en `lib/screens/users/pantalla_coach.dart` (en la variable `_apiKey`). Si por algún motivo Google la hubiese bloqueado al detectar que el repositorio es público, habría que generar una nueva en Google AI Studio y sustituirla ahí.

## 🚀 4. Lanzar la Aplicación
Para evitar los típicos problemas de seguridad del navegador (errores de CORS) con el inicio de sesión de Google y las peticiones a la IA, te recomendamos lanzar la web con este comando directamente desde la terminal en la carpeta `duermechill-Fronted`:

```bash
flutter clean
flutter pub get
flutter run -d chrome --web-port 5000 --web-browser-flag "--disable-web-security"

 5. Cuentas de Acceso para Pruebas
Para facilitarte la corrección y que puedas ver todas las vistas directamente sin tener que registrarte (aunque puedes hacerlo si quieres probar el registro o el login de Google), te dejamos estas dos cuentas ya creadas en la base de datos:

Vista de Cliente (Usuario normal):

Usuario: Gian

Contraseña: 123

(Con esta cuenta podrás ver el historial, las gráficas, crear alarmas y hablar con el Coach IA).

Vista de Administrador:

Usuario: admin

Contraseña: admin