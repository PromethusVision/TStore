import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import 'package:t_store/features/commerce_ledger/domain/merchant_statement.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';

class MerchantStatementEntryPoint extends StatelessWidget {
  const MerchantStatementEntryPoint({
    super.key,
    required this.services,
    required this.access,
  });
  final MerchantServices services;
  final MerchantAccess access;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.receipt_long_outlined),
      title: const Text('Hesap Bakiyesi'),
      subtitle: const Text('Alacaklar, rezerv ve hesap hareketleri'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => MerchantStatementView(
            repository: services.statement!,
            shopId: access.shop!.id,
            ownerId: access.user.id,
            currentUserId: services.currentUserId,
            sessionChanges: services.sessionChanges,
          ),
        ),
      ),
    ),
  );
}

class MerchantStatementView extends StatefulWidget {
  const MerchantStatementView({
    super.key,
    required this.repository,
    required this.shopId,
    required this.ownerId,
    required this.currentUserId,
    required this.sessionChanges,
    this.readTimeout = const Duration(seconds: 15),
  });
  final MerchantStatementRepository repository;
  final String shopId, ownerId;
  final String? Function() currentUserId;
  final Stream<String?> sessionChanges;
  final Duration readTimeout;
  @override
  State<MerchantStatementView> createState() => _MerchantStatementViewState();
}

class _MerchantStatementViewState extends State<MerchantStatementView>
    with WidgetsBindingObserver {
  MerchantStatement? _value;
  final _entries = <MerchantStatementEntry>[];
  StreamSubscription<String?>? _auth, _keys;
  AuthenticatedSessionEvents? _sessionSource;
  String? _sessionKey;
  CommerceLedgerFailure? _error;
  bool _busy = false, _sessionBroken = false;
  int _generation = 0;
  int _binding = 0;
  bool get _current =>
      !_sessionBroken &&
      widget.currentUserId() == widget.ownerId &&
      (_sessionSource == null ||
          (_sessionKey != null &&
              _sessionSource!.currentSessionKey == _sessionKey));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bind();
    _read();
  }

  void _bind() {
    final repository = widget.repository;
    _sessionSource = repository is AuthenticatedSessionEvents
        ? repository as AuthenticatedSessionEvents
        : null;
    _sessionKey = _sessionSource?.currentSessionKey;
    _listen();
  }

  void _listen() {
    final binding = ++_binding;
    unawaited(_auth?.cancel());
    unawaited(_keys?.cancel());
    _auth = widget.sessionChanges.listen(
      (actor) {
        if (binding == _binding && (actor != widget.ownerId || !_current)) {
          _expire();
        }
      },
      onError: (Object _) {
        if (binding == _binding) _expire();
      },
      onDone: () {
        if (binding == _binding) _expire();
      },
    );
    _keys = _sessionSource?.sessionKeyChanges.listen(
      (key) {
        if (binding == _binding && (key != _sessionKey || !_current)) _expire();
      },
      onError: (Object _) {
        if (binding == _binding) _expire();
      },
      onDone: () {
        if (binding == _binding) _expire();
      },
    );
  }

  void _expire() {
    if (!mounted || _sessionBroken) return;
    _sessionBroken = true;
    _reset();
  }

  bool _accept(int generation) {
    if (!mounted || generation != _generation) return false;
    if (!_current) {
      _expire();
      return false;
    }
    return true;
  }

  void _reset() {
    _generation++;
    if (!mounted) return;
    setState(() {
      _value = null;
      _entries.clear();
      _busy = false;
      _error = null;
    });
  }

  @override
  void didUpdateWidget(covariant MerchantStatementView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.shopId != widget.shopId ||
        oldWidget.ownerId != widget.ownerId) {
      _sessionBroken = false;
      _reset();
      _bind();
      _read();
    } else if (oldWidget.sessionChanges != widget.sessionChanges) {
      // A new stream wrapper does not grant a new session to this route.
      _listen();
      if (!_current) _expire();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reset();
      _read();
    }
  }

  @override
  void dispose() {
    _generation++;
    _binding++;
    unawaited(_auth?.cancel());
    unawaited(_keys?.cancel());
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _read({bool more = false}) async {
    if (!_current) {
      _expire();
      return;
    }
    if (_busy || (more && _value?.nextBefore == null)) return;
    final generation = ++_generation, previous = _value;
    setState(() {
      _busy = true;
      _error = null;
      if (!more) {
        _value = null;
        _entries.clear();
      }
    });
    try {
      final response = await widget.repository
          .readStatement(
            shopId: widget.shopId,
            before: more ? previous!.nextBefore : null,
            revision: more ? previous!.revision : null,
          )
          .timeout(widget.readTimeout);
      if (!_accept(generation)) return;
      setState(() {
        _busy = false;
        response.fold(
          (error) {
            _error = error;
            if (error == CommerceLedgerFailure.sessionChanged ||
                error == CommerceLedgerFailure.statementChanged ||
                error == CommerceLedgerFailure.invalidResponse) {
              _value = null;
              _entries.clear();
            }
          },
          (value) {
            if (value.shopId != widget.shopId ||
                (more &&
                    value.enabled &&
                    (value.revision != previous!.revision ||
                        value.reserveCap != previous.reserveCap ||
                        !mapEquals(value.accounts, previous.accounts) ||
                        !_olderPage(value.entries))) ||
                value.entries.any(
                  (e) => _entries.any((old) => old.id == e.id),
                )) {
              _value = null;
              _entries.clear();
              _error = CommerceLedgerFailure.invalidResponse;
              return;
            }
            _value = value;
            if (!value.enabled) _entries.clear();
            _entries.addAll(value.entries);
          },
        );
      });
    } catch (_) {
      if (!_accept(generation)) return;
      setState(() {
        _busy = false;
        _error = CommerceLedgerFailure.unavailable;
      });
    }
  }

  bool _olderPage(List<MerchantStatementEntry> next) {
    if (_entries.isEmpty || next.isEmpty) return true;
    final last = _entries.last, first = next.first;
    return first.recordedAt.isBefore(last.recordedAt) ||
        (first.recordedAt == last.recordedAt &&
            first.id.compareTo(last.id) < 0);
  }

  String _message(CommerceLedgerFailure error) => switch (error) {
    CommerceLedgerFailure.statementChanged =>
      'Hesabına yeni hareketler eklendi. Güncel bakiyeyi görmek için yenile.',
    CommerceLedgerFailure.sessionChanged =>
      'Hesap erişimi doğrulanamadı. Oturumunu yeniden kontrol et.',
    _ => 'Hesap bilgileri yüklenemedi. Bağlantını kontrol edip tekrar dene.',
  };
  @override
  Widget build(BuildContext context) {
    if (!_current) {
      return const Scaffold(
        body: Center(child: Text('Oturumunuz değişti. Bu ekranı kapatın.')),
      );
    }
    final value = _value;
    return MerchantPage(
      title: 'Hesap Bakiyesi',
      onRefresh: _read,
      actions: [
        IconButton(
          tooltip: 'Hesabı yenile',
          onPressed: _busy ? null : _read,
          icon: const Icon(Icons.refresh),
        ),
      ],
      children: [
        const Text('Alacaklarını kaynaklarına göre takip et.'),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          MerchantNotice(
            _message(_error!),
            error: true,
            onRetry: _busy
                ? null
                : () => _read(more: _value?.nextBefore != null),
          ),
        if (value != null && !value.enabled)
          const MerchantNotice(
            'Hesap bilgileri şu anda kullanıma açık değil. Daha sonra yeniden deneyebilirsin.',
          ),
        if (value != null && value.enabled) ...[
          MerchantSection(
            title: 'Bekleyen alacak',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  statementMoney(value.pending),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                _balanceLine(
                  'Kupon kullanımlarından',
                  value.balance(LedgerAccountKind.merchantCouponPending),
                ),
                _balanceLine(
                  'Kullanılmayan paket fonundan',
                  value.balance(LedgerAccountKind.merchantUnusedPending),
                ),
              ],
            ),
          ),
          MerchantSection(
            title: 'Zorunlu mahsup rezervi',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  statementMoney(
                    value.balance(LedgerAccountKind.merchantReserve),
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text('Üst sınır: ${statementMoney(value.reserveCap!)}'),
                const SizedBox(height: 8),
                const Text(
                  'Kupon alacaklarından ayrılır ve uygun platform hizmet bedellerinde önce kullanılır. Para çekme tutarı değildir.',
                ),
              ],
            ),
          ),
          MerchantSection(
            title: 'Beklemesi tamamlanan alacak',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  statementMoney(value.released),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                _balanceLine(
                  'Kupon kullanımlarından',
                  value.balance(LedgerAccountKind.merchantCouponAvailable),
                ),
                _balanceLine(
                  'Kullanılmayan paket fonundan',
                  value.balance(LedgerAccountKind.merchantUnusedAvailable),
                ),
                const Text(
                  'Bu kayıt, ödemenin yapıldığı veya para çekilebileceği anlamına gelmez.',
                ),
              ],
            ),
          ),
          const MerchantSection(
            title: 'Ödeme durumu',
            child: Text(
              'Para çekme henüz açık değil. Ödeme takvimi ve ödenen tutar bilgisi bu ekranda henüz sunulmuyor.',
            ),
          ),
          Text(
            'Hesap hareketleri',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            'Artı tutarlar alacağı artırır; eksi tutarlar azaltır. Hesaplar arasındaki dağılım değişiklikleri ayrıca gösterilir.',
          ),
          if (_entries.isEmpty)
            const MerchantNotice('Henüz hesap hareketin yok.'),
          for (final entry in _entries)
            _StatementCard(key: ValueKey(entry.id), entry: entry),
          if (value.nextBefore != null)
            OutlinedButton(
              onPressed: _busy ? null : () => _read(more: true),
              child: const Text('Önceki hareketleri yükle'),
            ),
        ],
      ],
    );
  }

  Widget _balanceLine(String title, BigInt amount) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text('$title: ${statementMoney(amount)}'),
  );
}

String _accountName(LedgerAccountKind kind) => switch (kind) {
  LedgerAccountKind.merchantReserve => 'Zorunlu rezerv',
  LedgerAccountKind.merchantCouponPending => 'Bekleyen kupon alacağı',
  LedgerAccountKind.merchantCouponAvailable =>
    'Beklemesi tamamlanan kupon alacağı',
  LedgerAccountKind.merchantUnusedPending => 'Bekleyen paket fonu alacağı',
  LedgerAccountKind.merchantUnusedAvailable =>
    'Beklemesi tamamlanan paket fonu alacağı',
  _ => throw StateError('Merchant account required'),
};
String _kindName(StatementKind kind) => switch (kind) {
  StatementKind.couponRedemption => 'Kupon kullanımı',
  StatementKind.unusedPackageFund => 'Kullanılmayan paket fonu',
  StatementKind.platformService => 'Platform hizmet bedeli',
  StatementKind.receivableRelease => 'Alacak beklemesi tamamlandı',
  StatementKind.reversal => 'Ters kayıt',
  StatementKind.rewardCompensation => 'Ödül düzeltmesi',
  StatementKind.returnEntry => 'İade düzeltmesi',
  StatementKind.offsetCreated => 'Mahsup kaydı',
  StatementKind.offsetRecovered => 'Mahsup işlemi',
  StatementKind.packageFunding ||
  StatementKind.rewardFunding => 'Paket fonu kaydı',
  StatementKind.rewardCapacity => 'Paket kontenjanı kaydı',
  StatementKind.rewardIssue => 'Ödül kaydı',
};

class _StatementCard extends StatelessWidget {
  const _StatementCard({super.key, required this.entry});
  final MerchantStatementEntry entry;
  @override
  Widget build(BuildContext context) {
    final date = entry.recordedAt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _kindName(entry.kind),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${two(date.day)}.${two(date.month)}.${date.year} • ${two(date.hour)}:${two(date.minute)}',
            ),
            const SizedBox(height: 8),
            Text(
              entry.net == BigInt.zero
                  ? 'Dağılım değişikliği'
                  : statementMoney(entry.net, signed: true),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            for (final movement in entry.movements.entries)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${_accountName(movement.key)}: ${statementMoney(movement.value, signed: true)}',
                ),
              ),
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('İşlem referansı'),
              children: [
                SelectableText('Kayıt: ${entry.id}'),
                if (entry.reverses != null)
                  SelectableText('Düzeltilen kayıt: ${entry.reverses}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
