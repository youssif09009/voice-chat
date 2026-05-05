const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const { getAllRooms, serializeRoom, getRoom, createRoom } = require('./src/rooms');
const { registerSignaling } = require('./src/signaling');

const PORT = process.env.PORT || 3000;

// ---------------------------------------------------------------------------
// App setup
// ---------------------------------------------------------------------------
const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] },
});

// ---------------------------------------------------------------------------
// REST endpoints
// ---------------------------------------------------------------------------

/** GET /rooms — list all live rooms */
app.get('/rooms', (req, res) => {
  res.json(getAllRooms());
});

/** GET /rooms/:id — single room */
app.get('/rooms/:id', (req, res) => {
  const room = getRoom(req.params.id);
  if (!room) return res.status(404).json({ error: 'Room not found' });
  res.json(serializeRoom(room));
});

/**
 * POST /rooms — create a new room
 * Body: { name, hostName, hostEmoji, coverEmoji, maxSlots, category,
 *         isVip, tags, accentColor, announcement }
 */
app.post('/rooms', (req, res) => {
  const { name } = req.body;
  if (!name || typeof name !== 'string' || name.trim().length === 0) {
    return res.status(400).json({ error: 'Room name is required' });
  }
  const room = createRoom({ ...req.body, name: name.trim() });
  res.status(201).json(room);
});

/** Health check */
app.get('/health', (req, res) => res.json({ status: 'ok' }));

// ---------------------------------------------------------------------------
// Socket.IO signaling
// ---------------------------------------------------------------------------
registerSignaling(io);

// ---------------------------------------------------------------------------
// Start
// ---------------------------------------------------------------------------
server.listen(PORT, () => {
  console.log(`✅  Nexus Voice backend running on http://localhost:${PORT}`);
});
