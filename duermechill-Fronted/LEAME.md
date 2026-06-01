Markdown
# Proyecto DuermeChill

Hola Guillermo,

Aquí te dejamos el repositorio oficial de **DuermeChill**. Para que puedas evaluar y probar la aplicación en local sin problemas, hemos preparado esta guía paso a paso con las configuraciones necesarias.

El proyecto consta de dos partes:
1. **Backend:** Spring Boot (Java).
2. **Frontend:** Flutter (Web/Android).

---

## 🛠️ Requisitos Previos
- **Java JDK 17** o superior.
- **Flutter SDK** (versión estable).
- **MySQL Server** (Hemos usado XAMPP, pero es válido cualquier servidor local).

---

## 🗄️ 1. Base de Datos (MySQL)
Lo primero es levantar el servidor de base de datos para que el backend tenga dónde guardar la información.

1. Abre tu servidor MySQL.
2. Crea una base de datos vacía llamada exactamente `duermechill_db` (con soporte UTF-8 para emojis y caracteres especiales):
```sql
   CREATE DATABASE duermechill_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
Importa el archivo .sql que hemos dejado en el proyecto. Ahí están todas las tablas ya creadas y con datos de prueba reales para que no tengas que empezar de cero probando la app.

⚙️ 2. Conexión del Backend (Spring Boot)
Entra en la carpeta duermechill-Backend.

Abre el archivo src/main/resources/application.properties.

Comprueba que el usuario y la contraseña de tu MySQL coinciden con los que hay escritos (por defecto está configurado para root sin contraseña).

Arranca el servidor desde tu IDE o ejecutando desde la terminal:

Bash
   ./mvnw spring-boot:run
Verás que Tomcat se inicia y queda escuchando en el puerto 8080.

📱 3. Configuración del Frontend (Flutter) y Gemini IA
Para que la interfaz visual encuentre al backend y a la IA, revisa estos dos archivos:

Conexión al Servidor: En lib/services/config_api.dart, asegúrate de que la variable urlServidor apunta a http://localhost:8080/api si lo vas a probar en Chrome Web. (Si usas el emulador de Android Studio, pon 10.0.2.2:8080).

El Coach IA (Gemini): Para que el chat inteligente funcione, tenemos nuestra API Key en lib/screens/users/pantalla_coach.dart (variable _apiKey). Si Google la hubiese bloqueado automáticamente al detectar que este repositorio es público, habría que generar una nueva en Google AI Studio y pegarla ahí.

🚀 4. Lanzar la Aplicación (Modo Evaluación)
Para facilitarte la corrección y evitar los típicos bloqueos de seguridad del navegador (errores de CORS) al usar el inicio de sesión de Google o las peticiones a la IA, te recomendamos lanzar la versión Web con este comando directamente desde la terminal en la carpeta duermechill-Fronted:

Bash
flutter clean
flutter pub get
flutter run -d chrome --web-port 5000 --web-browser-flag "--disable-web-security"
(También puedes compilar e instalar el APK en un dispositivo físico con flutter run, asegurándote de poner la IP de tu Wi-Fi en config_api.dart).

🔑 5. Cuentas de Acceso para Pruebas
Para que puedas ver todas las vistas y gráficas directamente, sin necesidad de registrarte o pasar por el Login de Google, te dejamos estas dos cuentas ya preparadas en la base de datos con historiales generados:

Vista de Cliente (Usuario normal):

Usuario: gian@duermechill.com (o simplemente escribe gian)

Contraseña: 123
(Con esta cuenta podrás ver el historial de sueño, las gráficas de pulsaciones, crear alarmas y hablar con el Coach IA).

Vista de Administrador:

Usuario: admin@duermechill.com (o simplemente escribe admin)

Contraseña: admin

¡Esperamos que te guste el proyecto!