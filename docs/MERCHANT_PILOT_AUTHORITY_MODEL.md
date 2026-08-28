# Merchant Pilot Authority Model

State: `PROPOSED — SERVER-AUTHORITATIVE`

## Yetki denklemi

Bir merchant işlemi ancak şu koşulların tamamı geçerliyse yapılabilir:

`authenticated user` + `active merchant profile` + `active exact-shop association` + `required capability` + `shop verified/active` + `policy eligible` + `current revision/session`.

Hiçbir claim, ekran görünürlüğü, route guard veya `profiles.role = merchant` tek başına yetki değildir.

## Pilot minimumu

- Bir auth user en fazla bir pilot shop için `OWNER` preset'iyle başlar.
- Backend kavramsal olarak shop-scoped membership/capability modeline hazır olmalıdır; UI staff yönetimi sunmaz.
- Minimum capabilities: `SHOP_VIEW`, `SHOP_BASIC_EDIT`, `LISTING_VIEW`, `LISTING_MANAGE`, `QR_VERIFY`, `HISTORY_VIEW`, `SUPPORT_CREATE`.
- `MEMBERSHIP_MANAGE`, `STAFF_MANAGE`, `ANALYTICS_VIEW`, `ADS_MANAGE`, `REWARD_MANAGE` pilotta yoktur.
- Owner ilişkisi revoke/suspend olduğunda mevcut session bir sonraki hassas çağrıda fail-closed olur.

## Single-owner seçeneği

İlk cohort yalnız tek-owner shops ile sınırlandırılabilir. Bu, şema veya RPC'yi yalnız global role mantığına kilitleme gerekçesi değildir. Kasada shared password yasaktır; shop birden çok kasa kullanacaksa multi-staff özelliği açılana kadar cohort dışında kalır veya her cihaz owner tarafından güvenli yönetilir.

## Yetki olayları

Grant, revoke, suspend, shop change ve policy change actor/reason/evidence/before/after ile audit edilir. Operatör kendi hesabını merchant üyesi yapamaz; destek ekibi şifre veya OTP istemez. Yetki değişikliği ile aynı anda açık QR preview'in confirm edilmesi sunucu tarafından yeniden yetkilendirilir.

## Failure behavior

- Session değişti: local state temizlenir, yeniden giriş istenir.
- Shop inactive/suspended: tüm mutation ve QR confirm reddedilir.
- Capability eksik: güvenli açıklama + correlation ID; veri sızıntısı yok.
- Birden fazla shop döndü: pilot UI rastgele seçmez; güvenli seçim veya ops review gerekir.
- Membership belirsiz: allow değil deny.

