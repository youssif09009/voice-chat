/**
 * Database setup — SQLite via better-sqlite3.
 * Schema is fully compatible with PostgreSQL if you migrate later.
 * All tables are created on first run (idempotent).
 */

const Database = require('better-sqlite3');
const path = require('path');

const DB_PATH = process.env.DB_PATH || path.join(__dirname, '..', 'data', 'app.db');

// Ensure the data directory exists
const fs = require('fs');
const dataDir = path.dirname(DB_PATH);
if (!fs.existsSync(dataDir)) fs.mkdirSync(dataDir, { recursive: true });

const db = new Database(DB_PATH);

// Enable WAL mode for better concurrent read performance
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

// ---------------------------------------------------------------------------
// Schema
// ---------------------------------------------------------------------------
db.exec(`
  -- -------------------------------------------------------------------------
  -- Users
  -- -------------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS users (
    id          TEXT PRIMARY KEY,
    username    TEXT NOT NULL UNIQUE,
    email       TEXT NOT NULL UNIQUE,
    password    TEXT NOT NULL,
    role        TEXT NOT NULL DEFAULT 'user',   -- user | agent | host | admin
    status      TEXT NOT NULL DEFAULT 'active', -- active | banned | suspended
    invited_by  TEXT REFERENCES users(id),
    created_at  INTEGER NOT NULL DEFAULT (unixepoch()),
    updated_at  INTEGER NOT NULL DEFAULT (unixepoch())
  );

  -- -------------------------------------------------------------------------
  -- Agents
  -- -------------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS agents (
    id              TEXT PRIMARY KEY REFERENCES users(id),
    invite_code     TEXT NOT NULL UNIQUE,
    status          TEXT NOT NULL DEFAULT 'pending',  -- pending | active | suspended
    commission_rate REAL NOT NULL DEFAULT 0.10,       -- 10%
    total_invites   INTEGER NOT NULL DEFAULT 0,
    active_invites  INTEGER NOT NULL DEFAULT 0,
    total_earnings  REAL NOT NULL DEFAULT 0,
    cycle_start     INTEGER NOT NULL DEFAULT (unixepoch()),
    approved_at     INTEGER,
    approved_by     TEXT REFERENCES users(id)
  );

  -- -------------------------------------------------------------------------
  -- Hosts
  -- -------------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS hosts (
    id              TEXT PRIMARY KEY REFERENCES users(id),
    status          TEXT NOT NULL DEFAULT 'pending',  -- pending | active | suspended
    commission_rate REAL NOT NULL DEFAULT 0.50,       -- 50% of gifts
    total_room_time INTEGER NOT NULL DEFAULT 0,       -- seconds
    total_gifts     REAL NOT NULL DEFAULT 0,
    total_earnings  REAL NOT NULL DEFAULT 0,
    approved_at     INTEGER,
    approved_by     TEXT REFERENCES users(id)
  );

  -- -------------------------------------------------------------------------
  -- Invitations  (agent → invited user)
  -- -------------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS invitations (
    id          TEXT PRIMARY KEY,
    agent_id    TEXT NOT NULL REFERENCES agents(id),
    invitee_id  TEXT NOT NULL REFERENCES users(id),
    created_at  INTEGER NOT NULL DEFAULT (unixepoch()),
    UNIQUE(agent_id, invitee_id)
  );

  -- -------------------------------------------------------------------------
  -- Gifts
  -- -------------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS gifts (
    id          TEXT PRIMARY KEY,
    sender_id   TEXT NOT NULL REFERENCES users(id),
    receiver_id TEXT NOT NULL REFERENCES users(id),  -- host user id
    room_id     TEXT,
    amount      REAL NOT NULL,                        -- coin value
    created_at  INTEGER NOT NULL DEFAULT (unixepoch())
  );

  -- -------------------------------------------------------------------------
  -- Earnings  (ledger — one row per transaction)
  -- -------------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS earnings (
    id          TEXT PRIMARY KEY,
    user_id     TEXT NOT NULL REFERENCES users(id),
    type        TEXT NOT NULL,   -- gift_received | agent_commission | host_commission
    amount      REAL NOT NULL,
    ref_id      TEXT,            -- gift id that triggered this
    created_at  INTEGER NOT NULL DEFAULT (unixepoch())
  );

  -- -------------------------------------------------------------------------
  -- Targets
  -- -------------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS targets (
    id          TEXT PRIMARY KEY,
    user_id     TEXT NOT NULL REFERENCES users(id),
    role        TEXT NOT NULL,   -- agent | host
    metric      TEXT NOT NULL,   -- invites | active_hours | coins_earned
    goal        REAL NOT NULL,
    current     REAL NOT NULL DEFAULT 0,
    cycle       TEXT NOT NULL,   -- monthly | weekly
    period      TEXT NOT NULL,   -- e.g. "2026-05" or "2026-W18"
    created_at  INTEGER NOT NULL DEFAULT (unixepoch()),
    UNIQUE(user_id, metric, period)
  );

  -- -------------------------------------------------------------------------
  -- Room sessions  (for host time tracking)
  -- -------------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS room_sessions (
    id          TEXT PRIMARY KEY,
    host_id     TEXT NOT NULL REFERENCES users(id),
    room_id     TEXT NOT NULL,
    started_at  INTEGER NOT NULL DEFAULT (unixepoch()),
    ended_at    INTEGER,
    duration    INTEGER          -- seconds, filled on close
  );

  -- -------------------------------------------------------------------------
  -- Indexes
  -- -------------------------------------------------------------------------
  CREATE INDEX IF NOT EXISTS idx_users_invited_by   ON users(invited_by);
  CREATE INDEX IF NOT EXISTS idx_invitations_agent  ON invitations(agent_id);
  CREATE INDEX IF NOT EXISTS idx_gifts_sender       ON gifts(sender_id);
  CREATE INDEX IF NOT EXISTS idx_gifts_receiver     ON gifts(receiver_id);
  CREATE INDEX IF NOT EXISTS idx_earnings_user      ON earnings(user_id);
  CREATE INDEX IF NOT EXISTS idx_targets_user       ON targets(user_id);
  CREATE INDEX IF NOT EXISTS idx_sessions_host      ON room_sessions(host_id);
`);

// ---------------------------------------------------------------------------
// Extended schema — Agency Categorization, Financial, Hierarchy, Recharge
// ---------------------------------------------------------------------------
db.exec(`
  -- -------------------------------------------------------------------------
  -- Agency Types  (USDT | Recharge | Country | Shipping)
  -- -------------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS agency_types (
    id              TEXT PRIMARY KEY,
    agent_id        TEXT NOT NULL REFERENCES agents(id),
    type            TEXT NOT NULL,          -- usdt | recharge | country | shipping
    status          TEXT NOT NULL DEFAULT 'pending',
    -- USDT-specific
    wallet_address  TEXT,
    -- Recharge-specific
    diamond_credit_limit INTEGER,
    -- Country-specific
    region          TEXT,
    country_code    TEXT,
    -- Shipping-specific
    max_transfer_cap REAL,
    created_at      INTEGER NOT NULL DEFAULT (unixepoch()),
    updated_at      INTEGER NOT NULL DEFAULT (unixepoch()),
    UNIQUE(agent_id, type)
  );

  -- -------------------------------------------------------------------------
  -- Subordinate agents  (master → subordinate hierarchy)
  -- -------------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS subordinate_agents (
    id              TEXT PRIMARY KEY,
    master_id       TEXT NOT NULL REFERENCES agents(id),
    subordinate_id  TEXT NOT NULL REFERENCES agents(id),
    commission_rate REAL NOT NULL DEFAULT 0.08,
    status          TEXT NOT NULL DEFAULT 'active',
    created_at      INTEGER NOT NULL DEFAULT (unixepoch()),
    UNIQUE(master_id, subordinate_id)
  );

  -- -------------------------------------------------------------------------
  -- Referral log  (agent-led invitations + activity events)
  -- -------------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS referral_log (
    id          TEXT PRIMARY KEY,
    agent_id    TEXT NOT NULL REFERENCES agents(id),
    invitee_id  TEXT NOT NULL REFERENCES users(id),
    event_type  TEXT NOT NULL DEFAULT 'registration',  -- registration | gift | recharge
    event_ref   TEXT,                                   -- gift_id or order_id
    commission  REAL NOT NULL DEFAULT 0,
    created_at  INTEGER NOT NULL DEFAULT (unixepoch())
  );

  -- -------------------------------------------------------------------------
  -- Withdrawal requests
  -- -------------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS withdrawals (
    id              TEXT PRIMARY KEY,
    agent_id        TEXT NOT NULL REFERENCES agents(id),
    amount          REAL NOT NULL,
    method          TEXT NOT NULL,   -- vodafone_cash | instapay | bank | usdt
    account_details TEXT NOT NULL,
    status          TEXT NOT NULL DEFAULT 'pending',  -- pending | approved | rejected
    rejection_reason TEXT,
    requested_at    INTEGER NOT NULL DEFAULT (unixepoch()),
    resolved_at     INTEGER,
    resolved_by     TEXT REFERENCES users(id)
  );

  -- -------------------------------------------------------------------------
  -- Recharge orders  (multi-gateway Diamond top-ups)
  -- -------------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS recharge_orders (
    id              TEXT PRIMARY KEY,
    user_id         TEXT NOT NULL REFERENCES users(id),
    diamond_amount  INTEGER NOT NULL,
    price_egp       REAL NOT NULL,
    gateway         TEXT NOT NULL,   -- fawry | usdt | google_pay | card
    status          TEXT NOT NULL DEFAULT 'pending',  -- pending | success | failed | refunded
    -- USDT-specific
    tx_id           TEXT,
    wallet_address  TEXT,
    -- Fawry-specific
    fawry_ref       TEXT,
    created_at      INTEGER NOT NULL DEFAULT (unixepoch()),
    updated_at      INTEGER NOT NULL DEFAULT (unixepoch())
  );

  -- -------------------------------------------------------------------------
  -- USDT settlement requests  (agent crypto payouts)
  -- -------------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS usdt_settlements (
    id              TEXT PRIMARY KEY,
    agent_id        TEXT NOT NULL REFERENCES agents(id),
    tx_id           TEXT NOT NULL,
    diamond_amount  INTEGER NOT NULL,
    status          TEXT NOT NULL DEFAULT 'pending',  -- pending | approved | rejected
    rejection_reason TEXT,
    submitted_at    INTEGER NOT NULL DEFAULT (unixepoch()),
    resolved_at     INTEGER,
    resolved_by     TEXT REFERENCES users(id)
  );

  -- -------------------------------------------------------------------------
  -- Bonus records  (performance rewards)
  -- -------------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS bonuses (
    id          TEXT PRIMARY KEY,
    agent_id    TEXT NOT NULL REFERENCES agents(id),
    type        TEXT NOT NULL,   -- invite_bonus | volume_bonus | full_bonus
    amount      REAL NOT NULL,
    period      TEXT NOT NULL,
    claimed     INTEGER NOT NULL DEFAULT 0,
    claimed_at  INTEGER,
    created_at  INTEGER NOT NULL DEFAULT (unixepoch())
  );

  -- -------------------------------------------------------------------------
  -- Extended indexes
  -- -------------------------------------------------------------------------
  CREATE INDEX IF NOT EXISTS idx_agency_types_agent    ON agency_types(agent_id);
  CREATE INDEX IF NOT EXISTS idx_subordinates_master   ON subordinate_agents(master_id);
  CREATE INDEX IF NOT EXISTS idx_referral_agent        ON referral_log(agent_id);
  CREATE INDEX IF NOT EXISTS idx_withdrawals_agent     ON withdrawals(agent_id);
  CREATE INDEX IF NOT EXISTS idx_recharge_user         ON recharge_orders(user_id);
  CREATE INDEX IF NOT EXISTS idx_usdt_agent            ON usdt_settlements(agent_id);
  CREATE INDEX IF NOT EXISTS idx_bonuses_agent         ON bonuses(agent_id);
`);

// ---------------------------------------------------------------------------
// Seed a default admin if none exists
// ---------------------------------------------------------------------------
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');

const adminExists = db.prepare(`SELECT id FROM users WHERE role = 'admin' LIMIT 1`).get();
if (!adminExists) {
  const hash = bcrypt.hashSync('admin123', 10);
  db.prepare(`
    INSERT INTO users (id, username, email, password, role)
    VALUES (?, 'admin', 'admin@app.com', ?, 'admin')
  `).run(uuidv4(), hash);
  console.log('[db] default admin created  →  admin@app.com / admin123');
}

module.exports = db;
