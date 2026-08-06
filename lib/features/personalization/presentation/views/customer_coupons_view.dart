import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';

class CustomerCouponsView extends StatelessWidget {
  const CustomerCouponsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: CustomerHomeV1Tokens.cream,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              key: const Key('customer-coupons-content'),
              constraints: const BoxConstraints(maxWidth: 430),
              child: const Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      CustomerHomeV1Tokens.space16,
                      CustomerHomeV1Tokens.space8,
                      CustomerHomeV1Tokens.space16,
                      0,
                    ),
                    child: _CouponsHeader(),
                  ),
                  SizedBox(height: CustomerHomeV1Tokens.space12),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: CustomerHomeV1Tokens.space16,
                    ),
                    child: _CouponsTabBar(),
                  ),
                  SizedBox(height: CustomerHomeV1Tokens.space8),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _CouponEmptyState(
                          key: Key('available-coupons-empty-state'),
                          icon: Icons.local_offer_outlined,
                          accent: CustomerHomeV1Tokens.coral,
                          iconBackground: Color(0xFFFFE4DE),
                          eyebrow: 'KULLANILABİLİR KUPONLAR',
                          title: 'Henüz kullanılabilir kuponun yok',
                          description:
                              'Sana tanımlanan ve kullanıma açılan kuponlar burada görünecek.',
                        ),
                        _CouponEmptyState(
                          key: Key('coupon-history-empty-state'),
                          icon: Icons.history_rounded,
                          accent: CustomerHomeV1Tokens.petrol,
                          iconBackground: CustomerHomeV1Tokens.mint,
                          eyebrow: 'KUPON GEÇMİŞİ',
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
      ),
    );
  }
}

class _CouponsHeader extends StatelessWidget {
  const _CouponsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-coupons-header'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Row(
        children: [
          Material(
            color: CustomerHomeV1Tokens.mint,
            shape: const CircleBorder(),
            child: IconButton(
              key: const Key('customer-coupons-back-button'),
              tooltip: 'Geri',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: CustomerHomeV1Tokens.petrol,
                size: 21,
              ),
            ),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kuponlarım',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: CustomerHomeV1Tokens.space4),
                Text(
                  'Fırsatlarını ve kupon geçmişini takip et',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4DE),
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius12,
              ),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: CustomerHomeV1Tokens.coral,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponsTabBar extends StatelessWidget {
  const _CouponsTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-coupons-tab-bar'),
      height: 50,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space4),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        border: Border.all(color: CustomerHomeV1Tokens.border),
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: CustomerHomeV1Tokens.petrol,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: CustomerHomeV1Tokens.muted,
        labelStyle: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(key: Key('available-coupons-tab'), text: 'Kullanılabilir'),
          Tab(key: Key('coupon-history-tab'), text: 'Geçmiş'),
        ],
      ),
    );
  }
}

class _CouponEmptyState extends StatelessWidget {
  const _CouponEmptyState({
    super.key,
    required this.icon,
    required this.accent,
    required this.iconBackground,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color accent;
  final Color iconBackground;
  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            CustomerHomeV1Tokens.space16,
            CustomerHomeV1Tokens.space4,
            CustomerHomeV1Tokens.space16,
            CustomerHomeV1Tokens.space24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - CustomerHomeV1Tokens.space32)
                  .clamp(0, double.infinity)
                  .toDouble(),
            ),
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(CustomerHomeV1Tokens.space24),
                decoration: BoxDecoration(
                  color: CustomerHomeV1Tokens.surface,
                  borderRadius: BorderRadius.circular(
                    CustomerHomeV1Tokens.radius20,
                  ),
                  border: Border.all(color: CustomerHomeV1Tokens.border),
                  boxShadow: CustomerHomeV1Tokens.softShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        color: iconBackground,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, size: 31, color: accent),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space16),
                    Text(
                      eyebrow,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: accent,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space8),
                    Text(
                      description,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.muted,
                        fontSize: 12.5,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        CustomerHomeV1Tokens.space12,
                      ),
                      decoration: BoxDecoration(
                        color: CustomerHomeV1Tokens.cream,
                        borderRadius: BorderRadius.circular(
                          CustomerHomeV1Tokens.radius12,
                        ),
                        border: Border.all(color: CustomerHomeV1Tokens.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: CustomerHomeV1Tokens.petrol,
                            size: 18,
                          ),
                          SizedBox(width: CustomerHomeV1Tokens.space8),
                          Expanded(
                            child: Text(
                              'Yeni kuponlar tanımlandığında bu sayfada otomatik olarak görünecek.',
                              style: TextStyle(
                                color: CustomerHomeV1Tokens.muted,
                                fontSize: 10.5,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
      },
    );
  }
}
