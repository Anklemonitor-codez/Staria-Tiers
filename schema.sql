-- ══════════════════════════════════════════════════════════════
-- PvP Tiers — Supabase Schema
-- Run this entire file in the Supabase SQL Editor
-- Dashboard → SQL Editor → New Query → Paste → Run
-- ══════════════════════════════════════════════════════════════

-- ── Players table ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.players (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username    TEXT NOT NULL,
  notes       TEXT DEFAULT '',

  -- Gamemode ranks stored as a JSONB object:
  -- { "crystal": "ht1", "sword": "ht3", "mace": "lt2", ... }
  -- Absent keys = unranked in that gamemode
  ranks       JSONB NOT NULL DEFAULT '{}'::jsonb,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Enforce unique usernames (case-insensitive)
  CONSTRAINT players_username_key UNIQUE (LOWER(username))
);

-- Index on username for fast lookups
CREATE INDEX IF NOT EXISTS idx_players_username ON public.players (LOWER(username));

-- GIN index on ranks for fast JSONB queries
CREATE INDEX IF NOT EXISTS idx_players_ranks ON public.players USING GIN (ranks);

-- Auto-update updated_at on any row change
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_players_updated_at ON public.players;
CREATE TRIGGER trg_players_updated_at
  BEFORE UPDATE ON public.players
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ══════════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY (RLS)
-- Public can read. Only authenticated admins can write.
-- ══════════════════════════════════════════════════════════════

ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;

-- Anyone can SELECT (public leaderboard)
CREATE POLICY "Public read"
  ON public.players
  FOR SELECT
  USING (true);

-- Only authenticated users can INSERT / UPDATE / DELETE
-- Your admin logs in via Supabase Auth; the anon key cannot write.
CREATE POLICY "Auth insert"
  ON public.players
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Auth update"
  ON public.players
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Auth delete"
  ON public.players
  FOR DELETE
  TO authenticated
  USING (true);


-- ══════════════════════════════════════════════════════════════
-- ENABLE REALTIME
-- ══════════════════════════════════════════════════════════════

-- Add the players table to the realtime publication so the
-- frontend receives live updates whenever a row changes.
ALTER PUBLICATION supabase_realtime ADD TABLE public.players;


-- ══════════════════════════════════════════════════════════════
-- SEED DATA (optional — delete this block after testing)
-- ══════════════════════════════════════════════════════════════

INSERT INTO public.players (username, notes, ranks) VALUES
  ('Technoblade', 'Legendary', '{"crystal":"ht1","sword":"ht1","axe":"ht2","mace":"ht2","uhc":"ht1"}'),
  ('Dream',       'Speedrunner', '{"crystal":"ht1","mace":"ht2","sword":"ht2","uhc":"ht1"}'),
  ('Sapnap',      '',        '{"crystal":"ht2","mace":"ht3","sword":"ht2","uhc":"ht3"}'),
  ('BadBoyHalo',  '',        '{"crystal":"ht3","sword":"ht3","axe":"ht3"}'),
  ('Skeppy',      '',        '{"crystal":"ht3","mace":"lt1","sword":"lt1"}'),
  ('Fundy',       '',        '{"crystal":"ht4","sword":"ht4","axe":"ht4"}'),
  ('Quackity',    '',        '{"crystal":"ht4","mace":"ht5","sword":"ht5"}'),
  ('Karl',        '',        '{"crystal":"ht5","sword":"lt1"}'),
  ('Tubbo',       '',        '{"crystal":"lt1","mace":"lt2"}'),
  ('TommyInnit',  '',        '{"crystal":"lt2","sword":"lt2","spearmace":"lt1"}')
ON CONFLICT (LOWER(username)) DO NOTHING;
