import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/rewards/domain/reward_progress.dart';
import 'package:t_store/features/rewards/domain/reward_program.dart';
import 'package:t_store/features/rewards/presentation/reward_counter_card.dart';

RewardRepository activeRewardRepository() => sl.isRegistered<RewardRepository>()
    ? sl<RewardRepository>()
    : const PendingRewardRepository();
String? rewardCustomerId() {
  try {
    return SupabaseService.instance.currentUser?.id;
  } catch (_) {
    return null;
  }
}

class HomeRewardCounter extends StatefulWidget {
  const HomeRewardCounter({
    super.key,
    this.onTap,
    this.currentUserIdProvider = rewardCustomerId,
  });
  final VoidCallback? onTap;
  final String? Function() currentUserIdProvider;
  @override
  State<HomeRewardCounter> createState() => _HomeRewardCounterState();
}

class _HomeRewardCounterState extends State<HomeRewardCounter> {
  bool _opening = false;
  Future<void> _open() async {
    if (_opening) return;
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    _opening = true;
    try {
      if (widget.currentUserIdProvider() == null) {
        final signedIn = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) =>
                const LoginView(returnToCallerAfterCustomerLogin: true),
          ),
        );
        if (!mounted ||
            signedIn != true ||
            widget.currentUserIdProvider() == null) {
          return;
        }
      }
      if (mounted) {
        await Navigator.of(
          context,
        ).push<void>(MaterialPageRoute(builder: (_) => const RewardCenter()));
      }
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (context, state) {
      final id = state is AuthAuthenticated ? state.user.id : null;
      return _RewardSubscription(
        key: ValueKey(id),
        customerId: id,
        builder: (progress) =>
            RewardCounterCard(progress: progress, onTap: _open),
      );
    },
  );
}

class RewardCenter extends StatelessWidget {
  const RewardCenter({super.key, this.repository, this.customerId});
  final RewardRepository? repository;
  final String? customerId;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ödül Merkezi')),
    body: _RewardSubscription(
      repository: repository,
      customerId: customerId ?? rewardCustomerId(),
      builder: (progress) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RewardCounterCard(progress: progress),
            if (!progress.loading && progress.error == null) ...[
              const SizedBox(height: 24),
              Text(
                'Hangi esnaflarda ilerleyebilirim?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (progress.merchants.isEmpty)
                Text(
                  progress.program == null
                      ? 'Katılımcı esnaflar henüz açıklanmadı. Uygun mağazalar ve katılım koşulları hazır olduğunda burada görünecek.'
                      : 'Şu anda ödül kontenjanı uygun bir mağaza bulunamadı. Daha sonra yeniden kontrol edebilirsiniz.',
                ),
              for (final merchant in progress.merchants)
                ListTile(
                  leading: MerchantLogoBubbles(merchants: [merchant]),
                  title: Text(merchant.name),
                ),
              const SizedBox(height: 24),
              Text(
                'Ödül detayları',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (progress.program == null)
                const Text('Ödül türü ve kazanma koşulları henüz belirlenmedi.')
              else ...[
                const Text(
                  'Beş uygun alışverişin bekleme süreleri tamamlandığında kupon oluşturulur. Bekleyen tutar henüz kupon değildir.',
                ),
                Text(
                  'Bekleyen kazanım: ${rewardMoney(progress.program!.pending)}',
                ),
                Text(
                  'Oluşturulan kupon değeri: ${rewardMoney(progress.program!.couponValue)}',
                ),
                Text(
                  progress.program!.checkoutEnabled
                      ? 'Kupon tutarını sepetinizde QR oluşturmadan önce onaylayabilirsiniz. Kuponlar para çekme veya transfer için kullanılamaz.'
                      : 'Kupon harcama henüz açılmadı. Kuponlar para çekme veya transfer için kullanılamaz.',
                ),
                if ((progress.program!.futureOffset?.value ?? BigInt.zero) >
                    BigInt.zero)
                  Text(
                    'Gelecek ödüllerden karşılanacak düzeltme: ${rewardMoney(progress.program!.futureOffset!)}. Bu bir nakit borcu değildir; olgunlaşan sonraki kupon tutarından karşılanır.',
                  ),
              ],
              const SizedBox(height: 24),
              Text(
                'Ödül geçmişi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (progress.program?.history.isNotEmpty != true)
                const Text('Henüz bir ödül kaydı yok.'),
              for (final earning
                  in progress.program?.history ?? <RewardEarning>[])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    !earning.valid
                        ? 'Kazanım geri alındı'
                        : earning.issued
                        ? 'Kupona aktarıldı'
                        : 'Olgunlaşma bekleniyor',
                  ),
                  subtitle: Text(
                    'Alışveriş: ${_rewardDate(earning.earnedAt)}\nBekleme sonu: ${_rewardDate(earning.maturesAt)}',
                  ),
                ),
              for (final coupon
                  in progress.program?.coupons ?? <RewardCoupon>[])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.confirmation_number_outlined),
                  title: Text('Kupon: ${rewardMoney(coupon.remaining)}'),
                  subtitle: Text(_rewardDate(coupon.issuedAt)),
                ),
            ],
            if ((repository ?? activeRewardRepository())
                case final RewardProgramRepository program)
              TextButton(
                onPressed: program.refresh,
                child: const Text('Ödül bilgilerini yenile'),
              ),
          ],
        ),
      ),
    ),
  );
}

String _rewardDate(DateTime value) {
  final v = value.toLocal();
  return '${v.day.toString().padLeft(2, '0')}.${v.month.toString().padLeft(2, '0')}.${v.year} ${v.hour.toString().padLeft(2, '0')}:${v.minute.toString().padLeft(2, '0')}';
}

class _RewardSubscription extends StatefulWidget {
  const _RewardSubscription({
    super.key,
    required this.customerId,
    required this.builder,
    this.repository,
  });
  final String? customerId;
  final RewardRepository? repository;
  final Widget Function(RewardProgress) builder;
  @override
  State<_RewardSubscription> createState() => _RewardSubscriptionState();
}

class _RewardSubscriptionState extends State<_RewardSubscription> {
  late Stream<RewardProgress> stream;
  int generation = 0;
  bool get program =>
      (widget.repository ?? activeRewardRepository())
          is RewardProgramRepository;
  @override
  void initState() {
    super.initState();
    stream = (widget.repository ?? activeRewardRepository()).watchProgress(
      widget.customerId,
    );
  }

  @override
  void didUpdateWidget(_RewardSubscription oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerId != widget.customerId ||
        oldWidget.repository != widget.repository) {
      generation++;
      stream = (widget.repository ?? activeRewardRepository()).watchProgress(
        widget.customerId,
      );
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<RewardProgress>(
    key: ValueKey(generation),
    stream: stream,
    builder: (context, snapshot) => widget.builder(
      snapshot.hasError
          ? const RewardProgress(error: 'Ödül bilgileri yüklenemedi.')
          : snapshot.data ?? RewardProgress(loading: program),
    ),
  );
}
