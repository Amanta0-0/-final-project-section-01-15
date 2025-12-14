import 'package:flutter/material.dart';

class GameProvider extends ChangeNotifier {
  // Game board (3x3 grid)
  List<List<String?>> board = [
    [null, null, null],
    [null, null, null],
    [null, null, null],
  ];

  String currentPlayer = 'X'; // X starts first
  String? winner; // null = no winner yet
  bool gameOver = false;

  // Player names
  String playerX = 'Player X';
  String playerO = 'Player O';

  // Scores
  int xWins = 0;
  int oWins = 0;
  int ties = 0;

  // Make a move
  void makeMove(int row, int col) {
    if (gameOver || board[row][col] != null) return;

    board[row][col] = currentPlayer;
    checkWinner();

    if (!gameOver) {
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    }

    notifyListeners();
  }

  // Check for winner
  void checkWinner() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != null &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        winner = board[i][0];
        gameOver = true;
        updateScores();
        return;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[0][i] != null &&
          board[0][i] == board[1][i] &&
          board[1][i] == board[2][i]) {
        winner = board[0][i];
        gameOver = true;
        updateScores();
        return;
      }
    }

    // Check diagonals
    if (board[0][0] != null &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      winner = board[0][0];
      gameOver = true;
      updateScores();
      return;
    }

    if (board[0][2] != null &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      winner = board[0][2];
      gameOver = true;
      updateScores();
      return;
    }

    // Check for tie
    bool isFull = true;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == null) {
          isFull = false;
          break;
        }
      }
    }

    if (isFull && winner == null) {
      gameOver = true;
      ties++;
      notifyListeners();
    }
  }

  void updateScores() {
    if (winner == 'X') {
      xWins++;
    } else if (winner == 'O') {
      oWins++;
    }
    notifyListeners();
  }

  // Reset the game
  void resetGame() {
    board = [
      [null, null, null],
      [null, null, null],
      [null, null, null],
    ];
    currentPlayer = 'X';
    winner = null;
    gameOver = false;
    notifyListeners();
  }

  // Update player names
  void updatePlayerX(String name) {
    playerX = name.isNotEmpty ? name : 'Player X';
    notifyListeners();
  }

  void updatePlayerO(String name) {
    playerO = name.isNotEmpty ? name : 'Player O';
    notifyListeners();
  }

  // Reset all scores
  void resetScores() {
    xWins = 0;
    oWins = 0;
    ties = 0;
    notifyListeners();
  }

  // Get current player name
  String get currentPlayerName {
    return currentPlayer == 'X' ? playerX : playerO;
  }

  // Get winner name
  String? get winnerName {
    if (winner == null) return null;
    return winner == 'X' ? playerX : playerO;
  }

  void switchPlayers() {}
}
