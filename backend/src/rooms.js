/**
 * In-memory room store.
 * No seeded rooms — all rooms are created dynamically via POST /rooms.
 * Empty rooms are automatically deleted when the last participant leaves.
 */

const { randomUUID } = require('crypto');

// Map<roomId, { ...roomMeta, participants: Map<socketId, participantInfo> }>
const rooms = new Map();

// ---------------------------------------------------------------------------
// CRUD
// ---------------------------------------------------------------------------

function createRoom(opts) {
  const id = randomUUID();
  const room = {
    id,
    name: opts.name,
    hostName: opts.hostName ?? 'Host',
    hostEmoji: opts.hostEmoji ?? '🎙',
    coverEmoji: opts.coverEmoji ?? '🎵',
    maxSlots: opts.maxSlots ?? 999999,
    category: opts.category ?? 'social',
    isVip: opts.isVip ?? false,
    tags: opts.tags ?? [],
    accentColor: opts.accentColor ?? '#8B5CF6',
    announcement: opts.announcement ?? '',
    createdAt: Date.now(),
    participants: new Map(),
  };
  rooms.set(id, room);
  return serializeRoom(room);
}

function getRoom(roomId) {
  return rooms.get(roomId) ?? null;
}

function getAllRooms() {
  return Array.from(rooms.values()).map(serializeRoom);
}

function serializeRoom(room) {
  return {
    id: room.id,
    name: room.name,
    hostName: room.hostName,
    hostEmoji: room.hostEmoji,
    coverEmoji: room.coverEmoji,
    maxSlots: room.maxSlots,
    category: room.category,
    isVip: room.isVip,
    tags: room.tags,
    accentColor: room.accentColor,
    announcement: room.announcement,
    createdAt: room.createdAt,
    listenerCount: room.participants.size,
    participants: Array.from(room.participants.values()),
  };
}

// ---------------------------------------------------------------------------
// Participants
// ---------------------------------------------------------------------------

function joinRoom(roomId, socketId, username) {
  const room = rooms.get(roomId);
  if (!room) return null;

  const isFirst = room.participants.size === 0;
  const participant = {
    socketId,
    username,
    isHost: isFirst,
    isMuted: true,
    isBot: false,
    joinedAt: Date.now(),
  };
  room.participants.set(socketId, participant);
  return { participant, room: serializeRoom(room) };
}

/**
 * Add a virtual bot participant (no real socket).
 * Returns the bot participant and the updated serialized room.
 */
function addBotParticipant(roomId, botUsername) {
  const room = rooms.get(roomId);
  if (!room) return null;

  const botId = `bot_${randomUUID()}`;
  const bot = {
    socketId: botId,
    username: botUsername,
    isHost: false,
    isMuted: true,
    isBot: true,
    joinedAt: Date.now(),
  };
  room.participants.set(botId, bot);
  return { participant: bot, room: serializeRoom(room) };
}

function leaveRoom(socketId) {
  for (const [roomId, room] of rooms.entries()) {
    if (room.participants.has(socketId)) {
      room.participants.delete(socketId);

      // Auto-delete the room when it becomes empty
      if (room.participants.size === 0) {
        rooms.delete(roomId);
        console.log(`[room] deleted empty room: ${roomId}`);
        return { roomId, room: null };
      }

      return { roomId, room: serializeRoom(room) };
    }
  }
  return null;
}

function setMuted(socketId, isMuted) {
  for (const room of rooms.values()) {
    const p = room.participants.get(socketId);
    if (p) {
      p.isMuted = isMuted;
      return serializeRoom(room);
    }
  }
  return null;
}

/**
 * Host mutes a target participant by force.
 * Returns { roomSerialized, targetSocketId } or null if not authorized.
 */
function hostMuteParticipant(requesterSocketId, targetSocketId) {
  for (const room of rooms.values()) {
    const requester = room.participants.get(requesterSocketId);
    const target = room.participants.get(targetSocketId);
    if (!requester || !target) continue;
    if (!requester.isHost) return null; // not authorized
    target.isMuted = true;
    return { room: serializeRoom(room), targetSocketId };
  }
  return null;
}

/**
 * Host kicks a target participant.
 * Returns { roomId, roomSerialized, targetSocketId } or null if not authorized.
 */
function hostKickParticipant(requesterSocketId, targetSocketId) {
  for (const [roomId, room] of rooms.entries()) {
    const requester = room.participants.get(requesterSocketId);
    const target = room.participants.get(targetSocketId);
    if (!requester || !target) continue;
    if (!requester.isHost) return null; // not authorized
    room.participants.delete(targetSocketId);
    return { roomId, room: serializeRoom(room), targetSocketId };
  }
  return null;
}

function getRoomBySocket(socketId) {
  for (const room of rooms.values()) {
    if (room.participants.has(socketId)) return serializeRoom(room);
  }
  return null;
}

function getRoomIdBySocket(socketId) {
  for (const [roomId, room] of rooms.entries()) {
    if (room.participants.has(socketId)) return roomId;
  }
  return null;
}

module.exports = {
  createRoom,
  getRoom,
  getAllRooms,
  serializeRoom,
  joinRoom,
  addBotParticipant,
  leaveRoom,
  setMuted,
  hostMuteParticipant,
  hostKickParticipant,
  getRoomBySocket,
  getRoomIdBySocket,
};
