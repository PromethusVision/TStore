# Backend Notification Contract

**State:** PRESERVE IN-APP V1; PUSH IS FUTURE

A notification is a recipient-scoped application fact with stable ID, type,
bounded display content/action metadata, created/read state and source reference.
Current `notifications` plus customer Realtime remain the active in-app contract.

## Rules

- server/domain action chooses recipient; client cannot notify arbitrary users;
- source event + notification type provides idempotency;
- action target is allowlisted and re-authorized at open time;
- missing/deleted target fails safely;
- read/delete affects only recipient and does not erase source/audit fact;
- no secret, token, raw QR, private evidence or unrestricted HTML;
- notification delivery does not prove the user saw or acted;
- user switch cancels prior subscriptions and private cached rows.

Push, email and in-app are separate delivery attempts over one notification intent.
Push tokens/preferences/quiet hours and transactional vs optional categories are
`OWNER_DECISION_REQUIRED`. Failure to push must not roll back a committed purchase.

