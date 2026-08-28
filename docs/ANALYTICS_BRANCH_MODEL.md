# EsnaftaVar Shop Branch Analytics Model

**State:** `PROPOSED`

A branch is a stable shop/location identity beneath a merchant organization. Events
are attributed to the branch that actually owned the listing, QR authorization or
customer destination at occurrence time.

Merchant rollups aggregate distinct branch facts once. They do not copy merchant-
level events into every branch. Branch timezone defines local-day dashboards;
merchant cross-branch comparison also offers a consistent UTC/complete-day view.

Branch opening, closure, transfer, merge or relocation needs effective-dated
history. A closed branch remains historically addressable. Transfer does not move
past facts to the new merchant unless an explicit reporting projection is selected.

Customer-origin location, individual visitor paths and low-count cohorts are not
shown to merchants. Branch comparisons require identical metric versions,
coverage and QR adoption caveats.

`BRANCH_IDENTITY_RUNTIME: NOT_IMPLEMENTED`
