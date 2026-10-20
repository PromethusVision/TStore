import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';
import 'package:t_store/features/rewards/domain/reward_program.dart';
import 'package:t_store/features/rewards/presentation/reward_view_session.dart';

class MerchantRewardEntry extends StatefulWidget {
  const MerchantRewardEntry({
    super.key,
    required this.services,
    required this.access,
  });
  final MerchantServices services;
  final MerchantAccess access;
  @override
  State<MerchantRewardEntry> createState() => _MerchantRewardEntryState();
}

class _MerchantRewardEntryState extends State<MerchantRewardEntry> {
  late RewardViewSession _session;
  bool _opening = false;
  @override
  void initState() {
    super.initState();
    _bind();
  }

  void _bind() {
    _session = RewardViewSession(
      repository: widget.services.rewardProgram!,
      owner: widget.access.user.id,
      currentUser: widget.services.currentUserId,
      changes: widget.services.sessionChanges,
      onLost: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void didUpdateWidget(MerchantRewardEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.services.rewardProgram != widget.services.rewardProgram ||
        oldWidget.access.shop?.id != widget.access.shop?.id ||
        oldWidget.access.user.id != widget.access.user.id ||
        widget.services.currentUserId() != widget.access.user.id) {
      _session.retire();
    }
  }

  @override
  void dispose() {
    _session.close();
    super.dispose();
  }

  Future<void> _open() async {
    if (_opening || !_session.check()) return;
    _opening = true;
    final origin = _session;
    final page = MerchantRewardsView(
      repository: widget.services.rewardProgram!,
      shopId: widget.access.shop!.id,
      ownerId: widget.access.user.id,
      currentUserId: widget.services.currentUserId,
      sessionChanges: widget.services.sessionChanges,
      originIsCurrent: () => mounted && origin.current,
    );
    try {
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute(builder: (_) => page));
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) => !_session.current
      ? const SizedBox.shrink()
      : Card(
          child: ListTile(
            leading: const Icon(Icons.card_giftcard_outlined),
            title: const Text('Yönlendirme paketi'),
            subtitle: const Text('Kazanım kontenjanı ve kupon kabul tercihi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _open,
          ),
        );
}

class MerchantRewardsView extends StatefulWidget {
  const MerchantRewardsView({
    super.key,
    required this.repository,
    required this.shopId,
    required this.ownerId,
    required this.currentUserId,
    required this.sessionChanges,
    this.originIsCurrent,
  });
  final RewardProgramRepository repository;
  final String shopId, ownerId;
  final String? Function() currentUserId;
  final Stream<String?> sessionChanges;
  final bool Function()? originIsCurrent;
  @override
  State<MerchantRewardsView> createState() => _MerchantRewardsViewState();
}

class _MerchantRewardsViewState extends State<MerchantRewardsView>
    with WidgetsBindingObserver {
  MerchantRewardState? _value;
  RewardProgramCapabilities? _caps;
  String? _error;
  bool _busy = false;
  int _generation = 0;
  late RewardViewSession _session;
  bool get _current => _session.current;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bind();
    _read();
  }

  void _bind() {
    _session = RewardViewSession(
      repository: widget.repository,
      owner: widget.ownerId,
      currentUser: widget.currentUserId,
      changes: widget.sessionChanges,
      originIsCurrent: widget.originIsCurrent,
      onLost: () {
        if (!mounted) return;
        _generation++;
        setState(() {
          _value = null;
          _caps = null;
          _busy = false;
          _error = null;
        });
      },
    );
  }

  @override
  void didUpdateWidget(MerchantRewardsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUserId() != widget.ownerId) {
      _session.retire();
      return;
    }
    if (oldWidget.repository != widget.repository ||
        oldWidget.shopId != widget.shopId ||
        oldWidget.ownerId != widget.ownerId) {
      final mayRebind = _session.current && oldWidget.ownerId == widget.ownerId;
      _session.close();
      _generation++;
      _busy = false;
      _value = null;
      _caps = null;
      _error = null;
      if (mayRebind) {
        _bind();
        _read();
      }
    } else {
      _session.check();
    }
  }

  @override
  void dispose() {
    _generation++;
    _session.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _read();
  }

  Future<void> _read() async {
    if (!_session.check() || _busy) return;
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
      _value = null;
      _caps = null;
    });
    bool live() => mounted && generation == _generation && _session.check();
    try {
      final repository = widget.repository, shop = widget.shopId;
      final result = await (() async {
        final caps = await repository.capabilities();
        if (!live()) return null;
        if (caps.isLeft()) {
          return (caps, null);
        }
        final value = await repository.readMerchant(shop);
        return (caps, value);
      })().timeout(const Duration(seconds: 15));
      if (!live() || result == null) return;
      setState(() {
        result.$1.fold((error) => _error = error, (c) => _caps = c);
        result.$2?.fold((error) => _error = error, (v) => _value = v);
      });
    } catch (_) {
      if (live()) {
        setState(() {
          _error = 'Bilgiler yüklenemedi. Güncel durumu yeniden kontrol edin.';
        });
      }
    } finally {
      if (live()) {
        setState(() {
          _busy = false;
          _generation++;
        });
      }
    }
  }

  Future<void> _set(bool preferred) async {
    final current = _value;
    if (!_session.check() ||
        _busy ||
        current == null ||
        current.forced ||
        !current.enabled ||
        _caps?.enabled != true) {
      return;
    }
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await widget.repository.setAcceptance(
        widget.shopId,
        preferred,
        current.revision,
      );
      if (!mounted || generation != _generation || !_session.check()) return;
      setState(() {
        _busy = false;
        result.fold((error) {
          _error = error;
          _value = null;
        }, (value) => _value = value);
      });
    } catch (_) {
      if (mounted && generation == _generation && _session.check()) {
        setState(() {
          _busy = false;
          _value = null;
          _error =
              'İşlem sonucu doğrulanamadı. Güncel durumu yeniden kontrol edin.';
        });
      }
    }
  }

  static String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_current) {
      return const Scaffold(
        body: Center(child: Text('Oturumunuz değişti. Bu ekranı kapatın.')),
      );
    }
    final value = _value, caps = _caps;
    return MerchantPage(
      title: 'Yönlendirme paketi',
      onRefresh: _read,
      actions: [
        IconButton(
          onPressed: _busy ? null : _read,
          tooltip: 'Yenile',
          icon: const Icon(Icons.refresh),
        ),
      ],
      children: [
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          MerchantNotice(_error!, error: true, onRetry: _busy ? null : _read),
        if (caps != null)
          MerchantSection(
            title: 'Paket koşulları',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${caps.packageSlots} uygun alışveriş için ${rewardMoney(caps.packageFund)} ödül fonu',
                ),
                Text('Hizmet bedeli: ${rewardMoney(caps.packageFee)}'),
                Text(
                  'Paket süresi: ${Duration(seconds: caps.packageSeconds).inDays} gün',
                ),
                Text('Kazanım eşiği: ${rewardMoney(caps.minimum)}'),
                const SizedBox(height: 8),
                const Text(
                  'Paket satın alma henüz açılmadı. Bu ekrandan ödeme alınmaz.',
                ),
              ],
            ),
          ),
        if (value != null) ...[
          if (!value.enabled)
            const MerchantNotice(
              'Yeni ödül kazanımları şu anda açık değil. Mevcut kayıtları aşağıda inceleyebilirsiniz.',
            ),
          MerchantSection(
            title: 'EV kupon kabulü',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Kupon kabul tercihi'),
                  value: value.effective,
                  onChanged:
                      _busy ||
                          !value.enabled ||
                          caps?.enabled != true ||
                          value.forced
                      ? null
                      : _set,
                ),
                Text(
                  value.forced
                      ? 'Aktif paket veya açık rezervasyon sürdüğü için kabul açık tutulur.'
                      : 'Paket yükümlülüğü kalmadığında kabul tercihini değiştirebilirsiniz.',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kupon harcama henüz kullanıma açılmadı. Bu tercih tek başına harcama yetkisi vermez.',
                ),
              ],
            ),
          ),
          if (value.packages.isEmpty)
            const MerchantNotice('Henüz açılmış bir yönlendirme paketi yok.'),
          for (final package in value.packages)
            MerchantSection(
              title: package.expired ? 'Süresi dolan paket' : 'Aktif paket',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_date(package.activatedAt)} – ${_date(package.expiresAt)}',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      Text('Kalan: ${package.free}'),
                      Text('Ayrılan: ${package.held}'),
                      Text('Kazanılan: ${package.consumed}'),
                      Text('Süresi dolan: ${package.refunded}'),
                    ],
                  ),
                  if (package.expired && package.held > 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Açık işlemlerin ayrılan kontenjanı kısa tamamlama süresi sonuna kadar korunur.',
                      ),
                    ),
                  if (package.refunded > 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Kullanılmayan fon alacak olarak kaydedilir. Bu kayıt banka ödemesi yapıldığı anlamına gelmez. Hizmet bedeli buna dahil değildir.',
                      ),
                    ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
