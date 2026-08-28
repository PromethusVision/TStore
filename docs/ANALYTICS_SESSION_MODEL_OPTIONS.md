# EsnaftaVar Analytics Session Model Options

**State:** `OPTIONS — NO SESSION MODEL SELECTED`

| Option | Definition | Privacy/quality tradeoff |
|---|---|---|
| No analytics session | Independent events/explicit correlations only | Minimum tracking; limited funnel analysis |
| Ephemeral app session | Random ID from foreground start to close/short inactivity; not persisted long-term | Useful health/navigation sequence; device lifecycle noise |
| Short inactivity session | Rotate after a proposed inactivity window | Familiar funnels; threshold is arbitrary and cross-platform fragile |
| Authenticated visit session | Server-issued per-login/visit identity | Stronger auth flow; risks unnecessary longitudinal linkage |

Recommended V1 is no general session or an ephemeral random session used only for
approved product analytics/health. It must rotate, be environment-scoped, carry no
identity meaning and not retroactively link guest history after login.

The inactivity duration, consent basis, persistence, cross-device behavior and
retention are Product Owner/privacy decisions. Absence of a later event cannot be
called abandonment until a selected session/end rule exists.

`ANALYTICS_SESSION_SELECTED: NO`
