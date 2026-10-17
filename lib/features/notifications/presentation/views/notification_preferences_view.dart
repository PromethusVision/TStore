import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/notifications/data/repositories/notification_preferences_repository.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/domain/push_coordinator.dart';
import 'package:t_store/features/notifications/presentation/views/push_device_controls.dart';

class NotificationPreferencesView extends StatelessWidget {
  const NotificationPreferencesView({super.key, this.repository});
  final NotificationPreferencesRepository? repository;
  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (context, state) {
      final role = state is AuthAuthenticated
          ? NotificationAppRole.values
                .where((r) => r.name == state.user.role)
                .firstOrNull
          : null;
      return Scaffold(
        appBar: AppBar(title: const Text('Bildirim tercihleri')),
        body: state is AuthAuthenticated && role != null
            ? NotificationPreferenceControls(
                key: ValueKey('${state.user.id}:${role.name}'),
                identity: PushIdentity(state.user.id, role),
                repository:
                    repository ?? LocalNotificationPreferencesRepository(),
              )
            : const Center(child: Text('Tercihler için hesabına giriş yap.')),
      );
    },
  );
}

class NotificationPreferenceControls extends StatefulWidget {
  const NotificationPreferenceControls({
    super.key,
    required this.identity,
    required this.repository,
    this.push,
    this.readTimeout = const Duration(seconds: 15),
  });
  final PushIdentity identity;
  final NotificationPreferencesRepository repository;
  final PushCoordinator? push;
  final Duration readTimeout;
  @override
  State<NotificationPreferenceControls> createState() =>
      _NotificationPreferenceControlsState();
}

class _NotificationPreferenceControlsState
    extends State<NotificationPreferenceControls> {
  NotificationPreferences? _preferences;
  bool _saving = false;
  String? _error;
  int _revision = 0, _authority = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant NotificationPreferenceControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    final identityChanged = !oldWidget.identity.matches(widget.identity);
    if (identityChanged || oldWidget.repository != widget.repository) {
      ++_revision;
      _preferences = null;
      if (identityChanged) {
        ++_authority;
        _saving = false;
      }
      _error = null;
      _load();
    }
  }

  Future<void> _load() async {
    final revision = ++_revision;
    setState(() => _error = null);
    try {
      final result = await widget.repository
          .read(widget.identity)
          .timeout(widget.readTimeout);
      if (mounted && revision == _revision) {
        setState(() {
          _preferences = result;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted && revision == _revision) {
        setState(() => _error = 'Tercihler yüklenemedi. Tekrar deneyin.');
      }
    }
  }

  Future<void> _save(NotificationPreferences next) async {
    if (_saving) return;
    final revision = _revision;
    final authority = _authority;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.save(widget.identity, next);
      if (mounted && revision == _revision) setState(() => _preferences = next);
    } catch (_) {
      if (mounted && revision == _revision) {
        setState(() => _error = 'Tercihler kaydedilemedi. Tekrar deneyin.');
      }
    } finally {
      if (mounted && authority == _authority) {
        setState(() => _saving = false);
        // A replacement adapter for the same account cannot cancel an ongoing
        // save. Keep controls disabled until it settles, then read the new one.
        if (revision != _revision) _load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferences = _preferences;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (widget.push != null) ...[
          PushDeviceControls(coordinator: widget.push!),
          const SizedBox(height: 24),
        ],
        if (!widget.repository.serverBacked)
          Text(
            widget.push == null
                ? 'Mobil bildirimler henüz etkin değil. Tercihlerin bu cihazda saklanır; sunucuya henüz aktarılmaz.'
                : 'Tercihlerin bu cihazda saklanır; sunucuya henüz aktarılmaz.',
          ),
        const SizedBox(height: 16),
        if (preferences == null && _error == null)
          const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Tercihler yükleniyor',
            ),
          ),
        if (preferences != null) ...[
          SwitchListTile(
            key: const Key('notification-service-preference'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Hizmet bildirimleri'),
            subtitle: const Text(
              'Alışveriş ve mesaj gelişmeleri için mobil bildirim tercihi.',
            ),
            value: preferences.service,
            onChanged: _saving
                ? null
                : (v) => _save(
                    NotificationPreferences(
                      service: v,
                      marketing: preferences.marketing,
                    ),
                  ),
          ),
          SwitchListTile(
            key: const Key('notification-marketing-preference'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Kampanya ve yerel teklifler'),
            subtitle: const Text(
              'İsteğe bağlı pazarlama bildirimleri. İstediğinde kapatabilirsin.',
            ),
            value: preferences.marketing,
            onChanged: _saving
                ? null
                : (v) => _save(
                    NotificationPreferences(
                      service: preferences.service,
                      marketing: v,
                    ),
                  ),
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          'Uygulama içindeki kayıtlar korunur. Zorunlu hesap ve güvenlik bilgilendirmeleri bu tercihlerden bağımsız olabilir.',
        ),
        if (_saving)
          const LinearProgressIndicator(
            semanticsLabel: 'Tercihler kaydediliyor',
          ),
        if (_error != null) ...[
          Semantics(liveRegion: true, child: Text(_error!)),
          if (preferences == null)
            TextButton(onPressed: _load, child: const Text('Tekrar dene')),
        ],
      ],
    );
  }
}
