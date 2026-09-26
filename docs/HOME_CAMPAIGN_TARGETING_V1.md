# Home campaign targeting V1

The existing `banners` table, repository, use case and Cubit remain authoritative.
Each V2 campaign owns its complete composition: title, subtitle, optional HTTPS
image, CTA and an allowlisted destination. Five approved bundled compositions
use gradients and native shopping/search/store/map motifs. Old image-only stock
rows are V1 and cannot enter the active customer Home carousel.

## Current selection

`HomeCampaignCatalog.select` accepts active, date-eligible V2 records with bounded
copy and `audience=general`, without city, district or category targeting. It
deduplicates IDs, sorts by `sort_order` then ID and caps the carousel at 12 items.
An empty, failed, legacy-only or invalid result selects the five approved local
compositions. Images may fail independently without hiding the text/CTA.

The carousel advances every six seconds when visible and motion is permitted.
Pointer interaction, focus and backgrounding pause it; manual interaction restarts
the interval. Reduced motion keeps manual paging and disables automatic motion.
Date eligibility is rechecked while the carousel runs and before navigation.

| Existing contract | Concept |
| --- | --- |
| `action_type`, `action_url` | allowlisted `target_type`, `target_value`, never arbitrary URLs |
| `sort_order` | priority, lower first |
| `start_date`, `end_date`, `is_active` | eligibility |
| `content_version`, `cta_text`, `audience` | V2 composition and audience |
| `city`, `district`, `category_scope` | reserved targeting metadata; excluded from general MVP |

`supabase/proposals/0016_engagement_foundation.sql` prepares the additive fields.
It is deliberately outside automatic migrations. No existing rows, assets,
canonical data, remote configuration or remote permissions were changed.
Updating reviewed V2 rows/images after a separately authorized deployment will
not require rebuilding the client. Existing installations without these columns
continue using local fallback.

## Future local eligibility

Before making a local-offer claim, the server must intersect date eligibility,
consented customer location, participating merchant availability/stock and the
campaign's category. No qualifying merchant means no local stationery offer,
even if a campaign matches the district. Do not infer availability from location
or a category name alone. Use coarse scopes where possible; precise location is
not collected or stored by this batch.

Rank eligible offers: real local offer → local category offer → regional seasonal
campaign → general campaign → bundled fallback. Distance and explicit priority
order offers within a tier. Without location permission use general content.
Latitude/longitude/radius fields can be added only when the availability contract
and privacy policy are defined; no speculative recommendation engine is included.

Future push references the same banner ID in `notifications.data.campaign_id`
and uses the same destination fields. The prepared server dispatcher currently
accepts only general eligible campaigns and requires marketing consent. Final
campaign artwork remains replaceable; no stock-photo fallback or asset upload
was performed.
