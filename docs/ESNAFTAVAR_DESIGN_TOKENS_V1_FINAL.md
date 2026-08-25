# EsnaftaVar Design Tokens V1 — Final

> WAVE 14 — PHASE B2 · Token Foundation Finalization
> Tarih: 2026-08-25
> Durum: **FINAL**
> Onaylı görsel dil: **Mahalle Terracotta**
> Figma: [EsnaftaVar — Final UI System](https://www.figma.com/design/O8MIn0KyQfFoPA3EnhiWii/EsnaftaVar-%E2%80%94-Final-UI-System)
> Historical proposal: [ESNAFTAVAR_DESIGN_TOKENS_V1_PROPOSAL.md](./ESNAFTAVAR_DESIGN_TOKENS_V1_PROPOSAL.md)
> Machine-readable manifest: [esnaftavar_design_tokens_v1.json](./data/esnaftavar_design_tokens_v1.json)

## 1. Final product decision

| Karar | Final değer |
|---|---|
| Design language | Mahalle Terracotta |
| Primary | `#B54732` |
| Accent | `#1F6B5D` |
| Typography | Poppins only |
| Spacing | `4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 / 48` |
| Radius | `8 / 12 / 16 / 999` |
| Touch target | `44 px` minimum, `48 px` preferred |
| Color mode | Light |
| Status | Final |

B1'de Recommended olan Mahalle Terracotta ürün sahibi tarafından final olarak onaylanmıştır. Bakır & Adaçayı ile Nar & Petrol yalnız historical candidate/reference olarak korunur; canonical token sistemine dahil değildir.

B2 kapsamının gerektirdiği, B1 tablosunda ayrı değer verilmemiş accent state türevleri aynı onaylı teal yönünde tamamlanmıştır:

- `brand/accentHover = #195C50`
- `brand/accentPressed = #144A41`
- `brand/accentSoft = #E5F2EF`

Bu türevler approved primary/accent yönünü değiştirmez. Accent / accentSoft kontrastı `5.51:1`'dir.

## 2. Artifact relationship and scope

Bu doküman final karar ve Figma foundation kaydıdır. B1 proposal dokümanı karar tarihçesi olarak korunur.

Bu fazda:

- yeni reusable Figma variable collection'ları oluşturuldu;
- yeni izole Poppins text style ve warm-charcoal effect style'ları oluşturuldu;
- yalnız approved proposal mock'ları bu foundation'a bağlandı;
- K'pasa source ekran, component, instance ve mevcut stilleri migrate edilmedi;
- Flutter/runtime değişikliği yapılmadı.

## 3. Figma canonical architecture

| Artifact | Ad | ID / mode | Count |
|---|---|---|---:|
| Color collection | `EsnaftaVar / Color` | `VariableCollectionId:52766:2` · `Light / 52766:0` | 38 |
| Dimension collection | `EsnaftaVar / Dimension` | `VariableCollectionId:52769:16` · `Default / 52769:0` | 15 |
| Text styles | `EsnaftaVar/type/*` | isolated local styles | 12 |
| Effect styles | `EsnaftaVar/shadow/*` | isolated local styles | 3 |

Architecture rules:

1. Semantic variable names slash-separated ve collection içinde unique'dir.
2. Canonical color count 50'nin altında olduğu için tek Light semantic collection kullanılır.
3. Aynı değerin farklı ürün anlamı taşıdığı commerce/future slot'lar intentional alias'tır.
4. `surface/elevated → surface/surface` ve `text/onAccent → text/onPrimary` alias'ları da intentional'dır.
5. Her variable targeted scope kullanır; `ALL_SCOPES` yoktur.
6. Her variable deterministik WEB Dev Mode syntax taşır. Bu syntax Flutter implementation değildir.
7. Dark mode bu fazda türetilmemiştir; ayrı tasarım ve kontrast onayı gerektirir.

## 4. Color variables

| Token | Resolved value | Alias | Semantic role | Figma variable |
|---|---:|---|---|---|
| `brand/primary` | `#B54732` | — | Primary CTA and core brand emphasis | `VariableID:52766:3` |
| `brand/primaryHover` | `#A33F2C` | — | Primary hover state | `VariableID:52766:4` |
| `brand/primaryPressed` | `#873425` | — | Primary pressed state | `VariableID:52766:5` |
| `brand/primarySoft` | `#FBE9E4` | — | Low-emphasis primary surface | `VariableID:52766:6` |
| `brand/accent` | `#1F6B5D` | — | Secondary action and merchant identity | `VariableID:52766:7` |
| `brand/accentHover` | `#195C50` | — | Accent hover state | `VariableID:52766:8` |
| `brand/accentPressed` | `#144A41` | — | Accent pressed state | `VariableID:52766:9` |
| `brand/accentSoft` | `#E5F2EF` | — | Low-emphasis accent surface | `VariableID:52766:10` |
| `surface/background` | `#FFF8F3` | — | Application background | `VariableID:52767:2` |
| `surface/surface` | `#FFFFFF` | — | Standard card and sheet surface | `VariableID:52767:3` |
| `surface/surfaceAlt` | `#F6EEE7` | — | Grouped alternate surface | `VariableID:52767:4` |
| `surface/elevated` | `#FFFFFF` | `surface/surface` | Elevated surface used with shadow | `VariableID:52767:5` |
| `text/primary` | `#2B211C` | — | Primary heading and body text | `VariableID:52767:6` |
| `text/secondary` | `#5F514A` | — | Secondary explanatory text | `VariableID:52767:7` |
| `text/muted` | `#75675E` | — | Non-critical metadata | `VariableID:52767:8` |
| `text/onPrimary` | `#FFFFFF` | — | Text and icon on primary | `VariableID:52767:9` |
| `text/onAccent` | `#FFFFFF` | `text/onPrimary` | Text and icon on accent | `VariableID:52767:10` |
| `border/default` | `#DCCFC5` | — | Subtle card and field border | `VariableID:52768:2` |
| `border/strong` | `#A08B7D` | — | High-emphasis control border | `VariableID:52768:3` |
| `border/divider` | `#E9DED5` | — | Decorative divider | `VariableID:52768:4` |
| `state/success` | `#287A4B` | — | Success label and indicator | `VariableID:52768:5` |
| `state/successSoft` | `#E6F4EA` | — | Success supporting surface | `VariableID:52768:6` |
| `state/warning` | `#8A5100` | — | Warning label and indicator | `VariableID:52768:7` |
| `state/warningSoft` | `#FFF0D1` | — | Warning supporting surface | `VariableID:52768:8` |
| `state/error` | `#B42318` | — | Error label and indicator | `VariableID:52769:2` |
| `state/errorSoft` | `#FDEAE7` | — | Error supporting surface | `VariableID:52769:3` |
| `state/info` | `#24677A` | — | Informational label and indicator | `VariableID:52769:4` |
| `state/infoSoft` | `#E5F2F5` | — | Information supporting surface | `VariableID:52769:5` |
| `commerce/price` | `#873425` | `brand/primaryPressed` | Primary product price | `VariableID:52769:6` |
| `commerce/discount` | `#B42318` | `state/error` | Discount amount or rate | `VariableID:52769:7` |
| `commerce/stockAvailable` | `#287A4B` | `state/success` | Available stock status | `VariableID:52769:8` |
| `commerce/stockLow` | `#8A5100` | `state/warning` | Low stock status | `VariableID:52769:9` |
| `commerce/unavailable` | `#75675E` | `text/muted` | Unavailable product metadata | `VariableID:52769:10` |
| `future/sponsored` | `#8A5100` | `state/warning` | Reserved sponsored disclosure color slot; no advertising behavior | `VariableID:52769:11` |
| `future/verifiedPurchase` | `#287A4B` | `state/success` | Reserved verified purchase visual slot | `VariableID:52769:12` |
| `future/merchantBadge` | `#1F6B5D` | `brand/accent` | Reserved merchant badge visual slot | `VariableID:52769:13` |
| `future/customerBadge` | `#B54732` | `brand/primary` | Reserved customer badge visual slot | `VariableID:52769:14` |
| `future/rewardProgress` | `#B54732` | `brand/primary` | Reserved reward progress visual slot; no gamification behavior | `VariableID:52769:15` |

Toplam color variable: **38**. Intentional alias: **12**. Broken alias: **0**.

## 5. Dimension variables

| Token | Value | Semantic role | Figma scope | Figma variable |
|---|---:|---|---|---|
| `space/4` | `4 px` | Spacing scale: 4 px | `WIDTH_HEIGHT, GAP` | `VariableID:52769:17` |
| `space/8` | `8 px` | Spacing scale: 8 px | `WIDTH_HEIGHT, GAP` | `VariableID:52769:18` |
| `space/12` | `12 px` | Spacing scale: 12 px | `WIDTH_HEIGHT, GAP` | `VariableID:52769:19` |
| `space/16` | `16 px` | Spacing scale: 16 px | `WIDTH_HEIGHT, GAP` | `VariableID:52769:20` |
| `space/20` | `20 px` | Spacing scale: 20 px | `WIDTH_HEIGHT, GAP` | `VariableID:52769:21` |
| `space/24` | `24 px` | Spacing scale: 24 px | `WIDTH_HEIGHT, GAP` | `VariableID:52769:22` |
| `space/32` | `32 px` | Spacing scale: 32 px | `WIDTH_HEIGHT, GAP` | `VariableID:52769:23` |
| `space/40` | `40 px` | Spacing scale: 40 px | `WIDTH_HEIGHT, GAP` | `VariableID:52769:24` |
| `space/48` | `48 px` | Spacing scale: 48 px | `WIDTH_HEIGHT, GAP` | `VariableID:52769:25` |
| `radius/small` | `8 px` | Small input and compact container radius | `CORNER_RADIUS` | `VariableID:52769:26` |
| `radius/medium` | `12 px` | Button and compact card radius | `CORNER_RADIUS` | `VariableID:52769:27` |
| `radius/large` | `16 px` | Product card and panel radius | `CORNER_RADIUS` | `VariableID:52769:28` |
| `radius/pill` | `999 px` | Pill, chip, and avatar radius | `CORNER_RADIUS` | `VariableID:52769:29` |
| `touch/min` | `44 px` | Minimum product touch target | `WIDTH_HEIGHT` | `VariableID:52769:30` |
| `touch/preferred` | `48 px` | Preferred product touch target | `WIDTH_HEIGHT` | `VariableID:52769:31` |

Spacing variable'ları layout gap/padding ve ölçü picker'ları için `WIDTH_HEIGHT, GAP`; radius yalnız `CORNER_RADIUS`; touch yalnız `WIDTH_HEIGHT` scope'undadır.

## 6. Typography styles

Ana ve tek canonical UI font ailesi **Poppins**'tir. Yeni canonical stillerde Inter kullanımı yoktur.

| Token | Font | Size / line-height | Decoration | Semantic role | Figma style |
|---|---|---:|---|---|---|
| `type/display` | `Poppins SemiBold` | `32 / 40` | `NONE` | Hero and high-emphasis display | `S:10d208d89f055e5c554934ba73c2cc305776e105,` |
| `type/headingLg` | `Poppins SemiBold` | `28 / 36` | `NONE` | Screen title | `S:b16c810136e673ad3e34c0a3a12075cfd9fd4c2c,` |
| `type/headingMd` | `Poppins SemiBold` | `24 / 32` | `NONE` | Major section title | `S:e5bc4e3e43a12519770f2f6446e617be9184e1a1,` |
| `type/headingSm` | `Poppins SemiBold` | `20 / 28` | `NONE` | Card group and compact section title | `S:df501ff45c53bf27425eec72254711354599e184,` |
| `type/bodyLg` | `Poppins Regular` | `16 / 24` | `NONE` | Primary body copy | `S:9075951ac72fb229cce145c243187b4a4898e187,` |
| `type/bodyMd` | `Poppins Regular` | `14 / 22` | `NONE` | Standard supporting body copy | `S:200317c537d4bd1013eb8c1771a1fc59b5e2aee8,` |
| `type/bodySm` | `Poppins Regular` | `12 / 18` | `NONE` | Compact body and metadata | `S:c172dc79ee373ab2125b3f2b6c09b1b49a8c0d51,` |
| `type/label` | `Poppins Medium` | `14 / 20` | `NONE` | Field label, badge, and compact action | `S:1f49e605c1f77a5f4b20d2d4e1b0798be1616caf,` |
| `type/caption` | `Poppins Regular` | `12 / 16` | `NONE` | Date, source, and secondary metadata | `S:f38ee7451010c9a77e47fdd9cd27eda315544f39,` |
| `type/priceHero` | `Poppins Bold` | `24 / 32` | `NONE` | Product detail hero price | `S:9147218e1fadf019d7041d2933222289f420c338,` |
| `type/price` | `Poppins SemiBold` | `18 / 24` | `NONE` | Product card and merchant row price | `S:342ee0e9079bd1445091781c0d36cba078ac1d9c,` |
| `type/priceOld` | `Poppins Regular` | `14 / 20` | `STRIKETHROUGH` | Previous price with strikethrough | `S:058ba333db0dad089b85c34ebeab2436c518d3b6,` |

Notlar:

- `type/label`, field label, badge ve compact action için ortak temel sağlar.
- `type/price`, ProductCard ve Seller row fiyatı içindir.
- `type/priceOld`, previous price rolünü strikethrough ile açıkça ayırır.
- Eski K'pasa text style'ları silinmedi ve değiştirilmedi.

## 7. Effect styles

Shadow rengi soğuk mavi-gri yerine warm charcoal `#2B211C`'dir.

| Token | X / Y / Blur / Spread | Opacity / color | Semantic role | Figma style |
|---|---|---|---|---|
| `shadow/xs` | `0 / 1 / 2 / 0` | `8% #2B211C` | Subtle card separation | `S:222fbea80c286018a9054cef2bcc4fdcfe7274e8,` |
| `shadow/sm` | `0 / 4 / 12 / -2` | `10% #2B211C` | Elevated card and floating action | `S:213fb1fbefa093858a6c4a8047dfa7257d7ad5b0,` |
| `shadow/md` | `0 / 12 / 28 / -6` | `14% #2B211C` | Modal and sheet elevation | `S:fc0077df5b9afe132a76a2bc4ef563b6921b4c8f,` |

Eski K'pasa effect style'ları korunmuştur.

## 8. Accessibility validation

WCAG 2.2 normal metin minimumu `4.5:1`, anlamlı UI/non-text göstergesi minimumu `3:1` referans alınmıştır.

| Pair | Ratio | Sonuç |
|---|---:|---|
| Primary `#B54732` / white | `5.37:1` | AA normal text PASS |
| Accent `#1F6B5D` / white | `6.33:1` | AA normal text PASS |
| Accent hover `#195C50` / white | `7.81:1` | PASS |
| Accent pressed `#144A41` / white | `10.07:1` | PASS |
| Text primary / background | `14.94:1` | PASS |
| Text secondary / background | `7.23:1` | PASS |
| Text muted / background | `5.18:1` | PASS |
| Success / white | `5.28:1` | PASS |
| Error / white | `6.57:1` | PASS |
| Primary / primarySoft | `4.57:1` | PASS |
| Accent / accentSoft | `5.51:1` | PASS |
| Success / successSoft | `4.65:1` | PASS |
| Warning / warningSoft | `5.72:1` | PASS |
| Error / errorSoft | `5.67:1` | PASS |
| Info / infoSoft | `5.57:1` | PASS |
| Border strong / white | `3.24:1` | Non-text PASS |

Soft renkler kendi başına metin rengi değildir. `primarySoft`, `accentSoft` ve state soft yüzeylerinde karşılık gelen strong token foreground olarak kullanılmalıdır. State, stock, discount, unavailable ve verified anlamı yalnız renk ile verilmez; label ve gerektiğinde icon eşlik eder.

Touch standardı WCAG minimumundan daha güçlü ürün standardı olarak `44 px` minimum ve `48 px` preferred'dır.

## 9. Approved proposal bindings

- Page: `EsnaftaVar — Tokens V1 Proposal`
- Page node: `52748:2`
- Board: `Proposal Board / EsnaftaVar Tokens V1`
- Board node: `52748:3`
- Board size: `1440 × 3802`
- Variable-consuming proposal nodes: `59`
- Variable reference count: `183`
- Unique consumed variables: `36`
- Invalid variable reference: `0`
- EsnaftaVar text-style bindings: `13`
- EsnaftaVar effect-style bindings: `5`
- Proposal component/component-set/instance: `0 / 0 / 0`
- Proposal font offender: `0`
- Placeholder/shimmer: `0`

Bound preview areas:

1. Recommended palette swatches
2. Semantic success/warning/error/info samples
3. Future semantic slot labels
4. Poppins typography specimens
5. Radius and shadow samples
6. CTA preview with 48 px target
7. ProductCard color preview
8. Merchant/Seller row preview with 44 px action

Alternate palette swatches remain hardcoded candidate reference and are not canonical variables.

## 10. Source UI kit safety

Source page fingerprints were calculated before and after all Figma writes with node ID/type/name, geometry, fills, strokes, text/effect style references, bound variables and text/font properties.

| Protected page | Node | Pre-write | Post-write | Result |
|---|---:|---:|---:|---|
| Cover | `458:7710` | `4661b821` | `4661b821` | UNCHANGED |
| UI / 113-screen source area | `401:358` | `7587dc5a` | `7587dc5a` | UNCHANGED |
| Components | `401:359` | `e6bd7684` | `e6bd7684` | UNCHANGED |
| Styles Guide | `16:3` | `2b7debab` | `2b7debab` | UNCHANGED |

Post-write source metrics:

- source screen page top-level child: `124`; source instance: `336`;
- source component/component-set: `253`; component-page instance: `35`;
- Styles Guide top-level child: `2`; instance: `39`;
- existing local paint/text/effect style count: `32 / 7 / 6`, unchanged;
- new local paint style: `0`;
- source screen modified: `0`;
- source component modified: `0`;
- source instance modified: `0`.

## 11. Token manifest contract

Canonical machine-readable source:

`docs/data/esnaftavar_design_tokens_v1.json`

Manifest özellikleri:

- deterministic order: color → dimension → typography → shadow;
- her entry'de `name`, `type`, `value`, `semanticRole`, `status = final`;
- exact Figma collection/variable/style ID mapping;
- resolved alias value ile alias target name/ID;
- variable scope ve Dev Mode syntax;
- toplam token: `68` (`38` color, `15` dimension, `12` typography, `3` shadow).

## 12. Component token migration prerequisites

Bir sonraki component migration fazı:

1. Bu task branch'i integration/release süreciyle main'e alır.
2. Source componentleri ekranlardan önce migrate eder.
3. Sıra: Button → TextField → Navbar → ProductCard → SellerPriceRow.
4. Her component'te fill, stroke, text, padding, radius, size ve shadow binding'leri semantic tokenlara taşır.
5. Türkçe truncation, loading/empty/error/success, disabled/focus, 44–48 px target ve screenshot/golden doğrulaması yapar.
6. Ekran çapında recolor ancak component-level kabul sonrasında yapılır.
7. Dark mode, Flutter mapping ve runtime rollout ayrı karar/uygulama fazıdır.

## 13. Out of scope

Bu finalization:

- Home veya 113 screen redesign/recolor yapmaz;
- source ProductCard, Navbar veya TextField değiştirmez;
- category UI/taxonomy implement etmez;
- Flutter kodu değiştirmez;
- advertising engine tasarlamaz;
- gamification/reward davranışı tasarlamaz.

## 14. Final status

- `DESIGN_TOKENS_V1_FINAL: PASS`
- `MAHALLE_TERRACOTTA: FINAL`
- `SOURCE_UI_KIT_UNCHANGED: YES`
- `RUNTIME_CODE_CHANGED: NO`
- `READY_FOR_COMPONENT_TOKEN_MIGRATION: YES`
- `INTEGRATION_REQUIRED`
