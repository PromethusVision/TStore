import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/rewards/domain/reward_progress.dart';
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
            widget.currentUserIdProvider() == null)
          return;
      }
      if (mounted)
        await Navigator.of(
          context,
        ).push<void>(MaterialPageRoute(builder: (_) => const RewardCenter()));
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
            const SizedBox(height: 24),
            Text(
              'Hangi esnaflarda ilerleyebilirim?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (progress.merchants.isEmpty)
              const Text(
                'Katılımcı esnaflar henüz açıklanmadı. Uygun mağazalar ve katılım koşulları hazır olduğunda burada görünecek.',
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
            const Text('Ödül türü ve kazanma koşulları henüz belirlenmedi.'),
            const SizedBox(height: 24),
            Text(
              'Ödül geçmişi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Henüz bir ödül kaydı yok.'),
          ],
        ),
      ),
    ),
  );
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
  late final stream = (widget.repository ?? activeRewardRepository())
      .watchProgress(widget.customerId);
  @override
  Widget build(BuildContext context) => StreamBuilder<RewardProgress>(
    stream: stream,
    builder: (context, snapshot) => widget.builder(
      snapshot.hasError
          ? const RewardProgress()
          : snapshot.data ?? const RewardProgress(),
    ),
  );
}
