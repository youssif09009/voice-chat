/**
 * User routes — registration, login, profile.
 */

const express = require('express');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { signToken, requireAuth } = require('../auth');

const router = express.Router();

// ---------------------------------------------------------------------------
// POST /api/users/register
// Body: { username, email, password, inviteCode? }
// ---------------------------------------------------------------------------
router.post('/register', (req, res) => {
  const { username, email, password, inviteCode } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({ error: 'username, email, password required' });
  }

  // Check if user exists
  const existing = db.prepare(`SELECT id FROM users WHERE email = ? OR username = ?`).get(email, username);
  if (existing) {
    return res.status(400).json({ error: 'User already exists' });
  }

  // Hash password
  const hash = bcrypt.hashSync(password, 10);
  const userId = uuidv4();

  // If inviteCode provided, find the agent
  let invitedBy = null;
  if (inviteCode) {
    const agent = db.prepare(`SELECT id FROM agents WHERE invite_code = ? AND status = 'active'`).get(inviteCode);
    if (agent) invitedBy = agent.id;
  }

  // Insert user
  db.prepare(`
    INSERT INTO users (id, username, email, password, invited_by)
    VALUES (?, ?, ?, ?, ?)
  `).run(userId, username, email, hash, invitedBy);

  // If invited by an agent, record invitation
  if (invitedBy) {
    db.prepare(`
      INSERT INTO invitations (id, agent_id, invitee_id)
      VALUES (?, ?, ?)
    `).run(uuidv4(), invitedBy, userId);

    // Update agent stats
    db.prepare(`
      UPDATE agents
      SET total_invites = total_invites + 1,
          active_invites = active_invites + 1
      WHERE id = ?
    `).run(invitedBy);
  }

  const token = signToken({ id: userId, role: 'user' });
  res.status(201).json({ userId, token });
});

// ---------------------------------------------------------------------------
// POST /api/users/login
// Body: { email, password }
// ---------------------------------------------------------------------------
router.post('/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'email and password required' });
  }

  const user = db.prepare(`SELECT * FROM users WHERE email = ?`).get(email);
  if (!user || !bcrypt.compareSync(password, user.password)) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  if (user.status !== 'active') {
    return res.status(403).json({ error: 'Account is banned or suspended' });
  }

  const token = signToken({ id: user.id, role: user.role });
  res.json({ userId: user.id, username: user.username, role: user.role, token });
});

// ---------------------------------------------------------------------------
// GET /api/users/me
// ---------------------------------------------------------------------------
router.get('/me', requireAuth, (req, res) => {
  const user = db.prepare(`
    SELECT id, username, email, role, status, invited_by, created_at
    FROM users WHERE id = ?
  `).get(req.user.id);

  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json(user);
});

module.exports = router;
