# W45C Auth + Startup — implementation scope

Base: `4287972429d9befe4ef2637a565ea6d8a2393a5e`
Branch: `astra-ui/w45c-auth-startup-final-ui`
Observed start: 2026-09-05 02:59:59 Europe/Istanbul (2026-09-04 23:59:59 UTC).

## Reachability audit

`lib/t_store.dart` installs `CustomerLaunchGate` as `MaterialApp.home`. There
are no named routes or a class named AuthGuard. Guard behavior is implemented
by caller checks and `LoginView(returnToCallerAfterCustomerLogin: true)`.
The default global email/recovery listeners determine callback destinations.

| W44 ID | Active surface | Source / real entry |
|---|---|---|
| FS-01 | Launch/loading gate | `views/on_boarding/customer_launch_gate.dart`; `TStore.home`; pending local preference, authenticated/completed home, first-run onboarding, storage-error home fallback |
| FS-02 | Three onboarding pages | `views/on_boarding/on_boarding_view.dart`; launch gate; swipe/dots/continue/skip/start through existing OnBoardingCubit |
| FS-03 | Login and auth-required destination | `views/login/login_view.dart`, `widgets/login_form_section.dart`; shell Cart/Wishlist/Settings, Home/app bar, Nearby, Settings, favorites, sellers, shop chat, product reviews, pending chat; guest return, caller-result return, confirmation-required and error states |
| FS-04 | Signup | `views/signup/sign_up_view.dart`, `widgets/sign_up_form_section.dart`; Login create-account action; six existing fields and two independent legal consents |
| FS-05 | Verify-email waiting/resend | `views/signup/verify_email_view.dart`; signup/login confirmation-required; cooldown, sending, resend success/error, return-to-caller/login |
| FS-06 | Forgot-password request | `views/password_configuration/forget_password_view.dart`; Login and invalid-recovery action |
| FS-07 | Reset-email instructions | `views/password_configuration/reset_password_view.dart`; request success; enumeration-safe copy, cooldown/resend and login return |
| FS-08 | New-password form/result | `views/password_configuration/update_password_view.dart`; PasswordRecoveryListener with verified identity; validating/submitting/success/rejected/invalid and sign-out before login |
| FS-09 | Invalid/expired recovery | `views/password_configuration/invalid_password_recovery_view.dart`; invalid launch, missing identity or failed recovery; new request/login actions |
| FS-10 | KVKK information | `views/legal/legal_document_views.dart`; Signup document link and Privacy & Permissions; existing text/version retained |
| FS-11 | Terms of Use | same legal file; Signup document link and Privacy & Permissions; existing text/version retained |
| MD-10 | Wrong merchant-account dialog | `widgets/login_form_section.dart`; retained `isMerchantLogin` outcome; sign-out or customer continuation unchanged |
| MD-11 | Merchant-registration information | `views/login/login_view.dart`; customer Login link; information/dismiss only |
| MD-24 | Email-confirmation success notice | `widgets/email_confirmation_listener.dart`; valid confirmation destination, dismissible overlay; invalid callback remains existing safe snackbar |

Paths abbreviated above are relative to `lib/features/auth/presentation/`.
Runtime caller scan also found `store_view.dart`, which W44 excludes as inactive;
it is not an additional active login entry. No runtime caller selects
`isMerchantLogin: true`; MD-10 is retained and tested as W44's scoped compatibility
outcome, not claimed as an additional customer screen.

## Exclusions and behavior boundary

- EX-05 `EmailVerifiedSuccessfully` / `SuccessView`: no runtime caller. Do not activate.
- EX-06–08 merchant management/form/scanner: outside customer package.
- Legacy Store/Orders/Address and Account/Profile editing: outside package.
- No separate splash route, auth-gate screen, social sign-in, OTP form, offline
  screen or additional confirmation/recovery state is invented.
- ST-02/ST-03 app-wide loading/snackbar families belong to WP-10. Auth consumes
  the existing helpers; no global helper/theme/core UI mutation is needed.
- Auth repositories/Cubits/domain, onboarding preferences/Cubit, bootstrap,
  callback URI/PKCE/session/security, backend config and legal text stay unchanged.

## Checkpoint and verification plan

Eight subpackages: (1) this inventory; (2) launch/onboarding; (3) login/signup;
(4) recovery/reset; (5) confirmation/results; (6) dialogs/auth presentation;
(7) 320/390/430 px, 130% text, keyboard/touch/semantics; (8) combined regression.
Denominator: 14 W44 units, 8 subpackages. MD-10 remains in the denominator.
Coherent groups receive targeted tests, analyzer, checkpoint commits and pushes.
Final gate: full local Flutter suite, analyzer, diff check, scoped secret/PII scan.
Live/environment tests keep their existing opt-in gates and skips; no remote
Supabase access or new skips. Figma is forbidden for all units in this task.

## Shared-file ownership

No `lib/core/ui`, global theme, navigation or common form/button change planned.
Existing `CustomerAuthFormCard` is Auth-owned; its consumers are the scoped auth
screens. The only listener-file edit planned is MD-24's rendering code in
`lib/features/auth/presentation/widgets/email_confirmation_listener.dart`.
Its subscriptions, callback verification, session checks, destinations and
notice lifecycle are preserved. Integration should review this presentation-only
hotspot against other listener work. Owner: this task branch; no overlapping
worktree changes observed. No Figma/remote data or owner decision is required.
