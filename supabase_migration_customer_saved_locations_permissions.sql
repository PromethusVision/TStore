BEGIN;

REVOKE ALL ON TABLE public.customer_saved_locations FROM anon;
GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE public.customer_saved_locations
  TO authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
