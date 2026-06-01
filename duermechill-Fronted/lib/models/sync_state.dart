enum SyncStatus {
  idle,
  syncing,
  success,
  noPermissions,
  noData,
  noConnection,
  healthConnectNotInstalled,
  error,
}

class SyncState {
  final SyncStatus status;
  final String? message;

  const SyncState(this.status, [this.message]);

  bool get isLoading => status == SyncStatus.syncing;

  bool get hasError =>
      status == SyncStatus.error ||
      status == SyncStatus.noPermissions ||
      status == SyncStatus.noConnection ||
      status == SyncStatus.healthConnectNotInstalled;
}
