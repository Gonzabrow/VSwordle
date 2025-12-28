import type * as Party from 'partykit/server';
import type {
  ClientMessage,
  ServerMessage,
  RoomState,
  PlayerState,
  LetterResult,
  RoomStatus,
} from './types';
import {
  checkGuess,
  isValidWord,
  isWinningGuess,
  getRandomWord,
  generateRoomCode,
  MAX_GUESSES,
} from './game';

// Reconnection timeout in milliseconds (30 seconds)
const RECONNECT_TIMEOUT_MS = 30_000;

export default class WordleServer implements Party.Server {
  // Room state
  private roomCode: string;
  private status: RoomStatus = 'waiting';
  private answer: string = '';
  private players: Map<string, PlayerState> = new Map();
  private createdAt: number = Date.now();
  private winnerId?: string;

  // Connection management
  private connectionToPlayer: Map<string, string> = new Map(); // connectionId -> playerId
  private playerToConnection: Map<string, string> = new Map(); // playerId -> connectionId
  private disconnectTimers: Map<string, ReturnType<typeof setTimeout>> = new Map();

  constructor(readonly room: Party.Room) {
    // Use room ID as room code (PartyKit creates rooms with the ID from URL)
    this.roomCode = room.id;
  }

  // Handle new connection
  async onConnect(conn: Party.Connection, ctx: Party.ConnectionContext) {
    // Check URL params for player ID (for reconnection)
    const url = new URL(ctx.request.url);
    const existingPlayerId = url.searchParams.get('playerId');

    // Check if this is a reconnection
    if (existingPlayerId && this.players.has(existingPlayerId)) {
      await this.handleReconnection(conn, existingPlayerId);
      return;
    }

    // New player joining
    const playerId = this.generatePlayerId();

    // Check room capacity
    if (this.players.size >= 2) {
      this.sendToConnection(conn, {
        type: 'error',
        code: 'room_full',
        message: 'Room is full',
      });
      conn.close();
      return;
    }

    // Check if game already started
    if (this.status !== 'waiting' && this.players.size >= 2) {
      this.sendToConnection(conn, {
        type: 'error',
        code: 'room_full',
        message: 'Game already in progress',
      });
      conn.close();
      return;
    }

    // Add player to room
    const playerState: PlayerState = {
      id: playerId,
      guesses: [],
      currentGuess: '',
      isConnected: true,
      hasFinished: false,
    };
    this.players.set(playerId, playerState);
    this.connectionToPlayer.set(conn.id, playerId);
    this.playerToConnection.set(playerId, conn.id);

    // Send room created message to new player
    this.sendToConnection(conn, {
      type: 'room_created',
      roomCode: this.roomCode,
      playerId: playerId,
    });

    // If this is the second player, notify both and start game
    if (this.players.size === 2) {
      // Notify all players about the new player
      this.broadcast({
        type: 'player_joined',
        playerId: playerId,
      });

      // Start the game
      this.startGame();
    }
  }

  // Handle disconnection
  async onClose(conn: Party.Connection) {
    const playerId = this.connectionToPlayer.get(conn.id);
    if (!playerId) return;

    const player = this.players.get(playerId);
    if (!player) return;

    // Mark player as disconnected
    player.isConnected = false;

    // Notify opponent
    const opponentId = this.getOpponentId(playerId);
    if (opponentId) {
      this.sendToPlayer(opponentId, {
        type: 'player_disconnected',
        playerId: playerId,
        reconnectTimeoutSeconds: RECONNECT_TIMEOUT_MS / 1000,
      });
    }

    // Start disconnect timer
    const timer = setTimeout(() => {
      this.handleDisconnectTimeout(playerId);
    }, RECONNECT_TIMEOUT_MS);
    this.disconnectTimers.set(playerId, timer);
  }

  // Handle incoming messages
  async onMessage(message: string, sender: Party.Connection) {
    const playerId = this.connectionToPlayer.get(sender.id);
    if (!playerId) return;

    let msg: ClientMessage;
    try {
      msg = JSON.parse(message);
    } catch {
      return;
    }

    switch (msg.type) {
      case 'guess':
        await this.handleGuess(playerId, msg.word);
        break;
      case 'typing':
        await this.handleTyping(playerId, msg.currentGuess);
        break;
      case 'leave_room':
        await this.handleLeaveRoom(playerId, sender);
        break;
    }
  }

  // ============================================
  // Game Logic
  // ============================================

  private startGame() {
    this.status = 'playing';
    this.answer = getRandomWord();

    // Notify all players
    this.broadcast({ type: 'game_start' });
  }

  private async handleGuess(playerId: string, word: string) {
    const player = this.players.get(playerId);
    if (!player) return;

    // Validate game state
    if (this.status !== 'playing') {
      this.sendToPlayer(playerId, {
        type: 'error',
        code: 'game_not_started',
        message: 'Game has not started',
      });
      return;
    }

    // Check if player already finished
    if (player.hasFinished) {
      this.sendToPlayer(playerId, {
        type: 'error',
        code: 'already_finished',
        message: 'You have already finished',
      });
      return;
    }

    // Validate word
    const upperWord = word.toUpperCase();
    if (upperWord.length !== 5) {
      this.sendToPlayer(playerId, {
        type: 'error',
        code: 'invalid_word',
        message: 'Word must be 5 letters',
      });
      return;
    }

    if (!isValidWord(upperWord)) {
      this.sendToPlayer(playerId, {
        type: 'error',
        code: 'invalid_word',
        message: 'Not in word list',
      });
      return;
    }

    // Check guess against answer
    const results = checkGuess(upperWord, this.answer);
    const guessNumber = player.guesses.length + 1;

    // Update player state
    player.guesses.push({ word: upperWord, results });
    player.currentGuess = '';

    // Check for win
    const isWin = isWinningGuess(results);
    if (isWin) {
      player.hasFinished = true;
    } else if (player.guesses.length >= MAX_GUESSES) {
      player.hasFinished = true;
    }

    // Broadcast the guess result to all players
    this.broadcast({
      type: 'guess_result',
      playerId: playerId,
      word: upperWord,
      results: results,
      guessNumber: guessNumber,
    });

    // Check for game over conditions
    if (isWin) {
      this.endGame(playerId, 'win');
    } else {
      this.checkGameOver();
    }
  }

  private async handleTyping(playerId: string, currentGuess: string) {
    const player = this.players.get(playerId);
    if (!player) return;

    // Update player's current guess
    player.currentGuess = currentGuess.toUpperCase();

    // Forward typing to opponent
    const opponentId = this.getOpponentId(playerId);
    if (opponentId) {
      this.sendToPlayer(opponentId, {
        type: 'opponent_typing',
        currentGuess: player.currentGuess,
      });
    }
  }

  private async handleLeaveRoom(playerId: string, conn: Party.Connection) {
    // Clean up player
    this.players.delete(playerId);
    this.connectionToPlayer.delete(conn.id);
    this.playerToConnection.delete(playerId);

    // Cancel any disconnect timer
    const timer = this.disconnectTimers.get(playerId);
    if (timer) {
      clearTimeout(timer);
      this.disconnectTimers.delete(playerId);
    }

    // If game was in progress, other player wins by forfeit
    if (this.status === 'playing') {
      const opponentId = this.getOpponentId(playerId);
      if (opponentId) {
        this.endGame(opponentId, 'disconnect');
      }
    }

    conn.close();
  }

  private checkGameOver() {
    const players = Array.from(this.players.values());

    // Check if all players have finished
    const allFinished = players.every((p) => p.hasFinished);
    if (!allFinished) return;

    // Both players finished without winning - it's a draw
    this.endGame(null, 'draw');
  }

  private endGame(winnerId: string | null, result: 'win' | 'draw' | 'disconnect') {
    this.status = 'finished';
    this.winnerId = winnerId ?? undefined;

    // Send game over to all players
    for (const [playerId] of this.players) {
      let playerResult: 'win' | 'lose' | 'draw' | 'disconnect';

      if (result === 'draw') {
        playerResult = 'draw';
      } else if (result === 'disconnect') {
        playerResult = playerId === winnerId ? 'win' : 'disconnect';
      } else {
        playerResult = playerId === winnerId ? 'win' : 'lose';
      }

      this.sendToPlayer(playerId, {
        type: 'game_over',
        winnerId: winnerId,
        answer: this.answer,
        result: playerResult,
      });
    }
  }

  // ============================================
  // Reconnection Logic
  // ============================================

  private async handleReconnection(conn: Party.Connection, playerId: string) {
    const player = this.players.get(playerId);
    if (!player) {
      this.sendToConnection(conn, {
        type: 'error',
        code: 'room_not_found',
        message: 'Player not found in room',
      });
      conn.close();
      return;
    }

    // Cancel disconnect timer
    const timer = this.disconnectTimers.get(playerId);
    if (timer) {
      clearTimeout(timer);
      this.disconnectTimers.delete(playerId);
    }

    // Update connection mappings
    const oldConnId = this.playerToConnection.get(playerId);
    if (oldConnId) {
      this.connectionToPlayer.delete(oldConnId);
    }
    this.connectionToPlayer.set(conn.id, playerId);
    this.playerToConnection.set(playerId, conn.id);

    // Mark player as connected
    player.isConnected = true;

    // Notify opponent of reconnection
    const opponentId = this.getOpponentId(playerId);
    if (opponentId) {
      this.sendToPlayer(opponentId, {
        type: 'player_reconnected',
        playerId: playerId,
      });
    }

    // Send current state to reconnected player
    const opponent = opponentId ? this.players.get(opponentId) : undefined;
    this.sendToConnection(conn, {
      type: 'state_resync',
      roomCode: this.roomCode,
      status: this.status,
      myState: {
        guesses: player.guesses,
        currentGuess: player.currentGuess,
        isConnected: player.isConnected,
        hasFinished: player.hasFinished,
      },
      opponentState: opponent
        ? {
            guesses: opponent.guesses,
            currentGuess: opponent.currentGuess,
            isConnected: opponent.isConnected,
            hasFinished: opponent.hasFinished,
          }
        : undefined,
      opponentId: opponentId,
    });
  }

  private handleDisconnectTimeout(playerId: string) {
    this.disconnectTimers.delete(playerId);

    // Player didn't reconnect in time - they lose
    if (this.status === 'playing') {
      const opponentId = this.getOpponentId(playerId);
      if (opponentId) {
        this.endGame(opponentId, 'disconnect');
      }
    }

    // Clean up player
    const connId = this.playerToConnection.get(playerId);
    if (connId) {
      this.connectionToPlayer.delete(connId);
    }
    this.playerToConnection.delete(playerId);
    this.players.delete(playerId);
  }

  // ============================================
  // Utility Methods
  // ============================================

  private generatePlayerId(): string {
    return `player_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  private getOpponentId(playerId: string): string | undefined {
    for (const [id] of this.players) {
      if (id !== playerId) return id;
    }
    return undefined;
  }

  private sendToConnection(conn: Party.Connection, msg: ServerMessage) {
    conn.send(JSON.stringify(msg));
  }

  private sendToPlayer(playerId: string, msg: ServerMessage) {
    const connId = this.playerToConnection.get(playerId);
    if (!connId) return;

    const conn = this.room.getConnection(connId);
    if (conn) {
      conn.send(JSON.stringify(msg));
    }
  }

  private broadcast(msg: ServerMessage) {
    this.room.broadcast(JSON.stringify(msg));
  }
}
