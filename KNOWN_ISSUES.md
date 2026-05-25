# KNOWN_ISSUES

- Bilinen açık konular:
  1. Bazı profil ekranı bilgileri gerçek Supabase kullanıcısından değil, TStore demo/stock verilerinden geliyor olabilir.
  2. NavigationMenu guest guard bazı branch’lerde kaybolmuş olabilir; aktif branch’te kontrol edilmeli.
  3. Add to Cart butonlarının bir kısmı UI’da var ama gerçek CartCubit.addToCart çağrısına bağlı olmayabilir.
  4. Sepet şu an klasik e-commerce mantığında; ileride QR doğrulama sepetine dönüştürülecek.
  5. Checkout, Payment, Shipping, Order metinleri ve akışları henüz Esnafta Var modeline göre dönüştürülmedi.
  6. Supabase RLS ve güvenlik politikaları prototip için geçici durumda; ileride sağlamlaştırılmalı.
  7. .env dosyası kesinlikle commit edilmemeli.
  8. Flutter generated_plugin dosyaları ve gereksiz platform değişiklikleri yanlışlıkla commit edilmemeli.
- Dikkat edilmesi gereken branch disiplini:
  - main sadece çalışan ve onaylanmış temel sürüm için kullanılmalı.
  - Her yeni iş feature/... branch’inde yapılmalı.
  - Commit öncesi değişen dosyalar tek tek kontrol edilmeli.
