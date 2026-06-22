-- ===========================================
-- Esnafta Var - chat_messages grants migration
-- ===========================================
-- Purpose:
-- Persist the manual Supabase SQL Editor fix for public.chat_messages.
--
-- ChatView needs:
-- - SELECT to load messages, fetch realtime rows, and count unread messages.
-- - INSERT to send new messages.
-- - UPDATE to mark received messages as read.
--
-- DELETE is intentionally not granted.
-- anon is intentionally not granted access.
-- RLS policies are not changed by this migration.
-- ===========================================

GRANT SELECT, INSERT, UPDATE ON TABLE public.chat_messages TO authenticated;
