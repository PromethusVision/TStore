import 'package:flutter/material.dart';
import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:t_store/core/ui/components/esnaftavar_section_header.dart';
import 'package:t_store/features/personalization/presentation/widgets/account_page_header.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

class HelpAndSupportView extends StatelessWidget {
  const HelpAndSupportView({
    super.key,
    required this.onOpenPurchases,
    required this.onOpenMessages,
    required this.onOpenSavedLocations,
  });

  final VoidCallback onOpenPurchases;
  final VoidCallback onOpenMessages;
  final VoidCallback onOpenSavedLocations;

  @override
  Widget build(BuildContext context) {
    return EsnaftaVarScaffold(
      safeAreaTop: false,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-help-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    EsnaftaVarSpacing.md,
                    EsnaftaVarSpacing.xs,
                    EsnaftaVarSpacing.md,
                    0,
                  ),
                  child: _HelpHeader(),
                ),
                const SizedBox(height: EsnaftaVarSpacing.sm),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('customer-help-scroll'),
                    padding: const EdgeInsets.fromLTRB(
                      EsnaftaVarSpacing.md,
                      EsnaftaVarSpacing.xxs,
                      EsnaftaVarSpacing.md,
                      EsnaftaVarSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _HelpHero(),
                        const SizedBox(height: EsnaftaVarSpacing.lg),
                        const _SectionTitle(
                          title: 'Hızlı Yardım',
                          subtitle: 'Sık kullanılan müşteri işlemleri',
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.sm),
                        _QuickHelpTile(
                          key: const Key('help-purchases-action'),
                          icon: Icons.receipt_long_outlined,
                          accent: EsnaftaVarColors.primary,
                          iconBackground: EsnaftaVarColors.primarySoft,
                          title: 'Alışverişlerim',
                          subtitle:
                              'Doğrulamalarını ve iade taleplerini görüntüle',
                          onTap: onOpenPurchases,
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.xs),
                        _QuickHelpTile(
                          key: const Key('help-messages-action'),
                          icon: Icons.chat_bubble_outline_rounded,
                          accent: EsnaftaVarColors.primary,
                          iconBackground: EsnaftaVarColors.primarySoft,
                          title: 'Mesajlarım',
                          subtitle: 'Mağazalarla yaptığın konuşmalara ulaş',
                          onTap: onOpenMessages,
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.xs),
                        _QuickHelpTile(
                          key: const Key('help-saved-locations-action'),
                          icon: Icons.location_on_outlined,
                          accent: EsnaftaVarColors.accent,
                          iconBackground: EsnaftaVarColors.accentSoft,
                          title: 'Kayıtlı Konumlarım',
                          subtitle:
                              'Yakındaki sonuçlarda kullanılacak konumu yönet',
                          onTap: onOpenSavedLocations,
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.lg),
                        const _SectionTitle(
                          title: 'Sık Sorulan Sorular',
                          subtitle: 'Esnafta Var kullanımı hakkında',
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.sm),
                        const _FrequentlyAskedQuestions(),
                        const SizedBox(height: EsnaftaVarSpacing.lg),
                        const _SupportContactCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpHeader extends StatelessWidget {
  const _HelpHeader();
  @override
  Widget build(BuildContext context) => const AccountPageHeader(
    key: Key('customer-help-header'),
    backKey: Key('customer-help-back-button'),
    title: 'Yardım ve Destek',
    subtitle: 'Soruların için doğru yerdesin',
  );
}

class _HelpHero extends StatelessWidget {
  const _HelpHero();
  @override
  Widget build(BuildContext context) => Container(
    key: const Key('customer-help-hero'),
    width: double.infinity,
    padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
    decoration: BoxDecoration(
      color: EsnaftaVarColors.primarySoft,
      borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nasıl yardımcı olabiliriz?',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: EsnaftaVarColors.primary),
        ),
        const SizedBox(height: EsnaftaVarSpacing.xs),
        Text(
          'Ürün bulma, yakındaki mağazalar ve alışveriş doğrulama hakkındaki cevaplara buradan ulaşabilirsin.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: EsnaftaVarSpacing.xs),
        Text(
          'Kargo Bekleme, Esnafta Var.',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) =>
      EsnaftaVarSectionHeader(title: title, subtitle: subtitle);
}

class _QuickHelpTile extends StatelessWidget {
  const _QuickHelpTile({
    super.key,
    required this.icon,
    required this.accent,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        child: Ink(
          padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
          decoration: BoxDecoration(
            color: EsnaftaVarColors.surface,
            borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
            border: Border.all(color: EsnaftaVarColors.borderDefault),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: accent, size: 21),
              ),
              const SizedBox(width: EsnaftaVarSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: EsnaftaVarColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: EsnaftaVarSpacing.xxs),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: EsnaftaVarColors.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: EsnaftaVarSpacing.xs),
              const Icon(
                Icons.chevron_right_rounded,
                color: EsnaftaVarColors.textSecondary,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FrequentlyAskedQuestions extends StatelessWidget {
  const _FrequentlyAskedQuestions();

  static const _questions = <({String question, String answer})>[
    (
      question: 'Esnafta Var nasıl çalışır?',
      answer:
          'Aradığın ürünü çevrendeki fiziksel mağazalarda bulmana, ürünü '
          'satan mağazaları karşılaştırmana ve seçtiğin mağazaya ulaşmana '
          'yardımcı olur.',
    ),
    (
      question: 'Bir ürünü satan mağazaları nasıl karşılaştırırım?',
      answer:
          'Ürün detayındaki satıcı listesinde mağazaları en ucuz, en pahalı, '
          'en yüksek puanlı veya en yakın olacak şekilde sıralayabilirsin.',
    ),
    (
      question: 'Yakındaki mağazalar hangi konuma göre gösterilir?',
      answer:
          'Mevcut GPS konumunu veya daha önce kaydettiğin konumlardan birini '
          'kullanabilirsin. Kayıtlı konumunu ana konum yaptığında yakındaki '
          'sonuçlar bu konuma göre yenilenir.',
    ),
    (
      question: 'Mağazayla nasıl iletişim kurarım?',
      answer:
          'Mağaza profilinden mesaj gönderebilir, mağazanın paylaştığı '
          'bilgilere göre telefonla arayabilir veya yol tarifi alabilirsin.',
    ),
    (
      question: 'Sepet ve QR ne işe yarar?',
      answer:
          'Sepetindeki ürünleri mağazada doğrulatmak için “QR kod oluştur” '
          'düğmesine dokunabilirsin. Oluşan QR kod bir ödeme yöntemi değildir.',
    ),
    (
      question: 'Alışverişimi nasıl doğrular ve mağazaya puan veririm?',
      answer:
          'Mağaza QR kodunu okutup alışverişi onayladığında alışveriş '
          'durumunda yeşil onay işareti görünür. Ardından mağazaya puan '
          'verebilirsin.',
    ),
    (
      question: 'İade taleplerime nereden ulaşırım?',
      answer:
          'Hesap ekranındaki Alışverişlerim bölümünden “İade Taleplerim” '
          'sekmesini görüntüleyebilirsin. Uygulama üzerinden iade talebi '
          'oluşturma henüz kullanıma açık değil.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-help-faq-list'),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < _questions.length; index++) ...[
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashColor: EsnaftaVarColors.primarySoft,
              ),
              child: ExpansionTile(
                key: ValueKey('help-faq-$index'),
                iconColor: EsnaftaVarColors.primary,
                collapsedIconColor: EsnaftaVarColors.textSecondary,
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: EsnaftaVarSpacing.md,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(
                  EsnaftaVarSpacing.md,
                  0,
                  EsnaftaVarSpacing.md,
                  EsnaftaVarSpacing.md,
                ),
                title: Text(
                  _questions[index].question,
                  style: const TextStyle(
                    color: EsnaftaVarColors.textPrimary,
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
                      decoration: BoxDecoration(
                        color: EsnaftaVarColors.background,
                        borderRadius: BorderRadius.circular(
                          EsnaftaVarRadii.medium,
                        ),
                      ),
                      child: Text(
                        _questions[index].answer,
                        style: const TextStyle(
                          color: EsnaftaVarColors.textSecondary,
                          fontSize: 12,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (index != _questions.length - 1)
              const Divider(height: 1, color: EsnaftaVarColors.borderDefault),
          ],
        ],
      ),
    );
  }
}

class _SupportContactCard extends StatelessWidget {
  const _SupportContactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-help-contact-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: EsnaftaVarColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mail_outline_rounded,
              color: EsnaftaVarColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: EsnaftaVarSpacing.sm),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daha fazla yardıma mı ihtiyacın var?',
                  style: TextStyle(
                    color: EsnaftaVarColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: EsnaftaVarSpacing.xxs),
                Text(
                  'Musaki Software destek ekibine e-posta ile ulaşabilirsin.',
                  style: TextStyle(
                    color: EsnaftaVarColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: EsnaftaVarSpacing.xs),
                SelectableText(
                  'info@esnaftavar.com',
                  style: TextStyle(
                    color: EsnaftaVarColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
