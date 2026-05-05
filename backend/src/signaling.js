/**
 * WebRTC signaling + room event handler.
 */

const {
  joinRoom,
  addBotParticipant,
  leaveRoom,
  setMuted,
  hostMuteParticipant,
  hostKickParticipant,
  getRoomBySocket,
  getRoomIdBySocket,
} = require('./rooms');

// ---------------------------------------------------------------------------
// Bot pool — 3 test users injected with staggered delays
// ---------------------------------------------------------------------------
const BOT_POOL = [
  { username: 'TestUser_01', emoji: '🤖' },
  { username: 'TestUser_02', emoji: '👾' },
  { username: 'TestUser_03', emoji: '🎭' },
];

/**
 * Inject all bots into a room with staggered 1-second delays.
 * Each bot emits peer_joined to the whole room so the host sees them appear
 * one by one — exactly like real users joining.
 */
function injectBots(io, roomId) {
  BOT_POOL.forEach((bot, i) => {
    setTimeout(() => {
      const result = addBotParticipant(roomId, bot.username);
      if (!result) return; // room was deleted before timeout fired
      io.to(roomId).emit('peer_joined', {
        participant: result.participant,
        room: result.room,
      });
      console.log(`[bot] ${bot.username} joined ${roomId}`);
    }, (i + 1) * 1200); // 1.2s, 2.4s, 3.6s
  });
}

// ---------------------------------------------------------------------------
// Signaling
// ---------------------------------------------------------------------------

function registerSignaling(io) {
  io.on('connection', (socket) => {
    console.log(`[socket] connected: ${socket.id}`);

    // ----------------------------------------------------------------
    // Join a room
    // ----------------------------------------------------------------
    socket.on('join_room', ({ roomId, username }) => {
      const result = joinRoom(roomId, socket.id, username ?? 'Guest');
      if (!result) {
        socket.emit('error', { message: 'Room not found' });
        return;
      }

      socket.join(roomId);

      socket.emit('room_joined', {
        room: result.room,
        you: result.participant,
      });

      socket.to(roomId).emit('peer_joined', {
        participant: result.participant,
        room: result.room,
      });

      console.log(`[room] ${username} joined ${roomId}`);

      // Inject bots when the first real user (host) joins
      if (result.participant.isHost) {
        injectBots(io, roomId);
      }
    });

    // ----------------------------------------------------------------
    // WebRTC relay
    // ----------------------------------------------------------------
    socket.on('webrtc_offer', ({ targetSocketId, sdp }) => {
      // Bots have no real socket — silently ignore offers to them
      if (targetSocketId.startsWith('bot_')) return;
      io.to(targetSocketId).emit('webrtc_offer', { fromSocketId: socket.id, sdp });
    });

    socket.on('webrtc_answer', ({ targetSocketId, sdp }) => {
      if (targetSocketId.startsWith('bot_')) return;
      io.to(targetSocketId).emit('webrtc_answer', { fromSocketId: socket.id, sdp });
    });

    socket.on('webrtc_ice', ({ targetSocketId, candidate }) => {
      if (targetSocketId.startsWith('bot_')) return;
      io.to(targetSocketId).emit('webrtc_ice', { fromSocketId: socket.id, candidate });
    });

    // ----------------------------------------------------------------
    // Self mute / unmute
    // ----------------------------------------------------------------
    socket.on('set_muted', ({ isMuted }) => {
      const room = getRoomBySocket(socket.id);
      if (!room) return;
      const updated = setMuted(socket.id, isMuted);
      if (updated) {
        io.to(updated.id).emit('participant_muted', {
          socketId: socket.id,
          isMuted,
          room: updated,
        });
      }
    });

    // ----------------------------------------------------------------
    // Host: force-mute a participant (works for bots too)
    // ----------------------------------------------------------------
    socket.on('host_mute', ({ targetSocketId }) => {
      const result = hostMuteParticipant(socket.id, targetSocketId);
      if (!result) {
        socket.emit('error', { message: 'Not authorized or user not found' });
        return;
      }

      // Only emit to real sockets (bots have no socket connection)
      if (!targetSocketId.startsWith('bot_')) {
        io.to(targetSocketId).emit('force_muted', { bySocketId: socket.id });
      }

      // Broadcast updated state to the whole room
      io.to(result.room.id).emit('participant_muted', {
        socketId: targetSocketId,
        isMuted: true,
        room: result.room,
      });

      console.log(`[host] ${socket.id} muted ${targetSocketId}`);
    });

    // ----------------------------------------------------------------
    // Host: kick a participant (works for bots too)
    // ----------------------------------------------------------------
    socket.on('host_kick', ({ targetSocketId }) => {
      const roomId = getRoomIdBySocket(socket.id);
      const result = hostKickParticipant(socket.id, targetSocketId);
      if (!result) {
        socket.emit('error', { message: 'Not authorized or user not found' });
        return;
      }

      // Only emit to real sockets
      if (!targetSocketId.startsWith('bot_')) {
        io.to(targetSocketId).emit('kicked', { bySocketId: socket.id, roomId });
      }

      // Broadcast peer_left to the room
      if (result.room) {
        io.to(result.roomId).emit('peer_left', {
          socketId: targetSocketId,
          room: result.room,
        });
      }

      console.log(`[host] ${socket.id} kicked ${targetSocketId}`);
    });

    // ----------------------------------------------------------------
    // Chat message
    // ----------------------------------------------------------------
    socket.on('chat_message', ({ roomId, text }) => {
      const room = getRoomBySocket(socket.id);
      if (!room) return;
      const sender = room.participants.find((p) => p.socketId === socket.id);
      io.to(roomId).emit('chat_message', {
        sender: sender?.username ?? 'Unknown',
        text,
        timestamp: Date.now(),
      });
    });

    // ----------------------------------------------------------------
    // Disconnect
    // ----------------------------------------------------------------
    socket.on('disconnect', () => {
      const result = leaveRoom(socket.id);
      if (result) {
        if (result.room) {
          io.to(result.roomId).emit('peer_left', {
            socketId: socket.id,
            room: result.room,
          });
        }
        console.log(`[room] ${socket.id} left ${result.roomId}`);
      }
      console.log(`[socket] disconnected: ${socket.id}`);
    });
  });
}

module.exports = { registerSignaling };
