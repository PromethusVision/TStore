import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        children: [
          Container(
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  introduction,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: TSizes.sm),
                Text(
                  'Metin sürümü: $version',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
          for (final section in sections) ...[
            Text(
              section.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: TSizes.sm),
            for (final paragraph in section.paragraphs) ...[
              SelectableText(
                paragraph,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: TSizes.sm),
            ],
            const SizedBox(height: TSizes.spaceBtwItems),
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
