import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/sizes.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Yardım ve Destek')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(TSizes.lg),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.support_agent_rounded,
                      size: 40,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    Text(
                      'Nasıl yardımcı olabiliriz?',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: TSizes.sm),
                    Text(
                      'Ürün bulma, yakındaki mağazalar ve alışveriş doğrulama '
                      'hakkındaki cevaplara buradan ulaşabilirsin.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: TSizes.sm),
                    Text(
                      'Kargo Bekleme, Esnafta Var.',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              Text(
                'Hızlı Yardım',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              _QuickHelpTile(
                key: const Key('help-purchases-action'),
                icon: Icons.receipt_long_outlined,
                title: 'Alışverişlerim',
                subtitle: 'Doğrulamalarını ve iade taleplerini görüntüle',
                onTap: onOpenPurchases,
              ),
              const SizedBox(height: TSizes.sm),
              _QuickHelpTile(
                key: const Key('help-messages-action'),
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Mesajlarım',
                subtitle: 'Mağazalarla yaptığın konuşmalara ulaş',
                onTap: onOpenMessages,
              ),
              const SizedBox(height: TSizes.sm),
              _QuickHelpTile(
                key: const Key('help-saved-locations-action'),
                icon: Icons.location_on_outlined,
                title: 'Kayıtlı Konumlarım',
                subtitle: 'Yakındaki sonuçlarda kullanılacak konumu yönet',
                onTap: onOpenSavedLocations,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              Text(
                'Sık Sorulan Sorular',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              const _FrequentlyAskedQuestions(),
              const SizedBox(height: TSizes.spaceBtwSections),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(TSizes.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: TSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daha fazla yardıma mı ihtiyacın var?',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: TSizes.xs),
                          Text(
                            'Resmî destek iletişim kanalı hazır olduğunda bu '
                            'sayfada yer alacak.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickHelpTile extends StatelessWidget {
  const _QuickHelpTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TSizes.md,
          vertical: TSizes.xs,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
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
          'Sepetindeki ürünleri mağazada doğrulatmak için “Alışverişi '
          'Doğrula” ekranındaki QR kodu kullanabilirsin. Bu QR kod bir ödeme '
          'yöntemi değildir.',
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
          'Hesap ekranındaki Alışverişlerim bölümünden “İade Taleplerim” ve '
          '“İade Talebi Oluştur” sekmelerine ulaşabilirsin.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < _questions.length; index++) ...[
            ExpansionTile(
              key: ValueKey('help-faq-$index'),
              tilePadding: const EdgeInsets.symmetric(horizontal: TSizes.md),
              childrenPadding: const EdgeInsets.fromLTRB(
                TSizes.md,
                0,
                TSizes.md,
                TSizes.md,
              ),
              title: Text(
                _questions[index].question,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _questions[index].answer,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (index != _questions.length - 1)
              Divider(height: 1, color: colorScheme.outlineVariant),
          ],
        ],
      ),
    );
  }
}
