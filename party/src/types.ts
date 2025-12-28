// Letter status enum matching Dart LetterStatus
export type LetterStatus = 'hit' | 'blow' | 'absent';

// Result for a single letter in a guess
export interface LetterResult {
  letter: string;
  status: LetterStatus;
}

// A complete guess with results
export interface Guess {
  word: string;
  results: LetterResult[];
}

// Player state in a game
export interface PlayerState {
  id: string;
  guesses: Guess[];
  currentGuess: string;
  isConnected: boolean;
  hasFinished: boolean; // true if player has won or used all 6 guesses
}

// Room status
export type RoomStatus = 'waiting' | 'playing' | 'finished';

// Game result type
export type GameResult = 'win' | 'lose' | 'draw' | 'disconnect';

// Room state
export interface RoomState {
  roomCode: string;
  status: RoomStatus;
  answer: string; // The secret word (server-only)
  players: Map<string, PlayerState>;
  createdAt: number;
  winnerId?: string;
}

// ============================================
// Client -> Server Messages
// ============================================

export interface CreateRoomMessage {
  type: 'create_room';
}

export interface JoinRoomMessage {
  type: 'join_room';
  roomCode: string;
}

export interface GuessMessage {
  type: 'guess';
  word: string;
}

export interface TypingMessage {
  type: 'typing';
  currentGuess: string;
}

export interface LeaveRoomMessage {
  type: 'leave_room';
}

export type ClientMessage =
  | CreateRoomMessage
  | JoinRoomMessage
  | GuessMessage
  | TypingMessage
  | LeaveRoomMessage;

// ============================================
// Server -> Client Messages
// ============================================

export interface RoomCreatedMessage {
  type: 'room_created';
  roomCode: string;
  playerId: string;
}

export interface PlayerJoinedMessage {
  type: 'player_joined';
  playerId: string;
}

export interface GameStartMessage {
  type: 'game_start';
}

export interface GuessResultMessage {
  type: 'guess_result';
  playerId: string;
  word: string;
  results: LetterResult[];
  guessNumber: number;
}

export interface OpponentTypingMessage {
  type: 'opponent_typing';
  currentGuess: string;
}

export interface GameOverMessage {
  type: 'game_over';
  winnerId: string | null; // null means draw
  answer: string;
  result: GameResult;
}

export interface PlayerDisconnectedMessage {
  type: 'player_disconnected';
  playerId: string;
  reconnectTimeoutSeconds: number;
}

export interface PlayerReconnectedMessage {
  type: 'player_reconnected';
  playerId: string;
}

export interface ErrorMessage {
  type: 'error';
  code: 'room_not_found' | 'room_full' | 'invalid_word' | 'not_your_turn' | 'game_not_started' | 'already_finished';
  message: string;
}

export interface StateResyncMessage {
  type: 'state_resync';
  roomCode: string;
  status: RoomStatus;
  myState: Omit<PlayerState, 'id'>;
  opponentState?: Omit<PlayerState, 'id'>;
  opponentId?: string;
}

export type ServerMessage =
  | RoomCreatedMessage
  | PlayerJoinedMessage
  | GameStartMessage
  | GuessResultMessage
  | OpponentTypingMessage
  | GameOverMessage
  | PlayerDisconnectedMessage
  | PlayerReconnectedMessage
  | ErrorMessage
  | StateResyncMessage;
