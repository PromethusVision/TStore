-- Esnafta Var - müşteri favorileri tablo izinleri
--
-- Yalnızca giriş yapmış müşteriler favorilerini okuyabilir, ekleyebilir
-- ve kaldırabilir. Satır güvenliği politikası her müşteriyi kendi
-- kayıtlarıyla sınırlar. Giriş yapmayan kullanıcılara erişim verilmez.

BEGIN;

REVOKE ALL ON TABLE public.wishlist FROM anon;
GRANT SELECT, INSERT, DELETE
  ON TABLE public.wishlist
  TO authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
