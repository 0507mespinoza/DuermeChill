import 'package:flutter/material.dart';
import '../services/health_service.dart';

/// Displays real-time diagnostic information about Health Connect integration.
/// Shows requested types, permission status, SDK availability, and platform info.
class HealthDebugPanel extends StatefulWidget {
  const HealthDebugPanel({super.key});

  @override
  State<HealthDebugPanel> createState() => _HealthDebugPanelState();
}

class _HealthDebugPanelState extends State<HealthDebugPanel> {
  bool _expanded = true;
  late Future<Map<String, bool>> _permissionsFuture;
  late Future<String> _sdkStatusFuture;

  @override
  void initState() {
    super.initState();
    _refreshDiagnostics();
  }

  void _refreshDiagnostics() {
    _permissionsFuture = HealthService.getPermissionStatusMap();
    _sdkStatusFuture = HealthService.getHealthConnectSdkStatusText();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.all(12),
      color: isDark ? Colors.grey[900] : Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with expand/collapse
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.health_and_safety, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Health Connect Diagnostics',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable content
          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Platform info
                  _buildInfoRow(
                    'Platform',
                    HealthService.getPlatformName(),
                  ),
                  
                  // SDK Status
                  FutureBuilder<String>(
                    future: _sdkStatusFuture,
                    builder: (context, snapshot) {
                      final status = snapshot.data ?? 'Checking...';
                      return _buildInfoRow('SDK Status', status);
                    },
                  ),
                  
                  const Divider(height: 12),
                  
                  // Requested types with availability
                  const Text(
                    'Requested Types:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  _buildTypesList(),
                  
                  const Divider(height: 12),
                  
                  // Permission status
                  const Text(
                    'Permission Status:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  FutureBuilder<Map<String, bool>>(
                    future: _permissionsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 20,
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      
                      final permissions = snapshot.data ?? {};
                      if (permissions.isEmpty) {
                        return const Text('No permissions to check', style: TextStyle(fontSize: 11));
                      }
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: permissions.entries.map((entry) {
                          final name = entry.key;
                          final granted = entry.value;
                          if (name == '_error') return const SizedBox.shrink();
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Icon(
                                  granted ? Icons.check_circle : Icons.cancel,
                                  size: 14,
                                  color: granted ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: granted ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Refresh button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(_refreshDiagnostics);
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypesList() {
    final types = HealthService.getRequestedHealthTypes();
    final availability = HealthService.getTypeAvailabilityMap();
    
    if (types.isEmpty) {
      return const Text('No types requested', style: TextStyle(fontSize: 11));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: types.map((type) {
        final available = availability[type.name] ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Icon(
                available ? Icons.check_box : Icons.indeterminate_check_box,
                size: 14,
                color: available ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  type.name,
                  style: TextStyle(
                    fontSize: 11,
                    color: available ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
