# Signing Key Loss and Recovery Risk

**State:** RISK REVIEW — NO SECRET MATERIAL COPIED

## Risks

| Loss/compromise | Impact |
|---|---|
| Android upload key lost | future Play uploads blocked until approved reset process |
| Android app-signing key unavailable/compromised | update trust/older-device continuity risk depending on Play setup |
| iOS distribution certificate/profile unavailable | archive/export blocked; certificate rotation may be possible |
| Apple account/team access lost | App Store operations and signing governance blocked |
| only one encrypted backup | corruption/ransomware/operator loss becomes release outage |
| undocumented alias/fingerprint | wrong key may sign a candidate |

## Required recovery package

Public fingerprints/certificate metadata, ownership, secure backup locations, restore test date, rotation/reset procedure, account recovery contacts and separation between key material and passwords. The package references secrets but never contains them in Git.

## Recommendation

Maintain primary protected storage plus an independently controlled offline backup; test restore into a disposable signing environment without exporting secret evidence. At least two authorized humans should understand recovery, while routine release access remains least privilege.

Current documentation records one primary backup and recommends a second offline backup. WAVE 22 does not verify or move either.

`OWNER_DECISION_REQUIRED: SIGNING_CUSTODY_AND_RECOVERY_OWNERS`
