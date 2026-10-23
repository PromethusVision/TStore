import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_store/features/notifications/domain/push_coordinator.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/presentation/merchant_home.dart';
import 'package:t_store/features/merchant/presentation/merchant_session_cubit.dart';
import 'package:t_store/features/merchant/presentation/merchant_shop_form.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';
import 'presentation/merchant_account_recovery_view.dart';

class MerchantApp extends StatefulWidget {
  const MerchantApp({super.key, required this.services});
  final MerchantServices services;
  @override
  State<MerchantApp> createState() => _MerchantAppState();
}

class _MerchantAppState extends State<MerchantApp> with WidgetsBindingObserver {
  late final MerchantSessionCubit _session;
  late final PushCoordinator? _push;
  StreamSubscription<MerchantSessionState>? _scopeChanges;
  final _inboxRequests = ValueNotifier<int>(0);
  final _notificationRequests = ValueNotifier<NotificationEntity?>(null);
  int _lastScope = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _push =
        widget.services.pushFactory?.call(_openNotification) ??
        widget.services.pushCoordinator;
    _session = MerchantSessionCubit(
      repository: widget.services.merchants,
      credentials: widget.services.credentials,
      sessionChanges: widget.services.sessionChanges,
      currentUserId: widget.services.currentUserId,
      currentSessionKey: widget.services.currentSessionKey,
      sessionIdentities: widget.services.sessionIdentities,
      beforeSignOut: _push?.disable,
    );
    _scopeChanges = _session.stream.listen((state) {
      if (_lastScope != state.scopeRevision) {
        _lastScope = state.scopeRevision;
        _notificationRequests.value = null;
        _push?.invalidate();
      }
    });
    widget.services.recovery?.addListener(_recoveryChanged);
    _session.setRecoveryActive(
      widget.services.recovery?.blocksWorkspace ?? false,
    );
    _session.reload();
  }

  void _recoveryChanged() {
    if (!mounted) return;
    _session.setRecoveryActive(widget.services.recovery!.blocksWorkspace);
    setState(() {});
  }

  void _openNotification(NotificationEntity notification) {
    if (!mounted ||
        _session.state.status != MerchantSessionStatus.ready ||
        notification.userId != widget.services.currentUserId() ||
        notification.userId != _session.state.access?.user.id) {
      return;
    }
    // This is a validated event, not persistent selection. The coordinator owns
    // deduplication; a later enrollment can legitimately open the same record.
    _notificationRequests.value = null;
    _notificationRequests.value = notification;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Recheck role, ownership and shop suspension after returning to the app.
    if (state == AppLifecycleState.resumed) _session.reload(quiet: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.services.recovery?.removeListener(_recoveryChanged);
    _scopeChanges?.cancel();
    _push?.invalidate();
    if (widget.services.pushFactory != null) _push?.dispose();
    _inboxRequests.dispose();
    _notificationRequests.dispose();
    _session.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _session,
    child: BlocBuilder<MerchantSessionCubit, MerchantSessionState>(
      builder: (context, state) => MaterialApp(
        // Home alone does not own root dialogs or the ScaffoldMessenger queue.
        // Replace the entire navigation scope when its authority is invalidated.
        key: ValueKey(
          '${state.scopeRevision}:${widget.services.recovery?.revision ?? 0}',
        ),
        title: 'EsnaftaVar Esnaf',
        debugShowCheckedModeBanner: false,
        theme: EsnaftaVarTheme.light,
        themeMode: ThemeMode.light,
        home: Builder(
          builder: (context) {
            final recovery = widget.services.recovery;
            if (recovery != null && recovery.blocksWorkspace) {
              return MerchantAccountRecoveryView(recovery: recovery);
            }
            final access = state.access;
            return switch (state.status) {
              MerchantSessionStatus.checking => Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 24),
                          Text(
                            state.message ?? 'Esnaf erişimi doğrulanıyor…',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              MerchantSessionStatus.signedOut => _MerchantLogin(
                state: state,
                preview: widget.services.preview,
                onRecovery: recovery?.request,
              ),
              MerchantSessionStatus.failure => MerchantPage(
                title: 'Hesabını doğrula',
                children: [
                  MerchantNotice(
                    state.message ?? 'İşlem tamamlanamadı.',
                    error: true,
                    onRetry: state.busy || !state.canRetry
                        ? null
                        : _session.reload,
                  ),
                  TextButton(
                    onPressed: state.busy ? null : _session.signOut,
                    child: const Text('Çıkış yap'),
                  ),
                ],
              ),
              MerchantSessionStatus.denied => MerchantPage(
                title: 'Esnaf erişimi',
                children: [
                  MerchantNotice(
                    access?.hasRole == true
                        ? 'Mağazanız şu anda yönetim işlemlerine açık değil. Yetkili ekip ile iletişime geçin.'
                        : 'Bu hesabın esnaf yetkisi henüz yok. Onaylı esnaf hesabınızla giriş yapın.',
                  ),
                  FilledButton(
                    onPressed: _session.reload,
                    child: const Text('Erişimi yeniden kontrol et'),
                  ),
                  TextButton(
                    onPressed: _session.signOut,
                    child: const Text('Başka hesapla giriş yap'),
                  ),
                ],
              ),
              MerchantSessionStatus.onboarding => MerchantShopForm(
                key: ValueKey('setup-${access!.user.id}'),
                repository: widget.services.merchants,
                access: access,
                onSaved: _session.reload,
                onSignOut: _session.signOut,
              ),
              MerchantSessionStatus.ready => _MerchantWorkspace(
                key: ValueKey(
                  'workspace-${access!.user.id}-${access.shop!.id}-${access.shop!.updatedAt}',
                ),
                home: MerchantHome(
                  services: widget.services,
                  access: access,
                  push: _push,
                  inboxRequests: _inboxRequests,
                  notificationRequests: _notificationRequests,
                ),
              ),
            };
          },
        ),
      ),
    ),
  );
}

class _MerchantWorkspace extends StatefulWidget {
  const _MerchantWorkspace({super.key, required this.home});
  final Widget home;
  @override
  State<_MerchantWorkspace> createState() => _MerchantWorkspaceState();
}

class _MerchantWorkspaceState extends State<_MerchantWorkspace> {
  final _navigator = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) => NavigatorPopHandler<void>(
    onPopWithResult: (_) => _navigator.currentState!.maybePop(),
    child: Navigator(
      key: _navigator,
      onGenerateRoute: (_) =>
          MaterialPageRoute<void>(builder: (_) => widget.home),
    ),
  );
}

class _MerchantLogin extends StatefulWidget {
  const _MerchantLogin({
    required this.state,
    required this.preview,
    this.onRecovery,
  });
  final MerchantSessionState state;
  final bool preview;
  final VoidCallback? onRecovery;
  @override
  State<_MerchantLogin> createState() => _MerchantLoginState();
}

class _MerchantLoginState extends State<_MerchantLogin> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(), _password = TextEditingController();
  bool _obscure = true;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!widget.state.busy && merchantValidateForm(_form)) {
      context.read<MerchantSessionCubit>().signIn(_email.text, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) => MerchantPage(
    title: 'EsnaftaVar Esnaf',
    children: [
      const Icon(Icons.storefront_outlined, size: 56),
      Text('Mağazan burada.', style: Theme.of(context).textTheme.headlineLarge),
      const Text(
        'Ürünlerini, fiyatlarını ve mağaza bilgilerini tek yerden yönet.',
      ),
      if (widget.preview)
        const MerchantNotice(
          'Yerel önizleme • Gerçek hesap veya veri kullanılmaz.',
        ),
      if (widget.state.message != null && !widget.state.busy)
        MerchantNotice(widget.state.message!, error: true),
      Form(
        key: _form,
        child: AutofillGroup(
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                enabled: !widget.state.busy,
                decoration: const InputDecoration(labelText: 'E-posta'),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.username],
                validator: (v) =>
                    RegExp(
                      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                    ).hasMatch((v ?? '').trim())
                    ? null
                    : 'Geçerli e-posta girin.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                enabled: !widget.state.busy,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (v) => (v ?? '').isEmpty ? 'Şifrenizi girin.' : null,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              if (widget.onRecovery != null)
                TextButton(
                  onPressed: widget.state.busy ? null : widget.onRecovery,
                  child: const Text('Şifremi unuttum'),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.state.busy ? null : _submit,
                  child: Text(
                    widget.state.busy ? 'Giriş yapılıyor…' : 'Giriş yap',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const Text(
        'Pilot erişimi onaylı esnaf hesapları içindir. Hesap yetkisi ve erişim desteği için pilot ekibiyle iletişime geçin.',
      ),
    ],
  );
}
