import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/presentation/merchant_home.dart';
import 'package:t_store/features/merchant/presentation/merchant_session_cubit.dart';
import 'package:t_store/features/merchant/presentation/merchant_shop_form.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';

class MerchantApp extends StatefulWidget {
  const MerchantApp({super.key, required this.services});
  final MerchantServices services;
  @override
  State<MerchantApp> createState() => _MerchantAppState();
}

class _MerchantAppState extends State<MerchantApp> with WidgetsBindingObserver {
  late final MerchantSessionCubit _session;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = MerchantSessionCubit(
      repository: widget.services.merchants,
      credentials: widget.services.credentials,
      sessionChanges: widget.services.sessionChanges,
      currentUserId: widget.services.currentUserId,
      beforeSignOut: widget.services.pushCoordinator?.disable,
    )..reload();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Recheck role, ownership and shop suspension after returning to the app.
    if (state == AppLifecycleState.resumed) _session.reload(quiet: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _session.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _session,
    child: MaterialApp(
      title: 'EsnaftaVar Esnaf',
      debugShowCheckedModeBanner: false,
      theme: EsnaftaVarTheme.light,
      themeMode: ThemeMode.light,
      home: BlocBuilder<MerchantSessionCubit, MerchantSessionState>(
        builder: (context, state) {
          final access = state.access;
          return switch (state.status) {
            MerchantSessionStatus.checking => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            MerchantSessionStatus.signedOut => _MerchantLogin(
              state: state,
              preview: widget.services.preview,
            ),
            MerchantSessionStatus.failure => MerchantPage(
              title: 'Hesabını doğrula',
              children: [
                MerchantNotice(
                  state.message ?? 'İşlem tamamlanamadı.',
                  error: true,
                  onRetry: _session.reload,
                ),
                TextButton(
                  onPressed: _session.signOut,
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
              home: MerchantHome(services: widget.services, access: access),
            ),
          };
        },
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
  const _MerchantLogin({required this.state, required this.preview});
  final MerchantSessionState state;
  final bool preview;
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
    if (!widget.state.busy && _form.currentState!.validate()) {
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
      if (widget.state.message != null)
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
