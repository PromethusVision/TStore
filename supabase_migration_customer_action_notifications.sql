-- =============================================================
-- Esnafta Var - linked customer action notifications
-- =============================================================
-- Creates non-blocking notifications for future:
-- - chat messages, linked to the sender conversation
-- - verified purchases, linked to the verified transaction
--
-- Existing messages, purchases, and notifications are not modified.
-- Notification failures are caught so messaging and QR confirmation keep
-- their primary success/failure behavior.
-- =============================================================

BEGIN;

DO $preflight$
DECLARE
  v_missing_columns TEXT;
BEGIN
  IF to_regclass('public.notifications') IS NULL
     OR to_regclass('public.chat_messages') IS NULL
     OR to_regclass('public.verified_transactions') IS NULL
     OR to_regclass('public.profiles') IS NULL
     OR to_regclass('public.shops') IS NULL THEN
    RAISE EXCEPTION
      'Required notifications, chat, purchase, profile, and shop tables must exist';
  END IF;

  SELECT string_agg(required.column_name, ', ' ORDER BY required.column_name)
    INTO v_missing_columns
  FROM (
    VALUES
      ('notifications', 'user_id'),
      ('notifications', 'title'),
      ('notifications', 'body'),
      ('notifications', 'type'),
      ('notifications', 'data'),
      ('notifications', 'is_read'),
      ('notifications', 'created_at'),
      ('chat_messages', 'id'),
      ('chat_messages', 'sender_id'),
      ('chat_messages', 'receiver_id'),
      ('chat_messages', 'created_at'),
      ('verified_transactions', 'id'),
      ('verified_transactions', 'customer_user_id'),
      ('verified_transactions', 'shop_name'),
      ('verified_transactions', 'confirmed_at'),
      ('profiles', 'id'),
      ('profiles', 'full_name'),
      ('shops', 'owner_user_id'),
      ('shops', 'name')
  ) AS required(table_name, column_name)
  WHERE NOT EXISTS (
    SELECT 1
    FROM information_schema.columns AS columns
    WHERE columns.table_schema = 'public'
      AND columns.table_name = required.table_name
      AND columns.column_name = required.column_name
  );

  IF v_missing_columns IS NOT NULL THEN
    RAISE EXCEPTION 'Required columns are missing: %', v_missing_columns;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'notifications'
      AND column_name = 'data'
      AND data_type = 'jsonb'
  ) THEN
    RAISE EXCEPTION 'public.notifications.data must be JSONB';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_class AS relation
    JOIN pg_namespace AS namespace
      ON namespace.oid = relation.relnamespace
    WHERE namespace.nspname = 'public'
      AND relation.relname = 'notifications'
      AND relation.relrowsecurity
  ) THEN
    RAISE EXCEPTION 'Row-level security must be enabled on notifications';
  END IF;

  IF has_table_privilege(
       'authenticated',
       'public.notifications',
       'INSERT'
     ) THEN
    RAISE EXCEPTION
      'authenticated must not have direct INSERT permission on notifications';
  END IF;
END
$preflight$;

CREATE OR REPLACE FUNCTION public.create_chat_message_notification()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, auth
AS $function$
DECLARE
  v_sender_name TEXT;
BEGIN
  BEGIN
    IF NEW.sender_id IS NULL
       OR NEW.receiver_id IS NULL
       OR NEW.sender_id = NEW.receiver_id THEN
      RETURN NEW;
    END IF;

    SELECT NULLIF(btrim(shop.name), '')
      INTO v_sender_name
    FROM public.shops AS shop
    WHERE shop.owner_user_id = NEW.sender_id
    ORDER BY shop.id
    LIMIT 1;

    IF v_sender_name IS NULL THEN
      SELECT NULLIF(btrim(profile.full_name), '')
        INTO v_sender_name
      FROM public.profiles AS profile
      WHERE profile.id = NEW.sender_id;
    END IF;

    v_sender_name := COALESCE(v_sender_name, 'Bir kullanıcı');

    INSERT INTO public.notifications (
      user_id,
      title,
      body,
      type,
      data,
      is_read,
      created_at
    )
    VALUES (
      NEW.receiver_id,
      'Yeni mesajın var',
      format('%s sana yeni bir mesaj gönderdi.', v_sender_name),
      'chat',
      jsonb_build_object(
        'action_type', 'chat_detail',
        'action_id', NEW.sender_id::TEXT,
        'action_name', v_sender_name
      ),
      FALSE,
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

CREATE OR REPLACE FUNCTION public.create_verified_purchase_notification()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, auth
AS $function$
DECLARE
  v_shop_name TEXT;
BEGIN
  BEGIN
    IF NEW.customer_user_id IS NULL OR NEW.id IS NULL THEN
      RETURN NEW;
    END IF;

    v_shop_name := COALESCE(
      NULLIF(btrim(NEW.shop_name), ''),
      'Mağaza'
    );

    INSERT INTO public.notifications (
      user_id,
      title,
      body,
      type,
      data,
      is_read,
      created_at
    )
    VALUES (
      NEW.customer_user_id,
      'Alışverişin onaylandı',
      format('%s alışverişini onayladı.', v_shop_name),
      'order',
      jsonb_build_object(
        'action_type', 'order_detail',
        'action_id', NEW.id::TEXT,
        'action_name', v_shop_name
      ),
      FALSE,
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

DROP TRIGGER IF EXISTS create_chat_message_notification_after_insert
  ON public.chat_messages;
CREATE TRIGGER create_chat_message_notification_after_insert
AFTER INSERT ON public.chat_messages
FOR EACH ROW
EXECUTE FUNCTION public.create_chat_message_notification();

DROP TRIGGER IF EXISTS create_verified_purchase_notification_after_insert
  ON public.verified_transactions;
CREATE TRIGGER create_verified_purchase_notification_after_insert
AFTER INSERT ON public.verified_transactions
FOR EACH ROW
EXECUTE FUNCTION public.create_verified_purchase_notification();

COMMIT;

-- Optional read-only postflight checks:
-- SELECT
--   trigger.event_object_table,
--   trigger.trigger_name,
--   trigger.action_timing,
--   trigger.event_manipulation
-- FROM information_schema.triggers AS trigger
-- WHERE trigger.trigger_schema = 'public'
--   AND trigger.trigger_name IN (
--     'create_chat_message_notification_after_insert',
--     'create_verified_purchase_notification_after_insert'
--   )
-- ORDER BY trigger.trigger_name;
--
-- SELECT
--   has_table_privilege(
--     'authenticated',
--     'public.notifications',
--     'SELECT'
--   ) AS authenticated_can_select,
--   has_table_privilege(
--     'authenticated',
--     'public.notifications',
--     'UPDATE'
--   ) AS authenticated_can_update,
--   has_table_privilege(
--     'authenticated',
--     'public.notifications',
--     'INSERT'
--   ) AS authenticated_can_insert;
