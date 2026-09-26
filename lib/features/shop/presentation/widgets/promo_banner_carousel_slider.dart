import 'dart:async';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/navigation/engagement_destination.dart';
import 'package:t_store/core/navigation/engagement_target.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/shop/domain/entities/banner_entity.dart';
import 'package:t_store/features/shop/domain/services/home_campaign_catalog.dart';
import 'package:t_store/features/shop/presentation/cubit/banners_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/banners_state.dart';

class PromoBannerCarouselSlider extends StatefulWidget {
  const PromoBannerCarouselSlider({
    super.key,
    this.onDiscover,
    this.autoAdvance = true,
  });
  final FutureOr<void> Function()? onDiscover;
  final bool autoAdvance;
  @override
  State<PromoBannerCarouselSlider> createState() =>
      _PromoBannerCarouselSliderState();
}

class _PromoBannerCarouselSliderState extends State<PromoBannerCarouselSlider>
    with WidgetsBindingObserver {
  final _pages = PageController();
  Timer? _timer;
  int _selected = 0, _count = 5;
  bool _touching = false, _focused = false, _opening = false, _resumed = true;
  bool get _reduceMotion =>
      MediaQuery.disableAnimationsOf(context) ||
      MediaQuery.accessibleNavigationOf(context);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<BannersCubit>().getBanners();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant PromoBannerCarouselSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    if (_resumed) setState(() {});
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    if (!mounted ||
        !_resumed ||
        _touching ||
        _focused ||
        !TickerMode.valuesOf(context).enabled) {
      return;
    }
    _timer = Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      setState(() {}); // Re-evaluate dates even when motion is disabled.
      if (widget.autoAdvance &&
          !_reduceMotion &&
          _count > 1 &&
          _pages.hasClients) {
        _pages.animateToPage(
          (_selected + 1) % _count,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
      _schedule();
    });
  }

  void _go(int page) {
    if (_reduceMotion) {
      _pages.jumpToPage(page);
    } else {
      _pages.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
    _schedule();
  }

  Future<void> _open(BannerEntity banner) async {
    if (_opening) return;
    if (!banner.isActiveAt(DateTime.now())) {
      setState(() {});
      return;
    }
    final target = EngagementTarget.parse(banner.actionType, banner.actionUrl);
    if (target == null) return;
    _opening = true;
    _timer?.cancel();
    try {
      if (widget.onDiscover != null) {
        await Future<void>.sync(widget.onDiscover!);
      } else {
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => EngagementDestination(target: target),
          ),
        );
      }
    } finally {
      _opening = false;
      if (mounted) _schedule();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pages.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<BannersCubit, BannersState>(
    builder: (context, state) {
      final campaigns = HomeCampaignCatalog.select(
        state is BannersLoaded ? state.banners : [],
        DateTime.now(),
      );
      _count = campaigns.length;
      if (_selected >= _count) {
        _selected = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pages.hasClients) _pages.jumpToPage(0);
        });
      }
      return Focus(
        onFocusChange: (focused) {
          _focused = focused;
          _schedule();
        },
        child: Listener(
          onPointerDown: (_) {
            _touching = true;
            _schedule();
          },
          onPointerUp: (_) {
            _touching = false;
            _schedule();
          },
          onPointerCancel: (_) {
            _touching = false;
            _schedule();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scaler = MediaQuery.textScalerOf(context);
              double measure(String text, double width, TextStyle style) {
                final p = TextPainter(
                  text: TextSpan(text: text, style: style),
                  textDirection: Directionality.of(context),
                  textScaler: scaler,
                )..layout(maxWidth: math.max(80, width));
                final h = p.height;
                p.dispose();
                return h;
              }

              var height = 230.0;
              for (final c in campaigns) {
                height = math.max(
                  height,
                  math.max(
                        56,
                        measure(
                          c.title!,
                          constraints.maxWidth - 120,
                          _titleStyle,
                        ),
                      ) +
                      measure(
                        c.subtitle!,
                        constraints.maxWidth - 40,
                        _bodyStyle,
                      ) +
                      112,
                );
              }
              return Column(
                key: const Key('customer-home-hero'),
                children: [
                  SizedBox(
                    height: height,
                    child: PageView.builder(
                      key: const Key('campaign-pages'),
                      controller: _pages,
                      itemCount: campaigns.length,
                      onPageChanged: (index) {
                        setState(() => _selected = index);
                        _schedule();
                      },
                      itemBuilder: (context, i) => Semantics(
                        label: 'Kampanya ${i + 1} / ${campaigns.length}',
                        container: true,
                        child: ExcludeSemantics(
                          excluding: i != _selected,
                          child: _CampaignCard(
                            campaign: campaigns[i],
                            index: i,
                            onTap: () => _open(campaigns[i]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (campaigns.length > 1)
                    SizedBox(
                      height: 44,
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < campaigns.length; i++)
                                SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Semantics(
                                    selected: i == _selected,
                                    child: IconButton(
                                      tooltip: '${i + 1}. kampanya',
                                      onPressed: () => _go(i),
                                      icon: Icon(
                                        i == _selected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        size: 14,
                                        color: EsnaftaVarColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

const _titleStyle = TextStyle(
  fontSize: 18,
  height: 1.2,
  fontWeight: FontWeight.w700,
  color: EsnaftaVarColors.textPrimary,
);
const _bodyStyle = TextStyle(
  fontSize: 13,
  height: 1.4,
  color: EsnaftaVarColors.textSecondary,
);

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({
    required this.campaign,
    required this.index,
    required this.onTap,
  });
  final BannerEntity campaign;
  final int index;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    const motifs = [
      Icons.storefront_rounded,
      Icons.compare_arrows_rounded,
      Icons.shopping_bag_outlined,
      Icons.route_rounded,
      Icons.search_rounded,
    ];
    final motif = ExcludeSemantics(
      child: Icon(
        motifs[index % motifs.length],
        size: 40,
        color: EsnaftaVarColors.primary,
      ),
    );
    return Container(
      key: ValueKey('campaign-${campaign.id}'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            EsnaftaVarDiscoveryColors.categorySurfaces[index %
                EsnaftaVarDiscoveryColors.categorySurfaces.length],
            EsnaftaVarColors.surfaceElevated,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(campaign.title!, style: _titleStyle)),
              const SizedBox(width: 16),
              SizedBox(
                width: 64,
                height: 56,
                child: campaign.imageUrl.isEmpty
                    ? motif
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: campaign.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => motif,
                          errorWidget: (_, _, _) => motif,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(campaign.subtitle!, style: _bodyStyle),
          const Spacer(),
          if (EngagementTarget.parse(campaign.actionType, campaign.actionUrl) !=
                  null &&
              campaign.ctaText?.isNotEmpty == true)
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                key: ValueKey('campaign-cta-${campaign.id}'),
                onPressed: onTap,
                child: Text(campaign.ctaText!, textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }
}
