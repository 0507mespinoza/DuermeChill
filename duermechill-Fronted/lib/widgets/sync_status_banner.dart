import 'package:flutter/material.dart';
import '../models/sync_state.dart';

class SyncStatusBanner extends StatelessWidget {
  final SyncState state;
  final VoidCallback? onRetry;
  /// Called when the user taps the noPermissions banner. Should open the
  /// Health Connect permissions screen instead of retrying the full sync.
  final VoidCallback? onOpenSettings;

  const SyncStatusBanner({
    super.key,
    required this.state,
    this.onRetry,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case SyncStatus.idle:
        return const SizedBox.shrink();

      case SyncStatus.syncing:
        return _BannerContainer(
          color: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          child: Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.message ?? 'Sincronizando datos de salud...',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        );

      case SyncStatus.success:
        return _BannerContainer(
          color: Colors.green.shade50,
          borderColor: Colors.green.shade300,
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.message ?? 'Datos sincronizados correctamente.',
                  style: TextStyle(fontSize: 13, color: Colors.green.shade800),
                ),
              ),
            ],
          ),
        );

      case SyncStatus.noPermissions:
        return GestureDetector(
          onTap: onOpenSettings ?? onRetry,
          child: _BannerContainer(
            color: Colors.orange.shade50,
            borderColor: Colors.orange.shade300,
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.message ?? 'Permisos de salud no concedidos. Toca para abrir ajustes.',
                    style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.orange.shade400, size: 18),
              ],
            ),
          ),
        );

      case SyncStatus.noConnection:
        return _BannerContainer(
          color: Colors.grey.shade100,
          borderColor: Colors.grey.shade400,
          child: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.message ?? 'Sin conexión a Internet. Comprueba tu red e inténtalo de nuevo.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        );

      case SyncStatus.healthConnectNotInstalled:
        return _BannerContainer(
          color: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.message ??
                      'Health Connect no está instalado. Los datos de tu Samsung Health u otro reloj '
                          'se sincronizan a través de Health Connect.',
                  style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        );

      case SyncStatus.noData:
        return _BannerContainer(
          color: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.message ??
                      'No se encontraron datos de sueño. Asegúrate de que tu reloj haya sincronizado con Health Connect.',
                  style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        );

      case SyncStatus.error:
        return _BannerContainer(
          color: Colors.red.shade50,
          borderColor: Colors.red.shade300,
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.message ?? 'Error al sincronizar. Por favor inténtalo de nuevo.',
                  style: TextStyle(fontSize: 13, color: Colors.red.shade900),
                ),
              ),
              if (onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Reintentar', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        );
    }
  }
}

class _BannerContainer extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final Widget child;

  const _BannerContainer({
    required this.color,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
