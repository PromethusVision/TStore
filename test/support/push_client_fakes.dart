import 'dart:async';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/domain/push_installation.dart';

class FakePushProvider implements MobilePushProvider {
  @override
  bool configured = true;
  final tokens = StreamController<String>.broadcast(sync: true);
  final taps = StreamController<PushOpenEvent>.broadcast(sync: true);
  Future<PushPermission> Function()? permission;
  Future<String?> Function()? token;
  Future<void> Function()? deletion;
  int permissions = 0, fetched = 0, deleted = 0;
  @override
  Future<PushPermission> requestPermission() async {
    permissions++;
    return permission == null ? PushPermission.granted : await permission!();
  }

  @override
  Future<String?> getToken() async {
    fetched++;
    return token == null ? 'synthetic-token-1' : await token!();
  }

  @override
  Stream<String> get tokenChanges => tokens.stream;
  @override
  Stream<PushOpenEvent> get opened => taps.stream;
  @override
  Future<void> deleteToken() async {
    deleted++;
    await deletion?.call();
  }

  Future<void> close() async {
    await tokens.close();
    await taps.close();
  }
}

class FakePushRegistry implements PushDeviceRegistry {
  @override
  bool deployed = true;
  final registrations = <PushDeviceRegistration>[];
  final disabled = <(PushIdentity, String)>[];
  Future<void> Function(PushDeviceRegistration)? registering;
  Future<void> Function()? disabling;
  @override
  Future<void> register(PushDeviceRegistration value) async {
    registrations.add(value);
    await registering?.call(value);
  }

  @override
  Future<void> disable(PushIdentity identity, String installationId) async {
    disabled.add((identity, installationId));
    await disabling?.call();
  }
}

class FakePushInstallationStore implements PushInstallationStore {
  PushInstallation value = const PushInstallation('install-1');
  bool failRead = false, failSave = false;
  int reads = 0, saves = 0, ids = 1;
  @override
  Future<PushInstallation> read() async {
    reads++;
    if (failRead) throw StateError('synthetic-storage-failure');
    return value;
  }

  @override
  Future<void> save(PushInstallation next) async {
    saves++;
    if (failSave) throw StateError('synthetic-storage-failure');
    value = next;
  }

  @override
  String newId() => 'install-${++ids}';
}
