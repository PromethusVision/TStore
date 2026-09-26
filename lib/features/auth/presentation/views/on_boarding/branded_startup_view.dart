import 'package:flutter/material.dart';
import 'package:t_store/core/common/widgets/customer_brand_logo.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

/// Static artwork respects reduced motion and never competes with deep links.
class BrandedStartupView extends StatelessWidget {
  const BrandedStartupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('customer-launch-loading'),
      backgroundColor: EsnaftaVarColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const motifs = [
                  Icons.storefront_outlined,
                  Icons.location_on_outlined,
                  Icons.shopping_bag_outlined,
                  Icons.search,
                  Icons.inventory_2_outlined,
                  Icons.route_outlined,
                ];
                return Wrap(
                  clipBehavior: Clip.hardEdge,
                  children: List.generate(
                    ((constraints.maxWidth / 84).ceil() *
                        (constraints.maxHeight / 84).ceil()),
                    (index) => SizedBox(
                      width:
                          constraints.maxWidth /
                          (constraints.maxWidth / 84).ceil(),
                      height: 84,
                      child: Icon(
                        motifs[index % motifs.length],
                        size: 25,
                        color: EsnaftaVarColors.primary.withValues(
                          alpha: 0.055,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Semantics(
                  label: 'EsnaftaVar açılıyor',
                  liveRegion: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CustomerBrandLogo(),
                      const SizedBox(height: 20),
                      Text(
                        'Kargo bekleme, EsnaftaVar',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: EsnaftaVarColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
