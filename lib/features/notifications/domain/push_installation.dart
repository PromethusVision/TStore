/// Local transport bookkeeping, never an authentication or consent credential.
class PushInstallation {
  const PushInstallation(this.id, {this.cleanupRequired = false});
  final String id;
  final bool cleanupRequired;
}

abstract interface class PushInstallationStore {
  Future<PushInstallation> read();
  Future<void> save(PushInstallation installation);
  String newId();
}
