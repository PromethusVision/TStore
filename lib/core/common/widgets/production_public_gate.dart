import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_store/core/utils/theme/theme.dart';

/// Anonymous access is normal. A failed publication check removes the entire
/// customer app and its cached navigation; there is no alternate runtime.
class ProductionPublicGate extends StatefulWidget {
  const ProductionPublicGate({
    super.key,
    required this.changes,
    required this.configure,
    required this.applicationBuilder,
    required this.invalidate,
  });
  final Stream<void> changes;
  final Future<void> Function(VoidCallback unavailable) configure;
  final WidgetBuilder applicationBuilder;
  final VoidCallback invalidate;
  @override
  State<ProductionPublicGate> createState() => _ProductionPublicGateState();
}

class _ProductionPublicGateState extends State<ProductionPublicGate> {
  late final StreamSubscription<void> _subscription;
  Future<void> _queue = Future.value();
  var _generation = 0;
  var _busy = true;
  var _ready = false;
  @override
  void initState() {
    super.initState();
    _subscription = widget.changes.listen(
      (_) => _refresh(),
      onError: (Object _) => _reject(),
    );
    _refresh();
  }

  void _reject() {
    widget.invalidate();
    _generation++;
    if (mounted) {
      setState(() {
        _busy = false;
        _ready = false;
      });
    }
  }

  void _refresh() {
    widget.invalidate();
    final ticket = ++_generation;
    setState(() {
      _busy = true;
      _ready = false;
    });
    _queue = _queue.then((_) async {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || ticket != _generation) return;
      var accepted = false;
      try {
        await widget.configure(() {
          if (mounted && ticket == _generation) _reject();
        });
        accepted = true;
      } on Object {
        /* Controlled failure only. */
      }
      if (!mounted || ticket != _generation) return;
      setState(() {
        _busy = false;
        _ready = accepted;
      });
    });
  }

  @override
  void dispose() {
    _generation++;
    widget.invalidate();
    unawaited(_subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.applicationBuilder(context);
    return MaterialApp(
      theme: TAppTheme.lightTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('EsnaftaVar')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _busy
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Katalog şu anda kullanılamıyor. Lütfen tekrar deneyin.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _refresh,
                        child: const Text('Tekrar dene'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
