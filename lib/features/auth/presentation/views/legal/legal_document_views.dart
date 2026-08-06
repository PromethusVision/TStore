import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/auth/domain/legal/legal_document_versions.dart';

class KvkkInformationView extends StatelessWidget {
  const KvkkInformationView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalDocumentScaffold(
      title: 'KVKK Aydınlatma Metni',
      version: LegalDocumentVersions.privacyNotice,
      introduction:
          'Bu metin, Esnafta Var müşteri uygulamasını kullanırken kişisel '
          'verilerinizin hangi amaçlarla işlendiği hakkında sizi '
          'bilgilendirmek için hazırlanmıştır.',
      sections: [
        _LegalSectionData(
          title: '1. Veri sorumlusu',
          paragraphs: [
            '6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında veri '
                'sorumlusu Musaki Software’dir.',
            'İletişim: info@esnaftavar.com\n'
                'Adres: Esenler Teknopark, 15 Temmuz Mahallesi, '
                'Esenler/İstanbul',
          ],
        ),
        _LegalSectionData(
          title: '2. İşlenen kişisel veriler',
          paragraphs: [
            'Kimlik ve iletişim bilgileri: ad, soyad, e-posta adresi, telefon '
                'numarası ve eklemeyi seçtiğiniz profil fotoğrafı.',
            'Hesap ve güvenlik bilgileri: kullanıcı kimliği, hesap doğrulama, '
                'oturum ve güvenlik kayıtları.',
            'Konum bilgileri: yalnızca sizin isteğiniz ve cihaz izninizle '
                'alınan anlık konum ile özellikle kaydetmeyi seçtiğiniz '
                'konumlar.',
            'Müşteri işlem bilgileri: favoriler, sepet, mağazalarla yapılan '
                'mesajlaşmalar, QR ile doğrulanan alışverişler, '
                'değerlendirmeler ve bildirimler.',
            'Kullanım tercihleri: uygulamada son görüntülenen ürünler gibi '
                'müşteri deneyimini kolaylaştıran tercihler.',
          ],
        ),
        _LegalSectionData(
          title: '3. İşleme amaçları',
          paragraphs: [
            'Hesabınızı oluşturmak ve yönetmek; ürünleri ve yakındaki '
                'mağazaları keşfetmenizi sağlamak; sepet, favori, mesajlaşma '
                've bildirim özelliklerini sunmak.',
            'Mağazada yapılan alışverişi QR ile doğrulamak, alışveriş '
                'geçmişini göstermek, değerlendirme ve destek süreçlerini '
                'yürütmek.',
            'Uygulamanın güvenliğini, sürekliliğini ve kötüye kullanıma karşı '
                'korunmasını sağlamak.',
          ],
        ),
        _LegalSectionData(
          title: '4. Toplama yöntemi ve hukuki sebepler',
          paragraphs: [
            'Veriler; kayıt ve profil formlarından, uygulama içindeki '
                'işlemlerinizden ve yalnızca izin verdiğinizde cihaz '
                'özelliklerinden elektronik ortamda elde edilir.',
            'Veriler; sözleşmenin kurulması veya ifası, hukuki yükümlülük, '
                'bir hakkın tesisi, kullanılması veya korunması ve veri '
                'sorumlusunun meşru menfaati gibi KVKK’da yer alan işleme '
                'şartlarına dayanılarak işlenir. Açık rıza gereken ayrı bir '
                'işlem olursa ayrıca ve isteğe bağlı olarak talep edilir.',
          ],
        ),
        _LegalSectionData(
          title: '5. Verilerin aktarılması',
          paragraphs: [
            'Kişisel verileriniz; uygulamanın çalışması için gerekli ölçüde '
                'kimlik doğrulama, veritabanı, dosya saklama ve benzeri '
                'altyapı hizmeti sağlayıcılarıyla paylaşılabilir.',
            'Mesaj veya QR doğrulama gibi sizin başlattığınız işlemlerde, '
                'yalnızca işlemin gerektirdiği bilgiler ilgili mağazayla '
                'paylaşılabilir. Kanuni zorunluluk halinde yetkili kamu '
                'kurumlarıyla paylaşım yapılabilir.',
            'Kullanılan altyapı hizmetlerinin yurt dışında sunulması halinde '
                'aktarım süreçleri KVKK’nın yurt dışı aktarıma ilişkin '
                'hükümleri kapsamında yürütülür.',
          ],
        ),
        _LegalSectionData(
          title: '6. Saklama ve güvenlik',
          paragraphs: [
            'Verileriniz yalnızca işleme amacı ve ilgili yasal yükümlülükler '
                'için gerekli süre boyunca saklanır. Süre sonunda silinir, '
                'yok edilir veya anonim hale getirilir.',
            'Yetkisiz erişimi, kaybı ve kötüye kullanımı önlemek için uygun '
                'teknik ve idari tedbirler uygulanır.',
          ],
        ),
        _LegalSectionData(
          title: '7. Haklarınız',
          paragraphs: [
            'KVKK’nın 11. maddesi kapsamında kişisel verilerinizin işlenip '
                'işlenmediğini öğrenme, bilgi isteme, düzeltme, silme veya '
                'yok edilmesini isteme ve kanunda belirtilen diğer haklara '
                'sahipsiniz.',
            'Taleplerinizi kimliğinizi doğrulamaya elverişli bilgilerle '
                'info@esnaftavar.com adresine iletebilirsiniz.',
          ],
        ),
      ],
    );
  }
}

class TermsOfUseView extends StatelessWidget {
  const TermsOfUseView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalDocumentScaffold(
      title: 'Kullanım Koşulları',
      version: LegalDocumentVersions.termsOfUse,
      introduction:
          'Bu koşullar, Musaki Software tarafından sunulan Esnafta Var '
          'müşteri uygulamasının kullanımına ilişkin temel kuralları açıklar.',
      sections: [
        _LegalSectionData(
          title: '1. Hizmetin kapsamı',
          paragraphs: [
            'Esnafta Var, müşterilerin çevredeki fiziksel mağazalarda bulunan '
                'ürünleri keşfetmesine, mağaza bilgilerine ulaşmasına ve '
                'mağazayla iletişim kurmasına yardımcı olan bir platformdur.',
            'Uygulama üzerinden gösterilen QR, ödeme aracı değildir. QR '
                'akışı mağazada gerçekleşen alışverişin doğrulanması için '
                'kullanılır.',
          ],
        ),
        _LegalSectionData(
          title: '2. Üyelik ve hesap güvenliği',
          paragraphs: [
            'Kayıt sırasında doğru ve güncel bilgi vermeniz, hesap '
                'bilgilerinizi korumanız ve hesabınızda gerçekleşen '
                'işlemleri kontrol etmeniz gerekir.',
            'Yetkisiz kullanım şüphesinde info@esnaftavar.com adresinden '
                'bizimle iletişime geçmelisiniz.',
          ],
        ),
        _LegalSectionData(
          title: '3. Ürün ve mağaza bilgileri',
          paragraphs: [
            'Ürün, fiyat, stok, çalışma saati ve mağaza bilgileri ilgili '
                'mağaza tarafından sağlanabilir ve zaman içinde değişebilir.',
            'Müşteri, mağazaya gitmeden önce güncel fiyat ve stok bilgisini '
                'mağazadan teyit etmelidir. Satış sözleşmesi ve ödeme, '
                'müşteri ile ilgili mağaza arasında gerçekleşir.',
          ],
        ),
        _LegalSectionData(
          title: '4. Kullanım kuralları',
          paragraphs: [
            'Uygulamayı hukuka aykırı, yanıltıcı, taciz edici veya başkalarının '
                'haklarını ihlal eden amaçlarla kullanamazsınız.',
            'Sistemin güvenliğini bozmak, sahte hesap veya işlem oluşturmak, '
                'QR doğrulama akışını kötüye kullanmak ve diğer kullanıcıların '
                'deneyimini engellemek yasaktır.',
          ],
        ),
        _LegalSectionData(
          title: '5. Mesajlar ve değerlendirmeler',
          paragraphs: [
            'Mağazalara gönderdiğiniz mesajlar ve yaptığınız '
                'değerlendirmeler gerçeğe uygun, saygılı ve hukuka uygun '
                'olmalıdır.',
            'Hukuka aykırı veya kötüye kullanım niteliğindeki içerikler '
                'incelenebilir, kaldırılabilir ve ilgili hesap kısıtlanabilir.',
          ],
        ),
        _LegalSectionData(
          title: '6. Hizmet değişiklikleri',
          paragraphs: [
            'Uygulamanın güvenliği, sürekliliği ve geliştirilmesi için '
                'özelliklerde değişiklik veya geçici bakım yapılabilir.',
            'Kullanım koşullarında önemli bir değişiklik olduğunda yeni sürüm '
                'uygulama içinde yayımlanır ve gerektiğinde yeniden kabul '
                'istenir.',
          ],
        ),
        _LegalSectionData(
          title: '7. İletişim',
          paragraphs: [
            'Bu koşullar hakkındaki sorularınızı info@esnaftavar.com adresine '
                'iletebilirsiniz.',
            'Musaki Software\n'
                'Esenler Teknopark, 15 Temmuz Mahallesi, Esenler/İstanbul',
          ],
        ),
      ],
    );
  }
}

class _LegalDocumentScaffold extends StatelessWidget {
  const _LegalDocumentScaffold({
    required this.title,
    required this.version,
    required this.introduction,
    required this.sections,
  });

  final String title;
  final String version;
  final String introduction;
  final List<_LegalSectionData> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-legal-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CustomerHomeV1Tokens.space16,
                    CustomerHomeV1Tokens.space8,
                    CustomerHomeV1Tokens.space16,
                    0,
                  ),
                  child: _LegalHeader(title: title),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space12),
                Expanded(
                  child: ListView(
                    key: const Key('customer-legal-list'),
                    padding: const EdgeInsets.fromLTRB(
                      CustomerHomeV1Tokens.space16,
                      CustomerHomeV1Tokens.space4,
                      CustomerHomeV1Tokens.space16,
                      CustomerHomeV1Tokens.space24,
                    ),
                    children: [
                      _LegalIntroductionCard(
                        introduction: introduction,
                        version: version,
                      ),
                      const SizedBox(height: CustomerHomeV1Tokens.space20),
                      for (var index = 0; index < sections.length; index++) ...[
                        _LegalSectionCard(
                          key: Key('customer-legal-section-$index'),
                          section: sections[index],
                        ),
                        if (index != sections.length - 1)
                          const SizedBox(height: CustomerHomeV1Tokens.space12),
                      ],
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
}

class _LegalHeader extends StatelessWidget {
  const _LegalHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-legal-header'),
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
          IconButton(
            key: const Key('customer-legal-back'),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Geri',
            style: IconButton.styleFrom(
              backgroundColor: CustomerHomeV1Tokens.mint,
              foregroundColor: CustomerHomeV1Tokens.petrol,
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: CustomerHomeV1Tokens.navy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space8),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE4DE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.policy_outlined,
              color: CustomerHomeV1Tokens.coral,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalIntroductionCard extends StatelessWidget {
  const _LegalIntroductionCard({
    required this.introduction,
    required this.version,
  });

  final String introduction;
  final String version;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-legal-introduction'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space20),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.petrol,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius24),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.white),
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space16),
          Text(
            introduction,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CustomerHomeV1Tokens.space12,
              vertical: CustomerHomeV1Tokens.space8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radiusPill,
              ),
            ),
            child: Text(
              'Metin sürümü: $version',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSectionCard extends StatelessWidget {
  const _LegalSectionCard({super.key, required this.section});

  final _LegalSectionData section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: CustomerHomeV1Tokens.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 19,
                  color: CustomerHomeV1Tokens.petrol,
                ),
              ),
              const SizedBox(width: CustomerHomeV1Tokens.space12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    section.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: CustomerHomeV1Tokens.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          for (var index = 0; index < section.paragraphs.length; index++) ...[
            SelectableText(
              section.paragraphs[index],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.55,
                color: CustomerHomeV1Tokens.muted,
              ),
            ),
            if (index != section.paragraphs.length - 1)
              const SizedBox(height: CustomerHomeV1Tokens.space12),
          ],
        ],
      ),
    );
  }
}

class _LegalSectionData {
  const _LegalSectionData({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;
}
