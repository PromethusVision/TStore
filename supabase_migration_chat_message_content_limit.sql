-- =============================================================
-- Esnafta Var - chat message content length protection
-- =============================================================
-- Adds a non-destructive 1,000 character limit to chat messages.
-- The migration stops before changing the constraint if existing data
-- contains an empty or over-limit message.
-- =============================================================

BEGIN;

DO $preflight$
BEGIN
  IF to_regclass('public.chat_messages') IS NULL THEN
    RAISE EXCEPTION 'public.chat_messages table must exist';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'chat_messages'
      AND column_name = 'content'
      AND data_type = 'text'
      AND is_nullable = 'NO'
  ) THEN
    RAISE EXCEPTION
      'public.chat_messages.content must be a non-null text column';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.chat_messages
    WHERE char_length(btrim(content)) NOT BETWEEN 1 AND 1000
  ) THEN
    RAISE EXCEPTION
      'Existing chat messages violate the 1,000 character content limit';
  END IF;
END;
$preflight$;

ALTER TABLE public.chat_messages
  DROP CONSTRAINT IF EXISTS chat_messages_content_length;

ALTER TABLE public.chat_messages
  ADD CONSTRAINT chat_messages_content_length
  CHECK (char_length(btrim(content)) BETWEEN 1 AND 1000);

COMMIT;

-- Read-only postflight checks:
-- SELECT conname, pg_get_constraintdef(oid)
-- FROM pg_constraint
-- WHERE conrelid = 'public.chat_messages'::regclass
--   AND conname = 'chat_messages_content_length';
