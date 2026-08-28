# Golden Test Review

State: PROPOSED — OWNER REVIEW REQUIRED

Goldens can detect deterministic visual drift but can also create high maintenance and false noise across fonts/platform renderers.

## Recommendation

Use a small, high-value set after the final UI kit stabilizes:

- shared design primitives and critical states;
- auth confirmation/recovery;
- product/card layouts at narrow and large text;
- cart/review eligibility;
- QR result/error states.

Pin fonts, surface size, locale, theme, pixel ratio, and toolchain. Review changed pixels with semantic/function tests; never mass-approve baselines. Platform-native dialogs, camera, dynamic remote media, and whole-app screenshot proliferation are poor golden candidates.

Human visual acceptance remains required.

OWNER_DECISION_REQUIRED: approve whether to adopt goldens and baseline review ownership after UI-kit finalization.
