# Clean Install Matrix

State: PROPOSED — OWNER REVIEW REQUIRED

Clean install proves first-run behavior independently from developer state.

## Matrix

- supported Android low/high API and representative manufacturer;
- supported iOS low/current OS and iPhone/iPad if tablet remains supported;
- customer signup/login/recovery and guest entry;
- permissions initially allowed, denied, denied forever, and services disabled;
- no network, slow network, and recovery;
- cold deep link and callback;
- production label, identity, endpoint, privacy links, and release configuration.

Use synthetic accounts and record cleanup. Uninstall/reinstall behavior for secure storage, notification tokens, cached location, and session must be explicit. Emulator/simulator results do not replace at least one physical platform acceptance.

OWNER_DECISION_REQUIRED: approve minimum physical device set and tablet support expectations.
