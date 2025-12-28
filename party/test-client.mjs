// Simple WebSocket test client for PartyKit server
import WebSocket from 'ws';

const ROOM_CODE = 'TEST';
const SERVER_URL = `ws://127.0.0.1:1999/party/${ROOM_CODE}`;

async function testConnection(name) {
  return new Promise((resolve, reject) => {
    console.log(`[${name}] Connecting to ${SERVER_URL}...`);
    const ws = new WebSocket(SERVER_URL);

    ws.on('open', () => {
      console.log(`[${name}] Connected!`);
    });

    ws.on('message', (data) => {
      const msg = JSON.parse(data.toString());
      console.log(`[${name}] Received:`, JSON.stringify(msg, null, 2));

      // If game started, send a guess
      if (msg.type === 'game_start') {
        console.log(`[${name}] Game started! Sending guess...`);
        setTimeout(() => {
          ws.send(JSON.stringify({ type: 'guess', word: 'APPLE' }));
        }, 500);
      }

      // If we received room_created or game_start, resolve for the first client
      if (msg.type === 'room_created') {
        resolve({ ws, playerId: msg.playerId, roomCode: msg.roomCode });
      }
    });

    ws.on('error', (err) => {
      console.error(`[${name}] Error:`, err.message);
      reject(err);
    });

    ws.on('close', () => {
      console.log(`[${name}] Disconnected`);
    });
  });
}

async function main() {
  console.log('=== PartyKit WebSocket Test ===\n');

  // Player 1 connects and creates room
  const player1 = await testConnection('Player1');
  console.log(`\nPlayer1 joined room: ${player1.roomCode}\n`);

  // Wait a bit then Player 2 connects
  await new Promise(r => setTimeout(r, 1000));

  console.log('Player2 connecting...\n');
  const ws2 = new WebSocket(SERVER_URL);

  ws2.on('open', () => {
    console.log('[Player2] Connected!');
  });

  ws2.on('message', (data) => {
    const msg = JSON.parse(data.toString());
    console.log('[Player2] Received:', JSON.stringify(msg, null, 2));

    if (msg.type === 'game_start') {
      console.log('[Player2] Game started! Sending different guess...');
      setTimeout(() => {
        ws2.send(JSON.stringify({ type: 'guess', word: 'ABOUT' }));
      }, 1000);
    }
  });

  ws2.on('error', (err) => {
    console.error('[Player2] Error:', err.message);
  });

  // Keep running for 10 seconds to see messages
  await new Promise(r => setTimeout(r, 10000));

  console.log('\n=== Test complete ===');
  player1.ws.close();
  ws2.close();
  process.exit(0);
}

main().catch(console.error);
