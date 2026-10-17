-- REVIEW SOURCE ONLY: Development notification text correction.
-- Execute only through the separately approved, guarded E bundle; never replay 0006.
CREATE OR REPLACE FUNCTION public.create_chat_message_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'extensions', 'auth'
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

CREATE OR REPLACE FUNCTION public.create_verified_purchase_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'extensions', 'auth'
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
