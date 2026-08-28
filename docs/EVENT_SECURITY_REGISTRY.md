# EsnaftaVar Security Event Registry

**State:** `CANDIDATE SECURITY REGISTRY — NO DETECTION RUNTIME`

| Family | Candidate event | Minimum context |
|---|---|---|
| Authentication | `authentication_anomaly_detected`, `authentication_rate_limited` | subject surrogate, method, bounded reason, release/environment |
| Authorization | `role_violation_rejected`, `policy_access_rejected` | actor type, capability/policy, resource class, result |
| QR abuse | `qr_replay_rejected`, `qr_wrong_shop_rejected`, `qr_abuse_pattern_detected` | shop/token surrogate, correlation, rule version; no raw token |
| Operator | `operator_action_rejected`, `operator_session_anomaly_detected` | capability, case, session surrogate |
| Data boundary | `cross_environment_event_rejected`, `event_schema_rejected` | producer, environment, type/version, bounded reason |

Security events are restricted evidence, not product KPIs. A detection is not
proof of abuse and cannot automatically sanction a customer/merchant without the
governed operations policy. False-positive, appeal and reversal lineage must be
supported where consequences exist.

Payloads exclude credentials, auth/session tokens, raw QR, request bodies,
customer contact, precise location and private content. Network identifiers, if
ever necessary, require minimization, access, retention and legal review.

Alert severity is assigned by impact and confidence with baseline-backed
thresholds; exact thresholds are not selected here.

`SECURITY_EVENT_REGISTRY_FINALIZED: NO`
