# 🛏️ DuermeChill

**Una aplicación inteligente para monitorear y optimizar tus hábitos de sueño**

DuermeChill es una plataforma completa que te ayuda a registrar, analizar y mejorar tus patrones de sueño mediante un Coach de IA personalizado que proporciona recomendaciones basadas en tus datos reales de sueño.

---

## 📋 Tabla de Contenidos

- [Características](#características)
- [Tecnologías](#tecnologías)
- [Requisitos Previos](#requisitos-previos)
- [Instalación](#instalación)
  - [Backend](#-backend)
  - [Frontend](#-frontend)
- [Ejecución Local](#ejecución-local)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [API Endpoints](#api-endpoints)
- [Configuración Base de Datos](#configuración-base-de-datos)
- [Contribución](#contribución)
- [Licencia](#licencia)

---

## ✨ Características

- 📊 **Registro de Datos de Sueño**: Registra tus patrones de sueño con detalles de pulsaciones y fases
- ⌚ **Sincronización con Dispositivos**: Conecta tu reloj inteligente para datos automáticos
- 🤖 **Coach de IA Personalizado**: Recibe recomendaciones inteligentes basadas en tus hábitos reales
- 📈 **Análisis Detallado**: Visualiza gráficas y estadísticas de tus últimos 30 días
- 👤 **Gestión de Perfil**: Edita tu información personal y controla tu cuenta
- 📱 **Multiplataforma**: Disponible en Android, iOS, Web, Windows y Linux

---

## 🛠️ Tecnologías

### Backend
- **Java 17** con **Spring Boot 4.0.5**
- **MySQL** para persistencia de datos
- **JDBC** para acceso a datos
- **RESTful API**

### Frontend
- **Flutter 3.10.1+** para desarrollo multiplataforma
- **Dart** como lenguaje de programación
- Soporte para Android, iOS, Web, Windows, Linux, macOS

---

## 📦 Requisitos Previos

### Requisitos Globales
- Git
- Editor de código (VS Code, IntelliJ IDEA, etc.)

### Para Backend
- **Java Development Kit (JDK) 17** o superior
- **Maven 3.8+** (incluido con el proyecto)
- **MySQL 8.0+**

### Para Frontend
- **Flutter SDK 3.10.1+** ([Descargar aquí](https://flutter.dev/docs/get-started/install))
- **Dart SDK** (incluido con Flutter)
- Para desarrollo en Android: **Android Studio** y **Android SDK**
- Para desarrollo en iOS: **Xcode** (solo macOS)

---

## 🚀 Instalación

### 📋 Clonar el Repositorio

```bash
git clone <repositorio-url>
cd DuermeChill
```

### 🔧 Backend

#### 1. Configurar Base de Datos MySQL

```bash
# Conectarse a MySQL
mysql -u root -p

# Crear base de datos
CREATE DATABASE duermechill_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Usar la base de datos
USE duermechill_db;

# Importar esquema (si existe archivo schema.sql)
SOURCE path/to/schema.sql;
```

#### 2. Configurar Propiedades de la Aplicación

Edita `duermechill-Backend/src/main/resources/application.properties`:

```properties
# Base de Datos
spring.datasource.url=jdbc:mysql://localhost:3306/duermechill_db
spring.datasource.username=root
spring.datasource.password=tu_contraseña_mysql
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# Configuración de Spring
spring.application.name=duermechill-backend
server.port=8080

# JPA/Hibernate
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect
spring.jpa.hibernate.ddl-auto=update
```

#### 3. Instalar Dependencias

```bash
cd duermechill-Backend

# En Windows
mvnw.cmd clean install

# En Linux/macOS
./mvnw clean install
```

### 💻 Frontend

#### 1. Instalar Dependencias

```bash
cd duermechill-Fronted

# Obtener dependencias
flutter pub get

# Actualizar dependencias
flutter pub upgrade
```

#### 2. Configurar la URL del Backend

Edita el archivo de configuración del servicio (generalmente en `lib/services/`) y asegúrate de que la URL del backend apunte a `http://localhost:8080`:

```dart
final String apiBaseUrl = 'http://localhost:8080';
```

#### 3. Conectar un Dispositivo o Emulador (Opcional)

```bash
# Ver dispositivos disponibles
flutter devices

# Ejecutar en un dispositivo específico
flutter run -d <device_id>
```

---

## 🏃 Ejecución Local

### ▶️ Ejecutar Backend

```bash
cd duermechill-Backend

# Opción 1: Usando Maven
mvnw.cmd spring-boot:run

# Opción 2: Usando Java directo
java -jar target/duermechill-0.0.1-SNAPSHOT.jar
```

**El backend estará disponible en**: `http://localhost:8080`

### ▶️ Ejecutar Frontend

#### En Android Emulator o Device

```bash
cd duermechill-Fronted

# Ejecutar en el dispositivo conectado
flutter run

# O especificar un dispositivo
flutter run -d emulator-5554
```

#### En Web

```bash
cd duermechill-Fronted

# Ejecutar en navegador web
flutter run -d chrome

# Para desarrollo con hot reload
flutter run -d web-server
```

#### En Windows/Linux

```bash
cd duermechill-Fronted

# Ejecutar en Windows
flutter run -d windows

# Ejecutar en Linux
flutter run -d linux
```

---

## 📁 Estructura del Proyecto

```
DuermeChill/
├── duermechill-Backend/          # Backend Java/Spring Boot
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/             # Código fuente Java
│   │   │   │   └── com/intermodular/...
│   │   │   └── resources/        # application.properties, schema.sql
│   │   └── test/
│   ├── pom.xml                   # Configuración Maven
│   ├── mvnw / mvnw.cmd           # Maven Wrapper
│   └── target/                   # Artefactos compilados
│
├── duermechill-Fronted/          # Frontend Flutter
│   ├── lib/
│   │   ├── main.dart             # Punto de entrada
│   │   ├── screens/              # Pantallas de la aplicación
│   │   ├── services/             # Servicios (API, datos)
│   │   ├── models/               # Modelos de datos
│   │   ├── widgets/              # Componentes reutilizables
│   │   └── l10n/                 # Internacionalización
│   ├── android/                  # Configuración Android
│   ├── ios/                      # Configuración iOS
│   ├── web/                      # Configuración Web
│   ├── windows/                  # Configuración Windows
│   ├── linux/                    # Configuración Linux
│   ├── pubspec.yaml              # Dependencias Flutter
│   └── build/                    # Artefactos compilados
│
└── CAMBIOS_REALIZADOS.md         # Registro de cambios
```

---

## 🔌 API Endpoints

### Base URL
```
http://localhost:8080/api
```

### Endpoints Principales

#### Reloj de Sueño
- **GET** `/reloj/{nombre}` - Obtener datos del reloj (últimos 30 días)
  ```json
  {
    "historial_reloj": [...],
    "ultimo_reloj": {...},
    "pulsaciones": {...},
    "fases_sueno": {...}
  }
  ```

- **POST** `/reloj` - Registrar datos del reloj
  ```json
  {
    "usuario_id": 1,
    "pulsaciones": 72,
    "fases_sueno": "REM",
    "fecha": "2024-05-10"
  }
  ```

#### Datos Diarios
- **GET** `/datos/{usuario_id}` - Obtener datos diarios
- **POST** `/datos` - Registrar datos diarios
- **PUT** `/datos/{id}` - Actualizar datos
- **DELETE** `/datos/{id}` - Eliminar datos

#### Usuario
- **GET** `/usuario/{id}` - Obtener información del usuario
- **PUT** `/usuario/{id}` - Actualizar perfil
- **DELETE** `/usuario/{id}` - Eliminar cuenta

#### Coach de IA
- **POST** `/coach/recomendacion` - Obtener recomendación personalizada

---

## 🗄️ Configuración Base de Datos

### Script de Inicialización (schema.sql)

El archivo `duermechill-Backend/src/main/resources/schema.sql` contiene las tablas necesarias:

```sql
-- Tabla de Usuarios
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Datos Diarios
CREATE TABLE datos_diarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    fecha DATE NOT NULL,
    horas_sueno FLOAT,
    calidad_sueno INT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Tabla de Reloj de Sueños
CREATE TABLE reloj_suenos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    fecha DATETIME,
    pulsaciones INT,
    fases_sueno VARCHAR(50),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);
```

---

## 🐛 Solución de Problemas

### Error: "Connection Refused" en localhost

```bash
# Verifica que MySQL está corriendo
# Windows
net start MySQL80

# Linux/macOS
brew services start mysql
```

### Error: "Port 8080 already in use"

```bash
# Cambiar puerto en application.properties
server.port=8081
```

### Error de Dependencias en Flutter

```bash
# Limpia y reinstala
flutter clean
flutter pub get
```

### Error: "Device not found"

```bash
# Lista dispositivos disponibles
flutter devices

# Si no hay emulador, crea uno desde Android Studio
```

---

## 📝 Notas de Desarrollo

### Hot Reload
Puedes hacer cambios en el código y verlos inmediatamente sin reiniciar:

```bash
# Durante `flutter run`, presiona 'r' para hot reload
# Presiona 'R' para hot restart
```

### Build Completo

```bash
# Limpiar y compilar desde cero
cd duermechill-Frontend
flutter clean
flutter pub get
flutter run

# Para Backend
cd duermechill-Backend
mvnw.cmd clean compile
mvnw.cmd package
```

---

## 🤝 Contribución

Las contribuciones son bienvenidas. Para contribuir:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Haz commit de tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### Reportar Bugs
Si encuentras un bug, por favor abre un issue con:
- Descripción clara del problema
- Pasos para reproducirlo
- Comportamiento esperado vs real
- Capturas de pantalla si aplica

---

## 📄 Licencia

Este proyecto está bajo licencia [MIT](LICENSE).

---

## 👥 Autores

Proyecto desarrollado por el equipo de **DuermeChill**.

---

## 📞 Soporte

Para preguntas o soporte, por favor contacta al equipo a través de:
- Email: support@duermechill.com
- Issues: GitHub Issues

---

## 🎯 Próximas Funcionalidades

- [ ] Integración con más dispositivos wearables
- [ ] Análisis de tendencias a largo plazo
- [ ] Exportar reportes en PDF
- [ ] Notificaciones push personalizadas
- [ ] Modo oscuro mejorado
- [ ] Sincronización en la nube

---

**Última actualización**: Mayo 2026

Hecho con ❤️ para mejor sueño
