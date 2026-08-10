-- =============================================================
-- Esnafta Var - Customer conversation summary performance
-- =============================================================
-- Additive migration: no chat message is updated or deleted.
-- The customer app receives one row per conversation instead of
-- downloading the complete message history on every list refresh.
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
      AND column_name IN (
        'id',
        'sender_id',
        'receiver_id',
        'content',
        'is_read',
        'created_at'
      )
    GROUP BY table_schema, table_name
    HAVING COUNT(*) = 6
  ) THEN
    RAISE EXCEPTION
      'public.chat_messages is missing one or more required columns';
  END IF;
END;
$preflight$;

CREATE INDEX IF NOT EXISTS idx_chat_sender_created
  ON public.chat_messages(sender_id, created_at DESC, id DESC);

CREATE INDEX IF NOT EXISTS idx_chat_receiver_created
  ON public.chat_messages(receiver_id, created_at DESC, id DESC);

CREATE INDEX IF NOT EXISTS idx_chat_receiver_unread_sender
  ON public.chat_messages(receiver_id, sender_id)
  WHERE is_read = false;

CREATE OR REPLACE FUNCTION public.get_customer_conversations()
RETURNS TABLE (
  other_user_id UUID,
  last_message TEXT,
  last_message_at TIMESTAMPTZ,
  last_message_is_mine BOOLEAN,
  last_message_is_read BOOLEAN,
  unread_count BIGINT
)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = pg_catalog, public
AS $function$
  WITH current_user_id AS (
    SELECT auth.uid() AS user_id
  ),
  user_messages AS (
    SELECT
      cm.id,
      cm.receiver_id AS other_user_id,
      cm.content,
      cm.created_at,
      true AS is_mine,
      cm.is_read
    FROM public.chat_messages AS cm
    CROSS JOIN current_user_id AS signed_in_user
    WHERE signed_in_user.user_id IS NOT NULL
      AND cm.sender_id = signed_in_user.user_id

    UNION ALL

    SELECT
      cm.id,
      cm.sender_id AS other_user_id,
      cm.content,
      cm.created_at,
      false AS is_mine,
      cm.is_read
    FROM public.chat_messages AS cm
    CROSS JOIN current_user_id AS signed_in_user
    WHERE signed_in_user.user_id IS NOT NULL
      AND cm.receiver_id = signed_in_user.user_id
      AND cm.sender_id <> signed_in_user.user_id
  ),
  ranked_messages AS (
    SELECT
      message.*,
      ROW_NUMBER() OVER (
        PARTITION BY message.other_user_id
        ORDER BY message.created_at DESC NULLS LAST, message.id DESC
      ) AS message_rank,
      COUNT(*) FILTER (
        WHERE message.is_mine = false
          AND message.is_read = false
      ) OVER (PARTITION BY message.other_user_id) AS unread_count
    FROM user_messages AS message
    WHERE message.other_user_id IS NOT NULL
  )
  SELECT
    ranked.other_user_id,
    ranked.content AS last_message,
    ranked.created_at AS last_message_at,
    ranked.is_mine AS last_message_is_mine,
    ranked.is_read AS last_message_is_read,
    ranked.unread_count
  FROM ranked_messages AS ranked
  WHERE ranked.message_rank = 1
  ORDER BY ranked.created_at DESC NULLS LAST, ranked.id DESC;
$function$;

CREATE OR REPLACE FUNCTION public.get_customer_unread_chat_count()
RETURNS BIGINT
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = pg_catalog, public
AS $function$
  SELECT COUNT(*)
  FROM public.chat_messages AS message
  WHERE auth.uid() IS NOT NULL
    AND message.receiver_id = auth.uid()
    AND message.is_read = false;
$function$;

REVOKE ALL ON FUNCTION public.get_customer_conversations()
  FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.get_customer_unread_chat_count()
  FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.get_customer_conversations()
  TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_customer_unread_chat_count()
  TO authenticated;

COMMENT ON FUNCTION public.get_customer_conversations() IS
  'Returns one RLS-protected conversation summary row per chat participant.';
COMMENT ON FUNCTION public.get_customer_unread_chat_count() IS
  'Returns the authenticated user''s unread chat message count.';

COMMIT;

-- Read-only postflight checks:
-- SELECT proname, prosecdef
-- FROM pg_proc
-- WHERE oid IN (
--   'public.get_customer_conversations()'::regprocedure,
--   'public.get_customer_unread_chat_count()'::regprocedure
-- );
--
-- SELECT indexname, indexdef
-- FROM pg_indexes
-- WHERE schemaname = 'public'
--   AND tablename = 'chat_messages'
--   AND indexname IN (
--     'idx_chat_sender_created',
--     'idx_chat_receiver_created',
--     'idx_chat_receiver_unread_sender'
--   )
-- ORDER BY indexname;
