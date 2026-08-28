# Codex Automation Opportunity Map

**State:** PROPOSED

| Class | Future examples | Stop/gate |
|---|---|---|
| FULLY_UNATTENDED | static audit, docs consistency, deterministic fixture generation, format/diff/analyze, unit/widget/contract tests, local ephemeral migration replay, unsigned compile | unexpected dirty tree, inconsistent contract, secret finding |
| UNATTENDED_WITH_GATES | task branch creation, checkpoint commit/push, Development dry-run preparation, protected build preparation | exact environment/credential or human approval before external mutation |
| PHYSICAL_HUMAN | two-device QR, real camera/GPS, email callback on device, accessibility/visual, signed install/upgrade, network/background transitions | human supplies device/secret through secure mechanism and records evidence |
| PRODUCTION_HUMAN | migration, store Production promotion, smoke, rollback/kill switch, emergency action | named authority, immutable inputs, backup/monitoring and explicit approval |
| OWNER_DECISION | pilot platform/scope, support/legal readiness, accepted risk, device coverage, rollout policy, CI budget | no option auto-selected |

Codex may analyze results and prepare commands/evidence, but cannot turn missing physical observation, signing material or owner choice into PASS. Unattended work remains within task branch and its authorized systems.
