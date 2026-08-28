# Merchant Pilot Capability Matrix

State: `PROPOSED FOR OWNER REVIEW — NON-FINAL`

| Capability | Model A: Full App | Model B: Minimum safe | Model C: Assisted verifier | Pilot sınıfı | Yardım modeli | Defer riski |
|---|---:|---:|---:|---|---|---|
| Merchant auth/logout/session switch | Evet | Evet | Evet | MUST | Self-service | Kimlik/yetki karışır |
| Exact-shop owner authority | Evet | Evet | Evet | MUST | Server only | Cross-shop işlem |
| Shop verification/policy state | Evet | Evet | Evet | MUST | Ops review + merchant visibility | Regüle/yanlış shop açılır |
| Shop profile read | Evet | Evet | Evet | MUST | Self-service read | QR bağlamı belirsizleşir |
| Shop profile write | Gelişmiş | Temel | Assisted | SHOULD | Merchant attestation | Destek yükü/freshness |
| Listing read | Evet | Evet | Sınırlı | MUST | Self-service | Merchant gerçekliği göremez |
| Price write | Evet | Evet | Assisted geçiş | MUST | En kısa sürede self-service | Yanlış fiyat kalır |
| Availability + unknown | Evet | Evet | Assisted geçiş | MUST | En kısa sürede self-service | Hayalet stok |
| Freshness acknowledgement | Evet | Evet | Assisted | MUST | Self-service veya imzalı batch | Eski beyan görünür |
| Existing product search/associate | Evet | Basit | Operator prepared | MUST | Shared workflow | Yanlış ürün association |
| New catalog candidate | Evet | Basit | Operator intake | SHOULD | Assisted | Pilot öğrenmesi azalır |
| QR scan/preview/confirm | Evet | Evet | Evet | MUST | Self-service only | Pilot çekirdeği yok |
| QR reconciliation/history | Evet | Evet | Evet | MUST | Server authoritative | Çift işlem/belirsizlik |
| Review visibility | Evet | Read-only | Deferred/read-only | SHOULD | Self-service | Feedback yavaşlar |
| Review respond | Evet | Defer | Defer | DEFER | Ops case if abuse | Düşük pilot riski |
| Review report | Evet | Basit | Support case | SHOULD | Merchant/support | UGC itirazı gecikir |
| Structured evaluation | Dashboard | Read-only/sonra | Defer | SHOULD | No manual scoring | Pilot için şart değil |
| Critical notifications | Evet | Evet | Evet | MUST | System | Merchant kritik durumu kaçırır |
| Support/escalation | Evet | Evet | Evet | MUST | Case-based | Operasyon körleşir |
| Staff hierarchy | Evet | Tek owner | Tek owner | DEFER | Owner decision | Küçük cohortta gereksiz |
| Multi-branch | Evet | Defer | Defer | DEFER | None | İlk cohort tek shop olmalı |
| Analytics dashboard | Evet | Action summary | Defer | DEFER | Ops internal health | Veri yokken vanity |
| Ads/rewards/reputation | Gelecek | Gizli | Gizli | DEFER | None | Güven sözleşmesi karışır |

## Self-service / assisted sınırı

Self-service MUST: auth, logout, listing gerçeğini görme, kritik listing doğrulama, QR scan/confirm, belirsiz QR sonucu görme ve support request.

Operator-assisted olabilir: ilk shop kaydı, belge/profil kontrolü, başlangıç listing importu, canonical eşleştirme ve candidate düzeltme. Her assisted işlem actor, reason, source, before/after, merchant attestation ve correlation içermelidir.

