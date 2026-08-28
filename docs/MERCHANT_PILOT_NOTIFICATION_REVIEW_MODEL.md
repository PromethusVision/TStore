# Merchant Pilot Notifications, Reviews and Evaluations

State: `PROPOSED — MINIMUM VISIBILITY`

## Notifications

Pilot notificationları eylem odaklıdır: critical auth/security, shop state, listing freshness, catalog candidate, QR result ve support case. Push başarısızsa kritik state uygulama açılışında server projection'dan görülür; push authority değildir.

## Review visibility

- Product free-text review canonical product'a aittir; merchant profile feed'i yalnız projection olabilir.
- Merchant ayrı bir free-text review yazdıramaz.
- Structured shop evaluation product rating aggregate'ine karışmaz.
- Merchant pilotta verified review/evaluation özetini read-only görebilir.
- Customer review edit/delete olduğunda projection kaynak state'i izler; historical moderation/audit korunur.
- Merchant yorum metnini düzenleyemez, sıralayamaz veya olumsuz yorumu gizleyemez.
- Basit report/support case SHOULD; public reply DEFER edilebilir.

## Reputation boundary

Badge, composite score ve reputation dashboard pilot minimumu değildir. Ads harcaması, reward participation, quantity veya basket value merchant değerlendirmesine ağırlık vermez. Evaluation görünürse sample size ve “platform garantisi değildir” açıklaması bulunmalıdır.
