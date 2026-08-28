# Customer App Permission Audit

Status: PASS FOR DECLARED V1 CAPABILITIES

| Capability | Android | iOS | Runtime flow | Result |
| --- | --- | --- | --- | --- |
| Internet | `INTERNET` | platform default | Supabase/public media | PASS |
| Approximate location | `ACCESS_COARSE_LOCATION` | when-in-use description | explicit explanation → request | PASS |
| Precise location | `ACCESS_FINE_LOCATION` | when-in-use description | optional current-position sorting | PASS |
| Camera | `CAMERA` | camera usage description | QR verifier scanner only | PASS, physical gate open |
| Notifications | not declared | not declared | no OS push feature | NOT REQUIRED |
| Background location | not declared | not declared | no background tracking | PASS |

Denied, denied-forever, service-disabled, settings, settings-return, timeout, and unavailable location states have local coverage. QR scanner reports camera denial safely and owns/disposes its controller. No permission was added: the active features already have the minimum platform declarations they require.

The shared customer repository contains verifier-scanner code, but this is not proof of a finished Merchant App. A real two-device camera acceptance remains `PHYSICAL_TEST_REQUIRED`.

`PERMISSION_AUDIT: PASS`
`UNNECESSARY_PERMISSION_FOUND: NO`
`BACKGROUND_LOCATION_PERMISSION: NO`
