# Nexus Voice — Full Stack Setup

## Architecture

```
backend/   Node.js + Express + Socket.IO  (port 3000)
client/    Flutter app
```

## Quick Start

### 1. Start the backend
```bash
cd backend
npm install
npm start
# Server runs at http://localhost:3000
```

### 2. Configure the Flutter client

Edit `client/lib/core/constants.dart`:

| Target              | serverUrl value              |
|---------------------|------------------------------|
| Android emulator    | `http://10.0.2.2:3000`       |
| Physical device     | `http://<YOUR_LAN_IP>:3000`  |
| Web / desktop       | `http://localhost:3000`      |

### 3. Run the Flutter app
```bash
cd client
flutter run
```

## What works end-to-end

1. App opens → **Voice Rooms Explorer** fetches rooms from the backend via REST.
2. Tap any room card → **Voice Room Screen** connects via Socket.IO.
3. Tap the **mic button** → requests microphone permission, starts WebRTC audio.
4. Multiple devices/tabs on the same network can join the same room and hear each other.
5. Chat messages are broadcast to everyone in the room in real time.
6. Participant slots update live as people join/leave.

## Backend REST API

| Method | Path         | Description          |
|--------|--------------|----------------------|
| GET    | /rooms       | List all rooms       |
| GET    | /rooms/:id   | Get a single room    |
| GET    | /health      | Health check         |

## Socket.IO Events

| Event              | Direction       | Payload                              |
|--------------------|-----------------|--------------------------------------|
| join_room          | client → server | { roomId, username }                 |
| room_joined        | server → client | { room, you }                        |
| peer_joined        | server → room   | { participant, room }                |
| peer_left          | server → room   | { socketId, room }                   |
| set_muted          | client → server | { isMuted }                          |
| participant_muted  | server → room   | { socketId, isMuted, room }          |
| chat_message       | bidirectional   | { roomId, text } / { sender, text }  |
| webrtc_offer       | peer → peer     | { targetSocketId, sdp }              |
| webrtc_answer      | peer → peer     | { targetSocketId, sdp }              |
| webrtc_ice         | peer → peer     | { targetSocketId, candidate }        |
