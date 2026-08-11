-- EsnaftaVar canonical migration 0007: safe managed-service integration.
--
-- Realtime is deterministic from the client contract:
-- - chat_messages uses Supabase stream()
-- - notifications subscribes to INSERT and UPDATE postgres changes
--
-- Storage is intentionally decision-neutral. The client references these
-- expected names:
--   product-images, category-images, brand-logos, banner-images, avatars,
--   review-images
-- Bucket visibility, file ownership paths, MIME/size limits, and writer roles
-- are not defined by the current product contract. This migration therefore
-- creates no bucket and no storage.objects policy. See the normalization doc.

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';

DO $preflight$
BEGIN
  IF to_regclass('public.chat_messages') IS NULL
     OR to_regclass('public.notifications') IS NULL THEN
    RAISE EXCEPTION
      'Migration 0007 requires public.chat_messages and public.notifications'
      USING ERRCODE = '42P01';
  END IF;

  IF to_regclass('storage.buckets') IS NULL THEN
    RAISE EXCEPTION
      'Supabase managed storage.buckets table is required; canonical migrations never create managed storage tables'
      USING ERRCODE = '42P01';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime'
  ) THEN
    RAISE EXCEPTION
      'Supabase managed supabase_realtime publication is required'
      USING ERRCODE = '42704';
  END IF;
END
$preflight$;

DO $realtime$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'chat_messages'
  ) THEN
    EXECUTE
      'ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'notifications'
  ) THEN
    EXECUTE
      'ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications';
  END IF;
END
$realtime$;

COMMIT;
