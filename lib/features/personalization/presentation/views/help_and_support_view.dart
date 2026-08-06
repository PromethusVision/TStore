import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';

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
    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-help-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    CustomerHomeV1Tokens.space16,
                    CustomerHomeV1Tokens.space8,
                    CustomerHomeV1Tokens.space16,
                    0,
                  ),
                  child: _HelpHeader(),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space12),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('customer-help-scroll'),
                    padding: const EdgeInsets.fromLTRB(
                      CustomerHomeV1Tokens.space16,
                      CustomerHomeV1Tokens.space4,
                      CustomerHomeV1Tokens.space16,
                      CustomerHomeV1Tokens.space24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _HelpHero(),
                        const SizedBox(height: CustomerHomeV1Tokens.space20),
                        const _SectionTitle(
                          title: 'Hızlı Yardım',
                          subtitle: 'Sık kullanılan müşteri işlemleri',
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space12),
                        _QuickHelpTile(
                          key: const Key('help-purchases-action'),
                          icon: Icons.receipt_long_outlined,
                          accent: CustomerHomeV1Tokens.petrol,
                          iconBackground: CustomerHomeV1Tokens.mint,
                          title: 'Alışverişlerim',
                          subtitle:
                              'Doğrulamalarını ve iade taleplerini görüntüle',
                          onTap: onOpenPurchases,
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space8),
                        _QuickHelpTile(
                          key: const Key('help-messages-action'),
                          icon: Icons.chat_bubble_outline_rounded,
                          accent: const Color(0xFF3F6E9C),
                          iconBackground: const Color(0xFFE6F0F9),
                          title: 'Mesajlarım',
                          subtitle: 'Mağazalarla yaptığın konuşmalara ulaş',
                          onTap: onOpenMessages,
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space8),
                        _QuickHelpTile(
                          key: const Key('help-saved-locations-action'),
                          icon: Icons.location_on_outlined,
                          accent: CustomerHomeV1Tokens.coral,
                          iconBackground: const Color(0xFFFFE4DE),
                          title: 'Kayıtlı Konumlarım',
                          subtitle:
                              'Yakındaki sonuçlarda kullanılacak konumu yönet',
                          onTap: onOpenSavedLocations,
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space20),
                        const _SectionTitle(
                          title: 'Sık Sorulan Sorular',
                          subtitle: 'Esnafta Var kullanımı hakkında',
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space12),
                        const _FrequentlyAskedQuestions(),
                        const SizedBox(height: CustomerHomeV1Tokens.space20),
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
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-help-header'),
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
              key: const Key('customer-help-back-button'),
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
                  'Yardım ve Destek',
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
                  'İhtiyacın olan cevaba kolayca ulaş',
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
              color: const Color(0xFFFFF0C7),
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius12,
              ),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Color(0xFFA66A00),
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpHero extends StatelessWidget {
  const _HelpHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-help-hero'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CustomerHomeV1Tokens.petrol, Color(0xFF0E817C)],
        ),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -18,
            bottom: -28,
            child: Icon(
              Icons.question_answer_outlined,
              color: Color(0x26FFFFFF),
              size: 112,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  size: 25,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space16),
              const Text(
                'Nasıl yardımcı olabiliriz?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: const Text(
                  'Ürün bulma, yakındaki mağazalar ve alışveriş doğrulama hakkındaki cevaplara buradan ulaşabilirsin.',
                  style: TextStyle(
                    color: Color(0xFFE7F3F1),
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CustomerHomeV1Tokens.space12,
                  vertical: CustomerHomeV1Tokens.space8,
                ),
                decoration: BoxDecoration(
                  color: CustomerHomeV1Tokens.yellow,
                  borderRadius: BorderRadius.circular(
                    CustomerHomeV1Tokens.radiusPill,
                  ),
                ),
                child: const Text(
                  'Kargo Bekleme, Esnafta Var.',
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
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
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        child: Ink(
          padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.surface,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
            border: Border.all(color: CustomerHomeV1Tokens.border),
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
              const SizedBox(width: CustomerHomeV1Tokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.muted,
                        fontSize: 10.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CustomerHomeV1Tokens.space8),
              const Icon(
                Icons.chevron_right_rounded,
                color: CustomerHomeV1Tokens.muted,
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
    return Container(
      key: const Key('customer-help-faq-list'),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        border: Border.all(color: CustomerHomeV1Tokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < _questions.length; index++) ...[
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashColor: CustomerHomeV1Tokens.mint,
              ),
              child: ExpansionTile(
                key: ValueKey('help-faq-$index'),
                iconColor: CustomerHomeV1Tokens.petrol,
                collapsedIconColor: CustomerHomeV1Tokens.muted,
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: CustomerHomeV1Tokens.space16,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(
                  CustomerHomeV1Tokens.space16,
                  0,
                  CustomerHomeV1Tokens.space16,
                  CustomerHomeV1Tokens.space16,
                ),
                title: Text(
                  _questions[index].question,
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        CustomerHomeV1Tokens.space12,
                      ),
                      decoration: BoxDecoration(
                        color: CustomerHomeV1Tokens.cream,
                        borderRadius: BorderRadius.circular(
                          CustomerHomeV1Tokens.radius12,
                        ),
                      ),
                      child: Text(
                        _questions[index].answer,
                        style: const TextStyle(
                          color: CustomerHomeV1Tokens.muted,
                          fontSize: 11,
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
              const Divider(height: 1, color: CustomerHomeV1Tokens.border),
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
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: CustomerHomeV1Tokens.mint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mail_outline_rounded,
              color: CustomerHomeV1Tokens.petrol,
              size: 22,
            ),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daha fazla yardıma mı ihtiyacın var?',
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: CustomerHomeV1Tokens.space4),
                Text(
                  'Musaki Software destek ekibine e-posta ile ulaşabilirsin.',
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 10.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: CustomerHomeV1Tokens.space8),
                SelectableText(
                  'info@esnaftavar.com',
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.petrol,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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
