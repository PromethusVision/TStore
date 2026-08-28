# Gamification and Reward Customer App Requirements

**State:** CONCEPTUAL — NO CUSTOMER APP IMPLEMENTATION

## Future capabilities

- Show pending/earned/adjusted/reversed/expired state without blocking core purchase or review flow.
- Explain program owner, evidence, progress, value, expiry and redemption in plain Turkish.
- Show badge evidence/limitations, privacy controls and lifecycle state.
- Preserve independent customer ratings and clearly label merchant system signals.
- Provide notification preferences, correction/dispute entry and accessible empty/error states.

## Security and trust

The app never computes authoritative reward, badge or reputation state locally. Offline/cached state is visibly stale and reconciles idempotently. It does not award from views, wishlist, directions, ad interactions or an unconfirmed QR. Policy-sensitive purchase details never appear in public badges.
