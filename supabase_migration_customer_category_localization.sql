-- Müşteri uygulamasındaki ana kategori adlarını Türkçeleştirir.
-- Kategori kimlikleri ve ürün bağlantıları değişmeden kalır.

BEGIN;

DO $$
DECLARE
  expected_category_count CONSTANT INTEGER := 5;
  matched_category_count INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO matched_category_count
  FROM public.categories
  WHERE
    (id = 'c1000000-0000-0000-0000-000000000001'::uuid
      AND LOWER(name) IN ('electronics', 'elektronik'))
    OR (id = 'c1000000-0000-0000-0000-000000000002'::uuid
      AND LOWER(name) IN ('clothes', 'clothing', 'giyim'))
    OR (id = 'c1000000-0000-0000-0000-000000000003'::uuid
      AND LOWER(name) IN ('shoes', 'ayakkabı'))
    OR (id = 'c1000000-0000-0000-0000-000000000004'::uuid
      AND LOWER(name) IN ('furniture', 'mobilya'))
    OR (id = 'c1000000-0000-0000-0000-000000000005'::uuid
      AND LOWER(name) IN ('accessories', 'aksesuar'));

  IF matched_category_count <> expected_category_count THEN
    RAISE EXCEPTION
      'Kategori güncellemesi durduruldu: Beklenen 5 kayıttan % tanesi doğrulandı.',
      matched_category_count;
  END IF;

  UPDATE public.categories
  SET
    name = CASE id
      WHEN 'c1000000-0000-0000-0000-000000000001'::uuid THEN 'Elektronik'
      WHEN 'c1000000-0000-0000-0000-000000000002'::uuid THEN 'Giyim'
      WHEN 'c1000000-0000-0000-0000-000000000003'::uuid THEN 'Ayakkabı'
      WHEN 'c1000000-0000-0000-0000-000000000004'::uuid THEN 'Mobilya'
      WHEN 'c1000000-0000-0000-0000-000000000005'::uuid THEN 'Aksesuar'
      ELSE name
    END,
    updated_at = NOW()
  WHERE id IN (
    'c1000000-0000-0000-0000-000000000001'::uuid,
    'c1000000-0000-0000-0000-000000000002'::uuid,
    'c1000000-0000-0000-0000-000000000003'::uuid,
    'c1000000-0000-0000-0000-000000000004'::uuid,
    'c1000000-0000-0000-0000-000000000005'::uuid
  );
END;
$$;

COMMIT;

SELECT id, name, sort_order, is_active
FROM public.categories
WHERE id IN (
  'c1000000-0000-0000-0000-000000000001'::uuid,
  'c1000000-0000-0000-0000-000000000002'::uuid,
  'c1000000-0000-0000-0000-000000000003'::uuid,
  'c1000000-0000-0000-0000-000000000004'::uuid,
  'c1000000-0000-0000-0000-000000000005'::uuid
)
ORDER BY sort_order;
