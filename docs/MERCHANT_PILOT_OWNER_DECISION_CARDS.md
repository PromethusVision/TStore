# Merchant Pilot Owner Decision Cards

State: `FAST REVIEW — CHOICES EMPTY`

## MPR-01 — Operating model

Question: Pilot tam app, minimum slice veya verifier ağırlıklı mı başlar?
Recommended: Model B; Model C yalnız time-boxed bootstrap.
Why: Yetki/listing/QR güvenini korurken dashboard ön yatırımını erteler.
Options: [ ] A Full App  [ ] B Minimum safe  [ ] C Assisted verifier

## MPR-02 — Cohort complexity

Question: İlk cohort tek-owner/tek-shop ile mi sınırlandırılır?
Recommended: Evet; staff/multi-branch gerçek ihtiyaçla açılır.
Why: Shared credential ve yanlış shop riskini azaltır.
Options: [ ] A Single-owner only  [ ] B Limited staff  [ ] C Broad cohort

## MPR-03 — Listing truth

Question: Merchant minimum hangi veriyi kendi günceller?
Recommended: Price + availability/unknown + freshness; verified identity fields reviewed.
Why: Operatör darboğazı olmadan customer truth korunur.
Options: [ ] A Core self-service  [ ] B Operator-only  [ ] C Full catalog editor

## MPR-04 — Catalog candidate

Question: Bulunmayan ürün merchant tarafından aday gönderilebilir mi?
Recommended: Basit candidate + manual review; auto-publish yok.
Why: Pilot catalog öğrenmesi sağlar, canonical truth'u korur.
Options: [ ] A Submit+review  [ ] B Operator only  [ ] C Defer

## MPR-05 — QR rollout

Question: QR tüm cohortta mı, staged subsette mi açılır?
Recommended: Fiziksel/concurrency gates sonrası staged subset.
Why: Çekirdek ticari kanıtı kontrollü ölçer.
Options: [ ] A All cohort  [ ] B Staged  [ ] C Defer

## MPR-06 — Verification/policy

Question: İlk pilot hangi sektör/ürünleri kabul eder?
Recommended: Ordinary allowlist; unknown/regulated fail-closed.
Why: Küçük pilotu uzman inceleme yüküyle boğmadan gerçek riski dışarıda tutar.
Options: [ ] A Ordinary allowlist  [ ] B Specialist allowlist  [ ] C Broad

## MPR-07 — Review surface

Question: Merchant review/evaluation için ne görür/yapar?
Recommended: Read-only + simple report; reply/badge defer.
Why: Feedback verir, verified review bağımsızlığını korur.
Options: [ ] A Read+report  [ ] B Read-only  [ ] C Defer

## MPR-08 — Support/notifications

Question: Kritik durumların teslimi ve support kapsamı?
Recommended: In-app authoritative state + push convenience + named coverage/pause.
Why: Push kaybında truth kaybolmaz, kasada eskalasyon bellidir.
Options: [ ] A In-app+push  [ ] B In-app only  [ ] C Operator relay

## MPR-09 — Platform/package

Question: Merchant yüzeyi hangi uygulama stratejisiyle uygulanır?
Recommended: Dedicated Merchant App direction; kısa engineering spike exact path'i seçer.
Why: Customer/merchant boundary temiz kalır.
Options: [ ] A Dedicated  [ ] B Second entry point  [ ] C Customer routes

## MPR-10 — Operator duties

Question: Tek pilot operatörü birleşik rolleri taşıyabilir mi?
Recommended: Evet, reason/evidence/audit ve örneklem incelemesiyle.
Why: Lean operasyonu destekler; keyfi DB/yetki değişimi yine yasaktır.
Options: [ ] A Combined+controls  [ ] B Strict separation

## MPR-11 — Analytics

Question: Merchant pilotta dashboard görür mü?
Recommended: Yalnız action summary; charts defer.
Why: Veri azlığında vanity/gelir yanlış yorumunu önler.
Options: [ ] A Action summary  [ ] B Dashboard  [ ] C None

## MPR-12 — Release/stop authority

Question: Production go/no-go ve pilot stop kimde/nasıl?
Recommended: Explicit human authority + predefined P0/P1/support-capacity stops.
Why: Unattended Production varsayımını önler.
Options: [ ] A Human gate+stops  [ ] B Ad hoc owner  [ ] C Automated
