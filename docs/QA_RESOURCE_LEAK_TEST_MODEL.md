# Resource Leak Test Model

State: PROPOSED — OWNER REVIEW REQUIRED

Resource tests look for growth or retained work across repeated lifecycle operations.

## Repetition loops

- open/close discovery and product details;
- search query/cancel and image list scroll;
- auth/login/logout/user switch;
- location permission/service changes;
- QR camera open/scan/cancel;
- chat/realtime subscribe/unsubscribe;
- background/resume and navigation stack churn.

Observe memory trend, subscriptions, timers, controllers, camera/location handles, sockets, pending requests, image cache, CPU/battery, and crash logs. A single snapshot is not proof; compare stabilized repeated cycles on profile/release builds and physical devices.

Thresholds derive from baseline and leak slope, with reproduction traces attached.

OWNER_DECISION_REQUIRED: choose profiling devices/run lengths and ownership for detected leaks.
