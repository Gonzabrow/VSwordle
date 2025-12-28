import { describe, it, expect, vi, beforeEach } from 'vitest';
import type * as Party from 'partykit/server';

// Mock the game module before importing the server
vi.mock('../game', async () => {
  const actual = await vi.importActual('../game');
  return {
    ...actual,
    getRandomWord: vi.fn(() => 'APPLE'),
  };
});

import WordleServer from '../index';

// Mock connection
function createMockConnection(id: string): Party.Connection {
  return {
    id,
    send: vi.fn(),
    close: vi.fn(),
    serializeAttachment: vi.fn(),
    deserializeAttachment: vi.fn(),
    socket: {} as WebSocket,
    state: undefined,
    setState: vi.fn(),
    unstable_setState: vi.fn(),
  } as unknown as Party.Connection;
}

// Mock room
function createMockRoom(id: string): Party.Room {
  const connections = new Map<string, Party.Connection>();

  return {
    id,
    internalID: id,
    name: 'vswordle',
    env: {},
    context: {
      parties: {} as any,
      ai: {} as any,
    },
    storage: {} as any,
    broadcast: vi.fn((data: string) => {
      // Broadcast to all connections
      for (const conn of connections.values()) {
        conn.send(data);
      }
    }),
    getConnections: vi.fn(() => connections.values()),
    getConnection: vi.fn((id: string) => connections.get(id)),
    // Helper to add connections for testing
    _addConnection: (conn: Party.Connection) => {
      connections.set(conn.id, conn);
    },
  } as unknown as Party.Room & { _addConnection: (conn: Party.Connection) => void };
}

// Mock connection context
function createMockContext(url: string): Party.ConnectionContext {
  return {
    request: {
      url,
      headers: new Headers(),
      method: 'GET',
    } as unknown as Request,
  } as Party.ConnectionContext;
}

describe('WordleServer', () => {
  let server: WordleServer;
  let mockRoom: Party.Room & { _addConnection: (conn: Party.Connection) => void };

  beforeEach(() => {
    mockRoom = createMockRoom('ABCD');
    server = new WordleServer(mockRoom);
  });

  describe('Room Creation', () => {
    it('should create room and send room_created message when first player connects', async () => {
      const conn = createMockConnection('conn1');
      mockRoom._addConnection(conn);
      const ctx = createMockContext('http://localhost:1999/party/ABCD');

      await server.onConnect(conn, ctx);

      expect(conn.send).toHaveBeenCalledTimes(1);
      const msg = JSON.parse((conn.send as any).mock.calls[0][0]);
      expect(msg.type).toBe('room_created');
      expect(msg.roomCode).toBe('ABCD');
      expect(msg.playerId).toMatch(/^player_/);
    });

    it('should start game when second player joins', async () => {
      const conn1 = createMockConnection('conn1');
      const conn2 = createMockConnection('conn2');
      mockRoom._addConnection(conn1);
      mockRoom._addConnection(conn2);
      const ctx = createMockContext('http://localhost:1999/party/ABCD');

      await server.onConnect(conn1, ctx);
      await server.onConnect(conn2, ctx);

      // Check that game_start was broadcast
      expect(mockRoom.broadcast).toHaveBeenCalled();
      const broadcastCalls = (mockRoom.broadcast as any).mock.calls;
      const messages = broadcastCalls.map((call: any) => JSON.parse(call[0]));
      expect(messages.some((m: any) => m.type === 'game_start')).toBe(true);
    });

    it('should reject third player with room_full error', async () => {
      const conn1 = createMockConnection('conn1');
      const conn2 = createMockConnection('conn2');
      const conn3 = createMockConnection('conn3');
      mockRoom._addConnection(conn1);
      mockRoom._addConnection(conn2);
      mockRoom._addConnection(conn3);
      const ctx = createMockContext('http://localhost:1999/party/ABCD');

      await server.onConnect(conn1, ctx);
      await server.onConnect(conn2, ctx);
      await server.onConnect(conn3, ctx);

      // Check that third player received error
      const conn3Calls = (conn3.send as any).mock.calls;
      const lastMsg = JSON.parse(conn3Calls[conn3Calls.length - 1][0]);
      expect(lastMsg.type).toBe('error');
      expect(lastMsg.code).toBe('room_full');
      expect(conn3.close).toHaveBeenCalled();
    });
  });

  describe('Game Flow', () => {
    it('should broadcast guess results when player submits valid guess', async () => {
      const conn1 = createMockConnection('conn1');
      const conn2 = createMockConnection('conn2');
      mockRoom._addConnection(conn1);
      mockRoom._addConnection(conn2);
      const ctx = createMockContext('http://localhost:1999/party/ABCD');

      await server.onConnect(conn1, ctx);
      await server.onConnect(conn2, ctx);

      // Clear previous calls
      (mockRoom.broadcast as any).mockClear();

      // Player 1 submits a guess
      await server.onMessage(JSON.stringify({ type: 'guess', word: 'ABOUT' }), conn1);

      // Check broadcast
      expect(mockRoom.broadcast).toHaveBeenCalled();
      const msg = JSON.parse((mockRoom.broadcast as any).mock.calls[0][0]);
      expect(msg.type).toBe('guess_result');
      expect(msg.word).toBe('ABOUT');
      expect(msg.results).toHaveLength(5);
    });

    it('should reject invalid word with error', async () => {
      const conn1 = createMockConnection('conn1');
      const conn2 = createMockConnection('conn2');
      mockRoom._addConnection(conn1);
      mockRoom._addConnection(conn2);
      const ctx = createMockContext('http://localhost:1999/party/ABCD');

      await server.onConnect(conn1, ctx);
      await server.onConnect(conn2, ctx);

      // Clear previous calls
      (conn1.send as any).mockClear();

      // Player 1 submits invalid word
      await server.onMessage(JSON.stringify({ type: 'guess', word: 'XXXXX' }), conn1);

      // Check error was sent to player 1
      expect(conn1.send).toHaveBeenCalled();
      const msg = JSON.parse((conn1.send as any).mock.calls[0][0]);
      expect(msg.type).toBe('error');
      expect(msg.code).toBe('invalid_word');
    });

    it('should end game when player guesses correctly', async () => {
      const conn1 = createMockConnection('conn1');
      const conn2 = createMockConnection('conn2');
      mockRoom._addConnection(conn1);
      mockRoom._addConnection(conn2);
      const ctx = createMockContext('http://localhost:1999/party/ABCD');

      await server.onConnect(conn1, ctx);
      await server.onConnect(conn2, ctx);

      // Player 1 submits correct guess (answer is mocked to 'APPLE')
      await server.onMessage(JSON.stringify({ type: 'guess', word: 'APPLE' }), conn1);

      // Check that game_over was sent
      const conn1Calls = (conn1.send as any).mock.calls;
      const messages = conn1Calls.map((call: any) => JSON.parse(call[0]));
      const gameOverMsg = messages.find((m: any) => m.type === 'game_over');
      expect(gameOverMsg).toBeDefined();
      expect(gameOverMsg.answer).toBe('APPLE');
    });
  });

  describe('Typing Sync', () => {
    it('should forward typing to opponent', async () => {
      const conn1 = createMockConnection('conn1');
      const conn2 = createMockConnection('conn2');
      mockRoom._addConnection(conn1);
      mockRoom._addConnection(conn2);
      const ctx = createMockContext('http://localhost:1999/party/ABCD');

      await server.onConnect(conn1, ctx);
      await server.onConnect(conn2, ctx);

      // Clear previous calls
      (conn2.send as any).mockClear();

      // Player 1 types
      await server.onMessage(JSON.stringify({ type: 'typing', currentGuess: 'APP' }), conn1);

      // Check that opponent received typing
      expect(conn2.send).toHaveBeenCalled();
      const msg = JSON.parse((conn2.send as any).mock.calls[0][0]);
      expect(msg.type).toBe('opponent_typing');
      expect(msg.currentGuess).toBe('APP');
    });
  });

  describe('Disconnection', () => {
    it('should notify opponent when player disconnects', async () => {
      const conn1 = createMockConnection('conn1');
      const conn2 = createMockConnection('conn2');
      mockRoom._addConnection(conn1);
      mockRoom._addConnection(conn2);
      const ctx = createMockContext('http://localhost:1999/party/ABCD');

      await server.onConnect(conn1, ctx);
      await server.onConnect(conn2, ctx);

      // Clear previous calls
      (conn2.send as any).mockClear();

      // Player 1 disconnects
      await server.onClose(conn1);

      // Check that opponent received disconnect notification
      expect(conn2.send).toHaveBeenCalled();
      const msg = JSON.parse((conn2.send as any).mock.calls[0][0]);
      expect(msg.type).toBe('player_disconnected');
      expect(msg.reconnectTimeoutSeconds).toBe(30);
    });
  });

  describe('Reconnection', () => {
    it('should allow player to reconnect with playerId', async () => {
      const conn1 = createMockConnection('conn1');
      const conn2 = createMockConnection('conn2');
      mockRoom._addConnection(conn1);
      mockRoom._addConnection(conn2);

      // First player connects
      await server.onConnect(conn1, createMockContext('http://localhost:1999/party/ABCD'));

      // Get player 1's ID
      const msg = JSON.parse((conn1.send as any).mock.calls[0][0]);
      const player1Id = msg.playerId;

      // Second player connects
      await server.onConnect(conn2, createMockContext('http://localhost:1999/party/ABCD'));

      // Player 1 disconnects
      await server.onClose(conn1);

      // Player 1 reconnects with new connection
      const conn1New = createMockConnection('conn1-new');
      mockRoom._addConnection(conn1New);
      await server.onConnect(
        conn1New,
        createMockContext(`http://localhost:1999/party/ABCD?playerId=${player1Id}`)
      );

      // Check that state_resync was sent
      const reconnectMsgs = (conn1New.send as any).mock.calls.map((c: any) => JSON.parse(c[0]));
      const resyncMsg = reconnectMsgs.find((m: any) => m.type === 'state_resync');
      expect(resyncMsg).toBeDefined();
      expect(resyncMsg.roomCode).toBe('ABCD');
      expect(resyncMsg.status).toBe('playing');
    });
  });
});
