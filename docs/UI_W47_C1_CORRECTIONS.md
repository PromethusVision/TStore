# W47 C1 — Product Owner corrections

Source: `6cc7146c7b2978d89a87deb08c9e371ce73bc884` on `astra-ui/w47-tier-a-prototype-batch-2`.
Fetched main for Wave 3B: `cd1d566c36a669fc9b6cabeaee9a114979ae7fb7` (Account Hub now Final).

- Purchases: the opt-in prototype has two peer views, Alışverişlerim and İade Taleplerim. İade Talebi Oluştur is a separate secondary button. It opens the same existing preparation placeholder in a sheet; Alışverişlerimi Gör returns to history. No refund implementation/rule was added. Legacy/default presentation is unchanged.
- Reviews: approved presentation, source and 390 px evidence preserved byte-for-byte.
- Chat: the opt-in reverse message list shrink-wraps short conversations and aligns below the header. Large conversations retain reverse scrolling/pagination and latest-message positioning. Bubble colors, composer, real sent/read state and message logic are preserved.

87 targeted tests PASS across W47 prototypes and existing purchases/chat/inbox smoke. New C1 assertions check the two-tab/action distinction, original placeholder return handoff and short-conversation header/date proximity. Flutter analyzer PASS (no issues). Both corrected 390 × 844 screenshots were visually inspected. No new viewport/state matrix or full regression.

New Wave 3B surfaces will be isolated on a current-main-based descendant task branch that preserves all four W47 commits; this W47 branch is reserved for these corrections.

`W47_PURCHASES_C1: PASS`
`W47_REVIEWS_PRESERVED: PASS`
`W47_CHAT_C1: PASS`
