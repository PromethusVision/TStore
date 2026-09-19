import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_store/core/utils/theme/theme.dart';

/// Owns the complete preview application, so logout/account changes discard
/// cached canonical data and navigation before another identity can proceed.
class ProductionPreviewGate extends StatefulWidget {
  const ProductionPreviewGate({
    super.key,
    required this.currentSubject,
    required this.sessionChanges,
    required this.configure,
    required this.applicationBuilder,
    required this.loginBuilder,
    required this.signOut,
  });
  final String? Function() currentSubject;
  final Stream<void> sessionChanges;
  final Future<void> Function(String? subject) configure;
  final WidgetBuilder applicationBuilder;
  final WidgetBuilder loginBuilder;
  final Future<void> Function() signOut;

  @override
  State<ProductionPreviewGate> createState() => _ProductionPreviewGateState();
}

class _ProductionPreviewGateState extends State<ProductionPreviewGate> {
  late final StreamSubscription<void> _subscription;
  Future<void> _queue = Future.value();
  int _generation = 0;
  bool _busy = true;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _subscription = widget.sessionChanges.listen((_) {
      // During the existing login form, let its sign-in/profile lookup finish
      // and return to the caller before disposing its AuthCubit.
      if (_ready || _busy) _refresh();
    }, onError: (Object _) => _refresh());
    _refresh();
  }

  void _refresh() {
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _ready = false;
    });
    _queue = _queue.then((_) async {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || generation != _generation) return;
      final subject = widget.currentSubject();
      var accepted = false;
      try {
        await widget.configure(subject);
        accepted = subject != null && widget.currentSubject() == subject;
      } on Object {
        // Controlled diagnostics only; never render a legacy success fallback.
      }
      if (!mounted || generation != _generation) return;
      setState(() {
        _busy = false;
        _ready = accepted;
      });
    });
  }

  @override
  void dispose() {
    ++_generation;
    unawaited(_subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.applicationBuilder(context);
    return MaterialApp(
      key: ValueKey('preview-access-$_generation'),
      themeMode: ThemeMode.light,
      theme: TAppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Özel önizleme')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _busy
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.currentSubject() == null
                              ? 'Önizlemeye yetkili tester hesabınızla giriş yapın.'
                              : 'Önizleme erişimi doğrulanamadı. Hesabınızın iznini kontrol edin.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (widget.currentSubject() == null)
                          FilledButton(
                            onPressed: () async {
                              await Navigator.of(context).push<void>(
                                MaterialPageRoute(builder: widget.loginBuilder),
                              );
                              if (mounted) _refresh();
                            },
                            child: const Text('Giriş yap'),
                          )
                        else ...[
                          FilledButton(
                            onPressed: _refresh,
                            child: const Text('Tekrar dene'),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                await widget.signOut();
                              } on Object {
                                /* Stay denied. */
                              }
                              if (mounted) _refresh();
                            },
                            child: const Text('Hesap değiştir'),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
