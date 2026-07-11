-- migrations/0002_invite_links.sql  (Turso / libSQL, SQLite dialect)
-- Phase 4: participant invite links + membership.
--   * meal_sessions.invite_token — the shareable capability a participant uses
--     to join a meal they don't own. Rotatable (rotate = replace the value).
--   * meal_participants — records who has joined a meal. Powers the "joined
--     meals" list, return access without the link, and participant "leave".
-- A UNIQUE index (not an inline column constraint) is used because SQLite can't
-- add a UNIQUE column via ALTER TABLE; NULLs are distinct, so meals created
-- before this migration (token still NULL) don't collide.

ALTER TABLE meal_sessions ADD COLUMN invite_token TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS idx_meal_sessions_invite_token
  ON meal_sessions(invite_token);

CREATE TABLE IF NOT EXISTS meal_participants (
  id              TEXT PRIMARY KEY,
  meal_session_id TEXT NOT NULL REFERENCES meal_sessions(id) ON DELETE CASCADE,
  user_id         TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  joined_at       TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now')),
  UNIQUE (meal_session_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_meal_participants_user ON meal_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_meal_participants_meal ON meal_participants(meal_session_id);

INSERT INTO schema_migrations (version) VALUES ('0002_invite_links');
