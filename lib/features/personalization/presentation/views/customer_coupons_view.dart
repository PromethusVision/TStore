import 'package:flutter/material.dart';
import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:t_store/core/ui/components/esnaftavar_section_header.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/components/esnaftavar_surface_icon_button.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

class CustomerCouponsView extends StatelessWidget {
  const CustomerCouponsView({super.key});
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: EsnaftaVarScaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          key: const Key('customer-coupons-content'),
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  key: const Key('customer-coupons-header'),
                  children: [
                    MergeSemantics(
                      child: EsnaftaVarSurfaceIconButton(
                        buttonKey: const Key('customer-coupons-back-button'),
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Geri',
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: EsnaftaVarSectionHeader(
                        title: 'Kuponlarım',
                        subtitle: 'Kullanılabilir kuponlar ve geçmiş',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: EsnaftaVarColors.surface,
                    border: Border.all(color: EsnaftaVarColors.borderDefault),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    key: const Key('customer-coupons-tab-bar'),
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: EsnaftaVarColors.textOnPrimary,
                    unselectedLabelColor: EsnaftaVarColors.textSecondary,
                    indicator: BoxDecoration(
                      color: EsnaftaVarColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tabs: const [
                      Tab(
                        key: Key('available-coupons-tab'),
                        height: 48,
                        text: 'Kullanılabilir',
                      ),
                      Tab(
                        key: Key('coupon-history-tab'),
                        height: 48,
                        text: 'Geçmiş',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: TabBarView(
                  children: [
                    _CouponEmptyState(
                      key: Key('available-coupons-empty-state'),
                      icon: Icons.local_offer_outlined,
                      title: 'Henüz kullanılabilir kuponun yok',
                      description:
                          'Sana tanımlanan ve kullanıma açılan kuponlar burada görünecek.',
                    ),
                    _CouponEmptyState(
                      key: Key('coupon-history-empty-state'),
                      icon: Icons.history_rounded,
                      title: 'Kupon geçmişin boş',
                      description:
                          'Kullandığın veya süresi dolan kuponları daha sonra buradan görebileceksin.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CouponEmptyState extends StatelessWidget {
  const _CouponEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        EsnaftaVarStateCard(icon: icon, title: title, message: description),
        const SizedBox(height: 16),
        const Text(
          'Kupon kullanımı henüz açık değil.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
