-- F correction: SQL CHECK accepts UNKNOWN, so required amounts must explicitly
-- be non-null. Preserve 0021 and all immutable revision history.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
DO $preflight$ BEGIN
  IF to_regclass('public.campaign_revisions') IS NULL THEN
    RAISE EXCEPTION '0022 requires 0021 merchant campaign lite';
  END IF;
END $preflight$;

-- Validate existing rows too. If an earlier environment contains malformed
-- revisions, fail atomically; never invent an amount or rewrite audit history.
-- mutate_campaign_v1 already maps this check violation to the public, stable
-- CAMPAIGN_INVALID_ARGUMENT error and rolls back the whole attempted command.
ALTER TABLE public.campaign_revisions
  ADD CONSTRAINT campaign_revisions_required_amount CHECK ((
    (offer_type='announcement' AND price_minor IS NULL AND percentage_basis_points IS NULL)
    OR (offer_type='price' AND price_minor IS NOT NULL
      AND price_minor BETWEEN 1 AND 999999999 AND percentage_basis_points IS NULL)
    OR (offer_type='percentage' AND percentage_basis_points IS NOT NULL
      AND percentage_basis_points BETWEEN 1 AND 10000 AND price_minor IS NULL)
  ) IS TRUE);
COMMIT;
