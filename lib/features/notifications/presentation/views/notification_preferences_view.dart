import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/notifications/data/repositories/notification_preferences_repository.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/domain/push_coordinator.dart';
import 'package:t_store/features/notifications/domain/repositories/notification_repository.dart';
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
  bool _loading = false, _uncertain = false, _expired = false;
  NotificationSessionSource? _sessionSource;
  String? _sessionKey;
  StreamSubscription<String?>? _sessionSubscription;
  int _binding = 0;
  String? _error;
  int _revision = 0, _authority = 0;
  @override
  void initState() {
    super.initState();
    _bindSession();
    _load();
  }

  bool get _sessionCurrent =>
      !_expired &&
      (_sessionSource == null ||
          (_sessionSource!.currentUserId == widget.identity.userId &&
              _sessionKey != null &&
              _sessionSource!.currentSessionKey == _sessionKey));

  void _bindSession() {
    final binding = ++_binding;
    unawaited(_sessionSubscription?.cancel());
    _sessionSubscription = null;
    final repository = widget.repository;
    _sessionSource = repository is NotificationSessionSource
        ? repository as NotificationSessionSource
        : null;
    _sessionKey = _sessionSource?.currentSessionKey;
    _expired = false;
    if (!_sessionCurrent) {
      _expired = true;
      return;
    }
    _sessionSubscription = _sessionSource?.sessionKeyChanges.listen(
      (key) {
        if (binding == _binding && (key != _sessionKey || !_sessionCurrent)) {
          _expireSession();
        }
      },
      onError: (Object _) {
        if (binding == _binding) _expireSession();
      },
      onDone: () {
        if (binding == _binding) _expireSession();
      },
    );
  }

  void _expireSession() {
    if (!mounted || _expired) return;
    setState(() {
      _expired = true;
      ++_revision;
      ++_authority;
      _preferences = null;
      _loading = _saving = _uncertain = false;
      _error = null;
    });
  }

  bool _accept(int revision) {
    if (!mounted || revision != _revision) return false;
    if (!_sessionCurrent) {
      _expireSession();
      return false;
    }
    return true;
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
      _loading = _uncertain = false;
      _error = null;
      _bindSession();
      _load();
    }
  }

  Future<void> _load({bool replace = false}) async {
    if (!_sessionCurrent || (_loading && !replace)) return;
    final revision = ++_revision;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.repository
          .read(widget.identity)
          .timeout(widget.readTimeout);
      if (_accept(revision)) {
        setState(() {
          _preferences = result;
          _uncertain = false;
          _error = null;
        });
      }
    } catch (_) {
      if (_accept(revision)) {
        setState(() => _error = 'Tercihler yüklenemedi. Tekrar deneyin.');
      }
    } finally {
      if (_accept(revision)) setState(() => _loading = false);
    }
  }

  Future<void> _save(NotificationPreferences next) async {
    if (_saving || _loading || _uncertain || !_sessionCurrent) return;
    final revision = _revision;
    final authority = _authority;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.save(widget.identity, next);
      if (_accept(revision)) setState(() => _preferences = next);
    } catch (_) {
      if (_accept(revision)) {
        setState(() {
          _uncertain = true;
          _error =
              'Kayıt sonucu doğrulanamadı. Yeniden değiştirmeden önce kaydı kontrol edin.';
        });
      }
    } finally {
      if (mounted && authority == _authority) {
        setState(() => _saving = false);
        // A replacement adapter for the same account cannot cancel an ongoing
        // save. Keep controls disabled until it settles, then read the new one.
        if (revision != _revision) _load(replace: true);
      }
    }
  }

  @override
  void dispose() {
    ++_binding;
    ++_revision;
    ++_authority;
    unawaited(_sessionSubscription?.cancel());
    super.dispose();
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
        if (_expired)
          const Text(
            'Oturumunuz değişti. Tercihleri güncellemek için bu ekranı yeniden açın.',
          ),
        if (_loading && preferences == null)
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
            onChanged: _saving || _loading || _uncertain || _expired
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
            onChanged: _saving || _loading || _uncertain || _expired
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
        if (_loading && preferences != null)
          const LinearProgressIndicator(
            semanticsLabel: 'Tercihler kontrol ediliyor',
          ),
        if (_error != null) ...[
          Semantics(liveRegion: true, child: Text(_error!)),
          if (!_expired && (preferences == null || _uncertain))
            TextButton(
              onPressed: _loading || _saving ? null : _load,
              child: Text(_uncertain ? 'Kaydı kontrol et' : 'Tekrar dene'),
            ),
        ],
      ],
    );
  }
}
