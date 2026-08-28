# Merchant App Accessibility Requirements

Status: **PROPOSED — TESTABLE V1 REQUIREMENTS**
Wave: 17 / WP69

## Interaction

- Minimum comfortable touch targets and no gesture-only critical operation.
- Keyboard/switch navigation order follows visual/semantic flow where platforms apply.
- QR scanner has explicit permission guidance, manual/fallback path where contract permits and non-color result cues.
- Confirmation cannot be triggered by accidental scan alone.

## Perception

- Text/background and state indicators meet applicable contrast guidance.
- Dynamic text scaling does not hide price, shop, QR confirm or error action.
- Icons have semantic labels; color is never sole success/error/availability signal.
- Motion respects reduced-motion preference and never conveys sole meaning.

## Language and assistive technology

- Plain Turkish, concise headings and field instructions.
- Screen-reader announces active shop, loading/result, validation errors and QR terminal state.
- Currency, quantity/unit, rating and date/time have locale-aware spoken labels.
- Focus moves to error summary/result after asynchronous operation.

Accessibility checks belong in widget/integration/physical test gates, not a final cosmetic pass.
