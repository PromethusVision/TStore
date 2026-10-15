import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';
import 'package:t_store/features/rewards/domain/reward_program.dart';

class MerchantRewardEntry extends StatelessWidget {
  const MerchantRewardEntry({
    super.key,
    required this.services,
    required this.access,
  });
  final MerchantServices services;
  final MerchantAccess access;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.card_giftcard_outlined),
      title: const Text('Yönlendirme paketi'),
      subtitle: const Text('Kazanım kontenjanı ve kupon kabul tercihi'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => MerchantRewardsView(
            repository: services.rewardProgram!,
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

class MerchantRewardsView extends StatefulWidget {
  const MerchantRewardsView({
    super.key,
    required this.repository,
    required this.shopId,
    required this.ownerId,
    required this.currentUserId,
    required this.sessionChanges,
  });
  final RewardProgramRepository repository;
  final String shopId, ownerId;
  final String? Function() currentUserId;
  final Stream<String?> sessionChanges;
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
  StreamSubscription<String?>? _auth;
  bool get _current => widget.currentUserId() == widget.ownerId;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _auth = widget.sessionChanges.listen((_) {
      if (!mounted) return;
      _generation++;
      setState(() {
        _value = null;
        _caps = null;
        _busy = false;
        _error = null;
      });
      if (_current) _read();
    });
    _read();
  }

  @override
  void dispose() {
    _generation++;
    _auth?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _read();
  }

  Future<void> _read() async {
    if (!_current || _busy) return;
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
    });
    final caps = await widget.repository.capabilities();
    if (!mounted || generation != _generation || !_current) return;
    final value = await widget.repository.readMerchant(widget.shopId);
    if (!mounted || generation != _generation || !_current) return;
    setState(() {
      _busy = false;
      caps.fold((error) {
        _caps = null;
        _error = error;
      }, (c) => _caps = c);
      value.fold((error) {
        _value = null;
        _error = error;
      }, (v) => _value = v);
    });
  }

  Future<void> _set(bool preferred) async {
    final current = _value;
    if (!_current ||
        _busy ||
        current == null ||
        current.forced ||
        !current.enabled) {
      return;
    }
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.repository.setAcceptance(
      widget.shopId,
      preferred,
      current.revision,
    );
    if (!mounted || generation != _generation || !_current) return;
    setState(() {
      _busy = false;
      result.fold((error) {
        _error = error;
        _value = null;
      }, (value) => _value = value);
    });
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
                  onChanged: _busy || !value.enabled || value.forced
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
