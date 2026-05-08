/**
 * Rankings / leaderboard routes.
 *
 * GET /api/rankings/agents   — top agents (invites + earnings)
 * GET /api/rankings/hosts    — top hosts (gifts + room time)
 */

const express = require('express');
const db = require('../db');

const router = express.Router();

// ---------------------------------------------------------------------------
// GET /api/rankings/agents?limit=20&period=monthly
// ---------------------------------------------------------------------------
router.get('/agents', (req, res) => {
  const limit  = Math.min(100, parseInt(req.query.limit ?? 20, 10));
  const period = req.query.period ?? 'monthly'; // monthly | weekly | alltime

  let timeFilter = '';
  if (period === 'monthly') {
    const { currentMonthPeriod } = require('../helpers');
    const p = currentMonthPeriod();
    timeFilter = `AND earn.created_at >= unixepoch('${p}-01')`;
  } else if (period === 'weekly') {
    timeFilter = `AND earn.created_at >= (unixepoch() - 7 * 86400)`;
  }

  const rows = db.prepare(`
    SELECT
      a.id,
      u.username,
      a.total_invites,
      a.active_invites,
      a.total_earnings,
      COALESCE(period_earn.total, 0) AS period_earnings,
      ROW_NUMBER() OVER (ORDER BY COALESCE(period_earn.total, 0) DESC) AS rank
    FROM agents a
    JOIN users u ON u.id = a.id
    LEFT JOIN (
      SELECT earn.user_id, SUM(earn.amount) AS total
      FROM earnings earn
      WHERE earn.type = 'agent_commission' ${timeFilter}
      GROUP BY earn.user_id
    ) period_earn ON period_earn.user_id = a.id
    WHERE a.status = 'active'
    ORDER BY period_earnings DESC
    LIMIT ?
  `).all(limit);

  res.json({ period, leaderboard: rows });
});

// ---------------------------------------------------------------------------
// GET /api/rankings/hosts?limit=20&period=monthly
// ---------------------------------------------------------------------------
router.get('/hosts', (req, res) => {
  const limit  = Math.min(100, parseInt(req.query.limit ?? 20, 10));
  const period = req.query.period ?? 'monthly';

  let timeFilter = '';
  if (period === 'monthly') {
    const { currentMonthPeriod } = require('../helpers');
    const p = currentMonthPeriod();
    timeFilter = `AND earn.created_at >= unixepoch('${p}-01')`;
  } else if (period === 'weekly') {
    timeFilter = `AND earn.created_at >= (unixepoch() - 7 * 86400)`;
  }

  const rows = db.prepare(`
    SELECT
      h.id,
      u.username,
      h.total_room_time,
      ROUND(h.total_room_time / 3600.0, 2) AS total_hours,
      h.total_gifts,
      h.total_earnings,
      COALESCE(period_earn.total, 0) AS period_earnings,
      ROW_NUMBER() OVER (ORDER BY COALESCE(period_earn.total, 0) DESC) AS rank
    FROM hosts h
    JOIN users u ON u.id = h.id
    LEFT JOIN (
      SELECT earn.user_id, SUM(earn.amount) AS total
      FROM earnings earn
      WHERE earn.type = 'host_commission' ${timeFilter}
      GROUP BY earn.user_id
    ) period_earn ON period_earn.user_id = h.id
    WHERE h.status = 'active'
    ORDER BY period_earnings DESC
    LIMIT ?
  `).all(limit);

  res.json({ period, leaderboard: rows });
});

module.exports = router;
