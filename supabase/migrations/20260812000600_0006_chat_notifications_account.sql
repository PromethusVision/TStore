-- EsnaftaVar canonical migration 0006: chat summaries, trusted action
-- notifications, final notification privileges, and customer account delete.

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO $preflight$
DECLARE
  missing_table TEXT;
BEGIN
  SELECT required_table.name
    INTO missing_table
  FROM (
    VALUES
      ('profiles'),
      ('orders'),
      ('shops'),
      ('chat_messages'),
      ('notifications'),
      ('verified_transactions')
  ) AS required_table(name)
  WHERE to_regclass('public.' || required_table.name) IS NULL
  LIMIT 1;

  IF missing_table IS NOT NULL THEN
    RAISE EXCEPTION 'Migration 0006 missing required table public.%', missing_table
      USING ERRCODE = '42P01';
  END IF;

  IF has_table_privilege(
       'authenticated', 'public.notifications', 'INSERT'
     ) THEN
    RAISE EXCEPTION
      'authenticated must not have direct INSERT on public.notifications'
      USING ERRCODE = '42501';
  END IF;
END
$preflight$;

CREATE INDEX chat_messages_sender_created_idx
  ON public.chat_messages(sender_id, created_at DESC, id DESC);
CREATE INDEX chat_messages_receiver_created_idx
  ON public.chat_messages(receiver_id, created_at DESC, id DESC);
CREATE INDEX chat_messages_receiver_unread_sender_idx
  ON public.chat_messages(receiver_id, sender_id) WHERE is_read = false;

CREATE FUNCTION public.get_customer_conversations()
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
      message.id,
      message.receiver_id AS other_user_id,
      message.content,
      message.created_at,
      true AS is_mine,
      message.is_read
    FROM public.chat_messages AS message
    CROSS JOIN current_user_id AS signed_in_user
    WHERE signed_in_user.user_id IS NOT NULL
      AND message.sender_id = signed_in_user.user_id

    UNION ALL

    SELECT
      message.id,
      message.sender_id AS other_user_id,
      message.content,
      message.created_at,
      false AS is_mine,
      message.is_read
    FROM public.chat_messages AS message
    CROSS JOIN current_user_id AS signed_in_user
    WHERE signed_in_user.user_id IS NOT NULL
      AND message.receiver_id = signed_in_user.user_id
      AND message.sender_id <> signed_in_user.user_id
  ),
  ranked_messages AS (
    SELECT
      message.*,
      ROW_NUMBER() OVER (
        PARTITION BY message.other_user_id
        ORDER BY message.created_at DESC NULLS LAST, message.id DESC
      ) AS message_rank,
      COUNT(*) FILTER (
        WHERE message.is_mine = false AND message.is_read = false
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

CREATE FUNCTION public.get_customer_unread_chat_count()
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

CREATE FUNCTION public.create_chat_message_notification()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, auth
AS $function$
DECLARE
  sender_name TEXT;
BEGIN
  BEGIN
    IF NEW.sender_id IS NULL
       OR NEW.receiver_id IS NULL
       OR NEW.sender_id = NEW.receiver_id THEN
      RETURN NEW;
    END IF;

    SELECT NULLIF(btrim(shop.name), '')
      INTO sender_name
    FROM public.shops AS shop
    WHERE shop.owner_user_id = NEW.sender_id
    ORDER BY shop.id
    LIMIT 1;

    IF sender_name IS NULL THEN
      SELECT NULLIF(btrim(profile.full_name), '')
        INTO sender_name
      FROM public.profiles AS profile
      WHERE profile.id = NEW.sender_id;
    END IF;

    sender_name := COALESCE(sender_name, 'Bir kullanıcı');

    INSERT INTO public.notifications (
      user_id, title, body, type, data, is_read, created_at
    ) VALUES (
      NEW.receiver_id,
      'Yeni mesajın var',
      format('%s sana yeni bir mesaj gönderdi.', sender_name),
      'chat',
      jsonb_build_object(
        'action_type', 'chat_detail',
        'action_id', NEW.sender_id::TEXT,
        'action_name', sender_name
      ),
      false,
      COALESCE(NEW.created_at, clock_timestamp())
    );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING
        'Notification could not be created for chat message %: %',
        NEW.id,
        SQLERRM;
  END;

  RETURN NEW;
END;
$function$;

CREATE FUNCTION public.create_verified_purchase_notification()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, auth
AS $function$
DECLARE
  shop_name TEXT;
BEGIN
  BEGIN
    IF NEW.customer_user_id IS NULL OR NEW.id IS NULL THEN
      RETURN NEW;
    END IF;

    shop_name := COALESCE(NULLIF(btrim(NEW.shop_name), ''), 'Mağaza');

    INSERT INTO public.notifications (
      user_id, title, body, type, data, is_read, created_at
    ) VALUES (
      NEW.customer_user_id,
      'Alışverişin onaylandı',
      format('%s alışverişini onayladı.', shop_name),
      'order',
      jsonb_build_object(
        'action_type', 'order_detail',
        'action_id', NEW.id::TEXT,
        'action_name', shop_name
      ),
      false,
      COALESCE(NEW.confirmed_at, clock_timestamp())
    );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING
        'Notification could not be created for verified purchase %: %',
        NEW.id,
        SQLERRM;
  END;

  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION public.create_chat_message_notification()
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.create_verified_purchase_notification()
  FROM PUBLIC, anon, authenticated;

CREATE TRIGGER create_chat_message_notification_after_insert
  AFTER INSERT ON public.chat_messages
  FOR EACH ROW
  EXECUTE FUNCTION public.create_chat_message_notification();
CREATE TRIGGER create_verified_purchase_notification_after_insert
  AFTER INSERT ON public.verified_transactions
  FOR EACH ROW
  EXECUTE FUNCTION public.create_verified_purchase_notification();

-- Clients can read, mark, and delete only their own notification rows through
-- RLS. Notification creation remains limited to trusted trigger functions.
REVOKE ALL ON TABLE public.notifications FROM PUBLIC, anon, authenticated;
GRANT SELECT, UPDATE, DELETE ON TABLE public.notifications TO authenticated;

CREATE FUNCTION public.delete_current_customer_account()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, auth
AS $function$
DECLARE
  current_user_id UUID := auth.uid();
  current_role TEXT;
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '28000';
  END IF;

  SELECT profile.role
    INTO current_role
  FROM public.profiles AS profile
  WHERE profile.id = current_user_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Customer profile not found' USING ERRCODE = 'P0002';
  END IF;

  IF current_role <> 'customer' THEN
    RAISE EXCEPTION 'Only customer accounts can be deleted here'
      USING ERRCODE = '42501';
  END IF;

  -- Legacy orders have a non-cascading user FK. They are not the permanent
  -- verified-purchase record and must be removed before managed auth deletion.
  DELETE FROM public.orders WHERE user_id = current_user_id;

  -- Verified transactions and shop ratings intentionally have snapshot UUIDs
  -- rather than auth.users FKs, so durable commercial proof remains.
  DELETE FROM auth.users WHERE id = current_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Authenticated customer account not found'
      USING ERRCODE = 'P0002';
  END IF;
END;
$function$;

REVOKE ALL ON FUNCTION public.delete_current_customer_account()
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.delete_current_customer_account()
  TO authenticated;

COMMIT;
