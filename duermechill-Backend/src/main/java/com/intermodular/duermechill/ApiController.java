package com.intermodular.duermechill;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.*;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*") // Permite que Flutter se conecte sin bloqueos
public class ApiController {

    private static final Logger log = LoggerFactory.getLogger(ApiController.class);
    private static final ZoneId ZONE_ID = ZoneId.of("Europe/Madrid");

    @Autowired
    private JdbcTemplate db; // Herramienta para ejecutar SQL

    // 1. Registro de usuario
    @PostMapping("/registro")
    public ResponseEntity<?> registro(@RequestBody Map<String, Object> body) {
        try {
            String sql = "INSERT INTO usuarios (nombre, correo, edad, contrasena) VALUES (?, ?, ?, ?)";
            db.update(sql, body.get("nombre"), body.get("correo"), body.get("edad"), body.get("contrasena"));
            return ResponseEntity.ok(Map.of("mensaje", "Usuario registrado"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Error al registrar el usuario"));
        }
    }

    // 2. Login de usuario
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, Object> body) {
        String sql = "SELECT * FROM usuarios WHERE nombre = ? AND contrasena = ?";
        List<Map<String, Object>> users = db.queryForList(sql, body.get("nombre"), body.get("contrasena"));
        
        if (!users.isEmpty()) {
            Map<String, Object> usuario = new HashMap<>(users.get(0));
            
            Object valorEncuesta = usuario.get("encuesta_completada");
            boolean completada = false;
            if (valorEncuesta instanceof Boolean) completada = (Boolean) valorEncuesta;
            else if (valorEncuesta instanceof Number) completada = ((Number) valorEncuesta).intValue() == 1;

            String sleepStartTime = null;
            List<Map<String, Object>> encuesta = db.queryForList(
                "SELECT hora FROM encuestas WHERE usuario_id = ? ORDER BY id DESC LIMIT 1",
                usuario.get("id")
            );
            if (!encuesta.isEmpty() && encuesta.get(0).get("hora") != null) {
                sleepStartTime = encuesta.get(0).get("hora").toString();
            }

            boolean onboardingCompleted = completada || (sleepStartTime != null && !sleepStartTime.isBlank());
            boolean isAdmin = "admin".equalsIgnoreCase(Objects.toString(usuario.get("nombre"), ""));
            usuario.put("encuesta_completada", onboardingCompleted);
            usuario.put("onboarding_completed", onboardingCompleted);
            usuario.put("sleep_start_time", sleepStartTime);
            usuario.put("is_admin", isAdmin);

            return ResponseEntity.ok(Map.of("mensaje", "Login exitoso", "usuario", usuario));
        } else {
            return ResponseEntity.status(401).body(Map.of("error", "Usuario o contraseña incorrectos"));
        }
    }

    // 3. Guardar encuesta inicial
    @PostMapping("/encuesta")
    public ResponseEntity<?> guardarEncuesta(@RequestBody Map<String, Object> body) {
        String sqlBusqueda = "SELECT id FROM usuarios WHERE nombre = ?";
        List<Map<String, Object>> users = db.queryForList(sqlBusqueda, body.get("nombre"));
        
        if (users.isEmpty()) return ResponseEntity.status(404).body(Map.of("error", "Usuario no encontrado"));
        
        Long userId = ((Number) users.get(0).get("id")).longValue();

        Object horaBody = body.get("sleep_start_time");
        if (horaBody == null || horaBody.toString().isBlank()) {
            horaBody = body.get("hora");
        }

        try {
            db.update("DELETE FROM encuestas WHERE usuario_id = ?", userId);

            Integer edadEncuesta = parseEdadEncuesta(body.get("edad"));
            String expectativa = normalizeTextForDb(body.get("expectativa"));
            String noche = normalizeTextForDb(body.get("noche"));
            String horaNormalizada = normalizeTextForDb(horaBody);

            String sqlInsert = "INSERT INTO encuestas (usuario_id, expectativa, noche, hora, edad_encuesta) VALUES (?, ?, ?, ?, ?)";
            db.update(sqlInsert, userId, expectativa, noche, horaNormalizada, edadEncuesta);

            String sqlUpdate = "UPDATE usuarios SET encuesta_completada = TRUE WHERE id = ?";
            db.update(sqlUpdate, userId);

            return ResponseEntity.ok(Map.of(
                "mensaje", "Encuesta guardada",
                "onboarding_completed", true,
                "sleep_start_time", horaNormalizada
            ));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Error al guardar encuesta"));
        }
    }

    private Integer parseEdadEncuesta(Object edadRaw) {
        if (edadRaw == null) return null;
        if (edadRaw instanceof Number) return ((Number) edadRaw).intValue();

        String texto = edadRaw.toString().trim();
        if (texto.isEmpty()) return null;

        // Acepta formatos como "18", "18-25" o "+60" y toma el primer número.
        String soloNumeros = texto.replaceAll("[^0-9]", " ").trim();
        if (soloNumeros.isEmpty()) return null;

        String primerNumero = soloNumeros.split("\\s+")[0];
        try {
            return Integer.parseInt(primerNumero);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String normalizeTextForDb(Object value) {
        if (value == null) return null;
        String text = value.toString().trim();
        if (text.isEmpty()) return null;
        // Solo eliminar caracteres de control y recortar espacios. Se preservan acentos y ñ.
        String cleaned = text.replaceAll("[\\p{Cc}\\p{Cf}]+", " ").trim();
        return cleaned.isEmpty() ? null : cleaned;
    }

    // 4. Guardar registro diario de sueño
    @PostMapping("/registro_diario")
    public ResponseEntity<?> registroDiario(@RequestBody Map<String, Object> body) {
        List<Map<String, Object>> users = db.queryForList("SELECT id FROM usuarios WHERE nombre = ?", body.get("nombre"));
        if (users.isEmpty()) return ResponseEntity.status(404).body(Map.of("error", "Usuario no encontrado"));
        
        Long userId = ((Number) users.get(0).get("id")).longValue();
        String fecha = LocalDate.now(ZONE_ID).toString();
        
        String sql = "INSERT INTO registros_diarios (usuario_id, fecha, horas_dormidas, como_dormido, cansado, despertares) VALUES (?, ?, ?, ?, ?, ?)";
        db.update(sql, userId, fecha, body.get("horas_dormidas"), body.get("como_dormido"), body.get("cansado"), body.get("despertares"));
        
        return ResponseEntity.ok(Map.of("mensaje", "Registro guardado"));
    }

    // 5. Guardar alarmas
    @PostMapping("/alarmas")
    @SuppressWarnings("unchecked")
    public ResponseEntity<?> guardarAlarmas(@RequestBody Map<String, Object> body) {
        List<Map<String, Object>> users = db.queryForList("SELECT id FROM usuarios WHERE nombre = ?", body.get("nombre"));
        if (users.isEmpty()) return ResponseEntity.status(404).body(Map.of("error", "Usuario no encontrado"));
        
        Long userId = ((Number) users.get(0).get("id")).longValue();
        
        db.update("DELETE FROM alarmas WHERE usuario_id = ?", userId);
        
        Object alarmasObj = body.get("alarmas");
        if (alarmasObj == null) {
            return ResponseEntity.ok(Map.of("mensaje", "Alarmas guardadas (lista vacía)"));
        }
        List<Map<String, Object>> alarmas = (List<Map<String, Object>>) alarmasObj;
        for (Map<String, Object> a : alarmas) {
            db.update("INSERT INTO alarmas (usuario_id, hora, activada) VALUES (?, ?, ?)", userId, a.get("hora"), a.get("activada"));
        }
        
        return ResponseEntity.ok(Map.of("mensaje", "Alarmas guardadas"));
    }

    // 6. Obtener datos de usuario (Gráficas, Alarmas y Encuesta)
    @GetMapping("/usuario/{nombre}")
    public ResponseEntity<?> getDatosUsuario(@PathVariable String nombre) {
        List<Map<String, Object>> users = db.queryForList("SELECT id FROM usuarios WHERE nombre = ?", nombre);
        if (users.isEmpty()) return ResponseEntity.status(404).body(Map.of("error", "Usuario no encontrado"));
        
        Long userId = ((Number) users.get(0).get("id")).longValue();
        
        List<Map<String, Object>> registros = db.queryForList("SELECT * FROM registros_diarios WHERE usuario_id = ? ORDER BY fecha ASC", userId);
        List<Map<String, Object>> alarmas = db.queryForList("SELECT hora, activada FROM alarmas WHERE usuario_id = ?", userId);
        List<Map<String, Object>> encuestas = db.queryForList("SELECT expectativa, noche, hora, edad_encuesta FROM encuestas WHERE usuario_id = ? ORDER BY id DESC LIMIT 1", userId);
        List<Map<String, Object>> perfilRows = db.queryForList("SELECT nombre, correo, edad FROM usuarios WHERE id = ?", userId);
        
        for (Map<String, Object> a : alarmas) {
            Object val = a.get("activada");
            boolean isActivada = false;
            if (val instanceof Boolean) isActivada = (Boolean) val;
            else if (val instanceof Number) isActivada = ((Number) val).intValue() == 1;
            a.put("activada", isActivada);
        }

        Map<String, Object> resultado = new HashMap<>();
        String sleepStartTime = null;
        if (!encuestas.isEmpty() && encuestas.get(0).get("hora") != null) {
            sleepStartTime = encuestas.get(0).get("hora").toString();
        }

        boolean onboardingCompleted = sleepStartTime != null && !sleepStartTime.isBlank();
        resultado.put("historial_registros", registros);
        resultado.put("alarmas", alarmas);
        resultado.put("encuesta", encuestas.isEmpty() ? null : encuestas.get(0));
        resultado.put("perfil", perfilRows.isEmpty() ? null : perfilRows.get(0));
        resultado.put("sleep_start_time", sleepStartTime);
        resultado.put("onboarding_completed", onboardingCompleted);
        return ResponseEntity.ok(resultado);
    }

    @PutMapping("/usuario/{nombreActual}")
    public ResponseEntity<?> actualizarDatosUsuario(
            @PathVariable String nombreActual,
            @RequestBody Map<String, Object> body
    ) {
        List<Map<String, Object>> users = db.queryForList("SELECT id FROM usuarios WHERE nombre = ?", nombreActual);
        if (users.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Usuario no encontrado"));
        }

        Long userId = ((Number) users.get(0).get("id")).longValue();

        String nuevoNombre = Objects.toString(body.get("nombre"), "").trim();
        String correo = Objects.toString(body.get("correo"), "").trim();
        Integer edad = parseNullableInt(body.get("edad"));

        if (nuevoNombre.isBlank() || correo.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Nombre y correo son obligatorios"));
        }

        List<Map<String, Object>> nombreEnUso = db.queryForList(
                "SELECT id FROM usuarios WHERE nombre = ? AND id <> ?",
                nuevoNombre,
                userId
        );
        if (!nombreEnUso.isEmpty()) {
            return ResponseEntity.status(409).body(Map.of("error", "El nombre de usuario ya existe"));
        }

        try {
            db.update(
                    "UPDATE usuarios SET nombre = ?, correo = ?, edad = ? WHERE id = ?",
                    nuevoNombre,
                    correo,
                    edad,
                    userId
            );

            Map<String, Object> response = new HashMap<>();
            response.put("mensaje", "Usuario actualizado");
            response.put("nombre", nuevoNombre);
            response.put("correo", correo);
            response.put("edad", edad);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "No se pudo actualizar el usuario"));
        }
    }

    @PutMapping("/usuario/{nombre}/contrasena")
    public ResponseEntity<?> actualizarContrasenaUsuario(
            @PathVariable String nombre,
            @RequestBody Map<String, Object> body
    ) {
        String contrasenaActual = Objects.toString(body.get("contrasena_actual"), "").trim();
        String contrasenaNueva = Objects.toString(body.get("contrasena_nueva"), "").trim();

        if (contrasenaActual.isBlank() || contrasenaNueva.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Las contraseñas son obligatorias"));
        }

        List<Map<String, Object>> users = db.queryForList(
                "SELECT id FROM usuarios WHERE nombre = ? AND contrasena = ?",
                nombre,
                contrasenaActual
        );
        if (users.isEmpty()) {
            return ResponseEntity.status(401).body(Map.of("error", "Contraseña actual incorrecta"));
        }

        Long userId = ((Number) users.get(0).get("id")).longValue();

        try {
            db.update("UPDATE usuarios SET contrasena = ? WHERE id = ?", contrasenaNueva, userId);
            return ResponseEntity.ok(Map.of("mensaje", "Contraseña actualizada"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "No se pudo actualizar la contraseña"));
        }
    }

    private Integer parseNullableInt(Object raw) {
        if (raw == null) return null;
        if (raw instanceof Number) return ((Number) raw).intValue();

        String text = raw.toString().trim();
        if (text.isEmpty()) return null;

        try {
            return Integer.parseInt(text);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // 7. Guardar datos de reloj inteligente (pulsaciones + fases de sueño)
    @PostMapping("/reloj/ingestar")
    @SuppressWarnings("unchecked")
    public ResponseEntity<?> ingestarDatosReloj(@RequestBody Map<String, Object> body) {
        String nombre = body.get("nombre") != null ? body.get("nombre").toString().trim() : null;
        if (nombre == null || nombre.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "El campo 'nombre' es obligatorio"));
        }

        List<Map<String, Object>> users = db.queryForList("SELECT id FROM usuarios WHERE nombre = ?", nombre);
        if (users.isEmpty()) return ResponseEntity.status(404).body(Map.of("error", "Usuario no encontrado"));

        Long userId = ((Number) users.get(0).get("id")).longValue();
        String fecha = body.getOrDefault("fecha", LocalDate.now(ZONE_ID).toString()).toString();

        List<Map<String, Object>> pulsacionesRaw = (List<Map<String, Object>>) body.getOrDefault("pulsaciones", List.of());
        List<Map<String, Object>> fasesSueno = (List<Map<String, Object>>) body.getOrDefault("fases_sueno", List.of());

        // Validate and filter BPM range 30-220 and minuto range 0-1440
        List<Map<String, Object>> pulsaciones = new ArrayList<>();
        for (Map<String, Object> p : pulsacionesRaw) {
            int valor = toInt(p.getOrDefault("valor", 0));
            int minuto = toInt(p.getOrDefault("minuto", 0));
            if (valor < 30 || valor > 220) {
                log.debug("BPM fuera de rango descartado: valor={}, minuto={}", valor, minuto);
                continue;
            }
            if (minuto < 0 || minuto > 1440) {
                log.debug("Minuto fuera de rango descartado: minuto={}", minuto);
                continue;
            }
            pulsaciones.add(p);
        }

        log.info("ingestarDatosReloj: usuario={}, fecha={}, pulsaciones={}, fases={}",
                nombre, fecha, pulsaciones.size(), fasesSueno.size());

        return guardarDatosReloj(userId, fecha, pulsaciones, fasesSueno);
    }

    // 8. Obtener datos de reloj guardados (historial completo)
    @GetMapping("/reloj/{nombre}")
    public ResponseEntity<?> obtenerDatosReloj(@PathVariable String nombre) {
        List<Map<String, Object>> users = db.queryForList("SELECT id FROM usuarios WHERE nombre = ?", nombre);
        if (users.isEmpty()) return ResponseEntity.status(404).body(Map.of("error", "Usuario no encontrado"));

        Long userId = ((Number) users.get(0).get("id")).longValue();
        // Obtener todos los registros del reloj ordenados por fecha (últimos 30 días)
        List<Map<String, Object>> historialReloj = db.queryForList("SELECT fecha, total_horas, horas_awake, horas_light, horas_deep, horas_rem FROM reloj_suenos WHERE usuario_id = ? AND fecha >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) ORDER BY fecha ASC", userId);

        if (historialReloj.isEmpty()) {
            return ResponseEntity.ok(Map.of("historial_reloj", List.of(), "ultimo_reloj", Map.of("total_horas", 0, "horas_awake", 0, "horas_light", 0, "horas_deep", 0, "horas_rem", 0), "pulsaciones", List.of(), "fases_sueno", List.of()));
        }

        Map<String, Object> ultimoDato = historialReloj.get(historialReloj.size() - 1);
        String fechaUltima = ultimoDato.get("fecha").toString();

        List<Map<String, Object>> pulsaciones = db.queryForList("SELECT minuto, valor FROM pulsaciones WHERE usuario_id = ? AND fecha = ? ORDER BY minuto ASC", userId, fechaUltima);
        List<Map<String, Object>> fasesSueno = db.queryForList("SELECT fase, horas FROM fases_sueno WHERE usuario_id = ? AND fecha = ? ORDER BY id ASC", userId, fechaUltima);

        return ResponseEntity.ok(Map.of("historial_reloj", historialReloj, "ultimo_reloj", ultimoDato, "pulsaciones", pulsaciones, "fases_sueno", fasesSueno));
    }

    private ResponseEntity<?> guardarDatosReloj(Long userId, String fecha, List<Map<String, Object>> pulsaciones, List<Map<String, Object>> fasesSueno) {
        log.info("guardarDatosReloj: userId={}, fecha={}", userId, fecha);
        try {
            double horasAwake = 0.0;
            double horasLight = 0.0;
            double horasDeep = 0.0;
            double horasRem = 0.0;

            for (Map<String, Object> fase : fasesSueno) {
                String nombreFase = fase.getOrDefault("fase", "").toString().toLowerCase();
                double horas = toDouble(fase.getOrDefault("horas", 0));
                switch (nombreFase) {
                    case "awake": horasAwake += horas; break;
                    case "light": horasLight += horas; break;
                    case "deep": horasDeep += horas; break;
                    case "rem": horasRem += horas; break;
                    default: break;
                }
            }

            double totalHoras = horasAwake + horasLight + horasDeep + horasRem;

            db.update("DELETE FROM reloj_suenos WHERE usuario_id = ? AND fecha = ?", userId, fecha);
            db.update("DELETE FROM fases_sueno WHERE usuario_id = ? AND fecha = ?", userId, fecha);

            db.update("INSERT INTO reloj_suenos (usuario_id, fecha, total_horas, horas_awake, horas_light, horas_deep, horas_rem) VALUES (?, ?, ?, ?, ?, ?, ?)",
                    userId, fecha, totalHoras, horasAwake, horasLight, horasDeep, horasRem);

            for (Map<String, Object> pulso : pulsaciones) {
                int minuto = toInt(pulso.getOrDefault("minuto", 0));
                int valor = toInt(pulso.getOrDefault("valor", 0));
                db.update("INSERT INTO pulsaciones (usuario_id, fecha, minuto, valor) VALUES (?, ?, ?, ?) " +
                          "ON DUPLICATE KEY UPDATE valor = VALUES(valor)",
                        userId, fecha, minuto, valor);
            }

            for (Map<String, Object> fase : fasesSueno) {
                db.update("INSERT INTO fases_sueno (usuario_id, fecha, fase, horas) VALUES (?, ?, ?, ?)",
                        userId, fecha, fase.getOrDefault("fase", ""), toDouble(fase.getOrDefault("horas", 0)));
            }

            log.info("guardarDatosReloj: guardados {} pulsaciones y {} fases para userId={}, fecha={}",
                    pulsaciones.size(), fasesSueno.size(), userId, fecha);
            return ResponseEntity.ok(Map.of("mensaje", "Datos de reloj guardados"));
        } catch (Exception e) {
            log.error("guardarDatosReloj: error para userId={}, fecha={}: {}", userId, fecha, e.getMessage(), e);
            return ResponseEntity.status(500).body(Map.of("error", "Error al guardar los datos del reloj"));
        }
    }

    private double toDouble(Object value) {
        if (value instanceof Number) return ((Number) value).doubleValue();
        try {
            return Double.parseDouble(value.toString());
        } catch (Exception e) {
            return 0.0;
        }
    }

    private int toInt(Object value) {
        if (value instanceof Number) return ((Number) value).intValue();
        try {
            return Integer.parseInt(value.toString());
        } catch (Exception e) {
            return 0;
        }
    }

    // 9. Obtener todo para el admin
    @GetMapping("/admin/usuarios")
    public ResponseEntity<?> getAdminUsuarios() {
        List<Map<String, Object>> users = db.queryForList("SELECT id, nombre, correo, bloqueado FROM usuarios WHERE nombre != 'admin'");
        
        for (Map<String, Object> u : users) {
            Long uid = ((Number) u.get("id")).longValue();

            Object b = u.get("bloqueado");
            boolean isBloqueado = false;
            if (b instanceof Boolean) isBloqueado = (Boolean) b;
            else if (b instanceof Number) isBloqueado = ((Number) b).intValue() == 1;
            u.put("bloqueado", isBloqueado);

            List<Map<String, Object>> enc = db.queryForList("SELECT * FROM encuestas WHERE usuario_id = ?", uid);
            u.put("encuesta", enc.isEmpty() ? null : enc.get(0));

            List<Map<String, Object>> reg = db.queryForList("SELECT * FROM registros_diarios WHERE usuario_id = ? ORDER BY fecha DESC LIMIT 1", uid);
            u.put("registro_diario", reg.isEmpty() ? null : reg.get(0));

            List<Map<String, Object>> alms = db.queryForList("SELECT hora, activada FROM alarmas WHERE usuario_id = ?", uid);
            for (Map<String, Object> a : alms) {
                Object val = a.get("activada");
                boolean isActivada = false;
                if (val instanceof Boolean) isActivada = (Boolean) val;
                else if (val instanceof Number) isActivada = ((Number) val).intValue() == 1;
                a.put("activada", isActivada);
            }
            u.put("alarmas", alms);
        }
        return ResponseEntity.ok(users);
    }

    // 10. Bloquear/Desbloquear usuario (Admin)
    @PutMapping("/admin/usuarios/{id}/bloquear")
    public ResponseEntity<?> bloquearUsuario(@PathVariable Long id, @RequestBody Map<String, Boolean> body) {
        db.update("UPDATE usuarios SET bloqueado = ? WHERE id = ?", body.get("bloquear"), id);
        return ResponseEntity.ok(Map.of("mensaje", "Estado de bloqueo actualizado"));
    }

    // 11. Eliminar usuario completo (Admin)
    @DeleteMapping("/admin/usuarios/{id}")
    public ResponseEntity<?> eliminarUsuario(@PathVariable Long id) {
        db.update("DELETE FROM alarmas WHERE usuario_id = ?", id);
        db.update("DELETE FROM registros_diarios WHERE usuario_id = ?", id);
        db.update("DELETE FROM encuestas WHERE usuario_id = ?", id);
        db.update("DELETE FROM chat_coach WHERE usuario_id = ?", id);
        db.update("DELETE FROM pulsaciones WHERE usuario_id = ?", id);
        db.update("DELETE FROM fases_sueno WHERE usuario_id = ?", id);
        db.update("DELETE FROM reloj_suenos WHERE usuario_id = ?", id);
        db.update("DELETE FROM usuarios WHERE id = ?", id);
        return ResponseEntity.ok(Map.of("mensaje", "Usuario eliminado"));
    }

    // 12. Obtener lista de sesiones de chat del Coach
    @GetMapping("/coach/{nombre}/sesiones")
    public ResponseEntity<?> getSesionesCoach(@PathVariable String nombre) {
        List<Map<String, Object>> users = db.queryForList("SELECT id FROM usuarios WHERE nombre = ?", nombre);
        if (users.isEmpty()) return ResponseEntity.status(404).body(Map.of("error", "Usuario no encontrado"));
        Long userId = ((Number) users.get(0).get("id")).longValue();

        String sql = "SELECT session_id, MIN(fecha) as fecha, " +
                     "(SELECT texto FROM chat_coach c2 WHERE c2.session_id = c1.session_id ORDER BY id ASC LIMIT 1) as titulo " +
                     "FROM chat_coach c1 WHERE usuario_id = ? AND session_id IS NOT NULL " +
                     "GROUP BY session_id ORDER BY fecha DESC";
                     
        List<Map<String, Object>> sesiones = db.queryForList(sql, userId);
        return ResponseEntity.ok(sesiones);
    }

    // 13. Obtener mensajes de una sesión específica
    @GetMapping("/coach/{nombre}/sesion/{sessionId}")
    public ResponseEntity<?> getMensajesSesion(@PathVariable String nombre, @PathVariable String sessionId) {
        List<Map<String, Object>> users = db.queryForList("SELECT id FROM usuarios WHERE nombre = ?", nombre);
        if (users.isEmpty()) return ResponseEntity.status(404).body(Map.of("error", "Usuario no encontrado"));
        Long userId = ((Number) users.get(0).get("id")).longValue();
        
        List<Map<String, Object>> chat = db.queryForList("SELECT rol, texto FROM chat_coach WHERE usuario_id = ? AND session_id = ? ORDER BY id ASC", userId, sessionId);
        return ResponseEntity.ok(chat);
    }

    // 14. Guardar mensaje en el chat (Coach)
    @PostMapping("/coach")
    public ResponseEntity<?> guardarMensajeCoach(@RequestBody Map<String, Object> body) {
        List<Map<String, Object>> users = db.queryForList("SELECT id FROM usuarios WHERE nombre = ?", body.get("nombre"));
        if (users.isEmpty()) return ResponseEntity.status(404).body(Map.of("error", "Usuario no encontrado"));
        Long userId = ((Number) users.get(0).get("id")).longValue();
        
        db.update("INSERT INTO chat_coach (usuario_id, rol, texto, session_id) VALUES (?, ?, ?, ?)", 
            userId, body.get("rol"), body.get("texto"), body.get("session_id"));
        return ResponseEntity.ok(Map.of("mensaje", "Mensaje guardado"));
    }

    // 15. login con google
    @PostMapping("/auth/google")
    public ResponseEntity<?> loginConGoogle(@RequestBody Map<String, String> body) {
        try {
            String email = body.get("email");
            String nombre = body.get("nombre");
            
            // 1. Buscamos si el usuario ya existe en la base de datos por su email o nombre
            String sqlBuscar = "SELECT * FROM usuarios WHERE correo = ? OR nombre = ?";
            List<Map<String, Object>> usuarios = db.queryForList(sqlBuscar, email, nombre);
            
            Map<String, Object> respuesta = new HashMap<>();
            Map<String, Object> datosUsuario = new HashMap<>();

            if (usuarios.isEmpty()) {
                // 2. Si no existe, lo registramos
                String sqlInsert = "INSERT INTO usuarios (nombre, correo, contrasena, edad, encuesta_completada) VALUES (?, ?, ?, ?, ?)";
                db.update(sqlInsert, nombre, email, "GOOGLE_AUTH", 25, false);
                
                datosUsuario.put("nombre", nombre);
                datosUsuario.put("correo", email);
                datosUsuario.put("encuesta_completada", false);
            } else {
                // 3. Si existe, obtenemos sus datos
                Map<String, Object> usuarioExistente = usuarios.get(0);
                datosUsuario.put("nombre", usuarioExistente.get("nombre"));
                datosUsuario.put("correo", usuarioExistente.get("correo"));
                
                Object encuestaObj = usuarioExistente.get("encuesta_completada");
                boolean encuestaCompletada = false;
                if (encuestaObj != null) {
                    if (encuestaObj instanceof Boolean) {
                        encuestaCompletada = (Boolean) encuestaObj;
                    } else if (encuestaObj instanceof Number) {
                        encuestaCompletada = ((Number) encuestaObj).intValue() == 1;
                    }
                }
                datosUsuario.put("encuesta_completada", encuestaCompletada);
            }

            respuesta.put("mensaje", "Login con Google exitoso");
            respuesta.put("usuario", datosUsuario);
            return ResponseEntity.ok(respuesta);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Error procesando el login de Google"));
        }
    }

    // 16. Guardar hora de despertar (Magia para la Jefa)
    @PostMapping("/registro_despertar")
    public ResponseEntity<?> registrarHoraDespertar(@RequestBody Map<String, Object> body) {
        String nombre = body.get("nombre") != null ? body.get("nombre").toString().trim() : null;
        if (nombre == null || nombre.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "El campo 'nombre' es obligatorio"));
        }

        List<Map<String, Object>> users = db.queryForList("SELECT id FROM usuarios WHERE nombre = ?", nombre);
        if (users.isEmpty()) return ResponseEntity.status(404).body(Map.of("error", "Usuario no encontrado"));

        Long userId = ((Number) users.get(0).get("id")).longValue();
        String fecha = body.getOrDefault("fecha", LocalDate.now(ZONE_ID).toString()).toString();
        String horaDespertar = body.getOrDefault("hora_despertar", "").toString();

        try {
            // Se asume que tienes una tabla llamada 'registros_diarios' o similar donde guardar esto.
            // Si la columna hora_despertar no existe, deberás añadirla a tu base de datos SQL.
            // Aquí hacemos un UPDATE asumiendo que el registro diario ya se creó, o lo adaptas a tu modelo.
            String sqlCheck = "SELECT id FROM registros_diarios WHERE usuario_id = ? AND fecha = ?";
            List<Map<String, Object>> registroExistente = db.queryForList(sqlCheck, userId, fecha);

            if (registroExistente.isEmpty()) {
                // Si no hay registro para hoy, lo creamos con la hora de despertar
                String sqlInsert = "INSERT INTO registros_diarios (usuario_id, fecha, hora_despertar) VALUES (?, ?, ?)";
                db.update(sqlInsert, userId, fecha, horaDespertar);
            } else {
                // Si ya hay registro, lo actualizamos
                String sqlUpdate = "UPDATE registros_diarios SET hora_despertar = ? WHERE usuario_id = ? AND fecha = ?";
                db.update(sqlUpdate, horaDespertar, userId, fecha);
            }
            
            log.info("Hora de despertar registrada: {} para usuario {}", horaDespertar, nombre);
            return ResponseEntity.ok(Map.of("mensaje", "Hora de despertar guardada con éxito"));
            
        } catch (Exception e) {
            log.error("Error al guardar hora de despertar para {}: {}", nombre, e.getMessage());
            return ResponseEntity.status(500).body(Map.of("error", "Error interno al guardar la hora de despertar"));
        }
    }
}