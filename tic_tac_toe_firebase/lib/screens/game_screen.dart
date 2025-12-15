import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe_firebase/providers/game_provider.dart';
import 'package:tic_tac_toe_firebase/services/firebase_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _resultDialogShown = false;

  // ADD THESE VARIABLES FOR TIMESTAMP TRACKING
  DateTime? _gameStartTime; // When game started
  int _moveCount = 0; // Count moves
  late GameProvider _provider; // Store provider reference

  // ADD: Function to start tracking time
  void _startGameTimer() {
    setState(() {
      _gameStartTime = DateTime.now();
      _moveCount = 0;
    });
  }

  // UPDATE: Modified saveGameToFirebase to include duration and moves
  Future<void> _saveGameToFirebase(
    BuildContext context,
    GameProvider provider,
  ) async {
    try {
      // Calculate duration in seconds
      final int duration;
      if (_gameStartTime != null) {
        final gameEndTime = DateTime.now();
        duration = gameEndTime.difference(_gameStartTime!).inSeconds;
      } else {
        duration = 0; // Fallback if timer wasn't started
      }

      // Get moves count from provider if available, otherwise use _moveCount
      final int moves;
      if (provider.moveCount != null) {
        moves = provider.moveCount!;
      } else {
        moves = _moveCount;
      }

      await _firebaseService.saveMatch(
        playerX: provider.playerX,
        playerO: provider.playerO,
        winner: provider.winner,
        board: provider.board,
        duration: duration, // ADD THIS
        moves: moves, // ADD THIS
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Game saved! Time: ${duration}s, Moves: $moves'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  // UPDATE: Modified handleRestartGame to reset timer
  void _handleRestartGame(GameProvider provider) {
    provider.resetGame();
    _resultDialogShown = false;

    // Reset timer and move count
    _startGameTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Game restarted!'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // UPDATE: Modified handleGoHome to save with timestamp
  void _handleGoHome(BuildContext context, GameProvider provider) {
    if (provider.gameOver) {
      _saveGameToFirebase(context, provider);
    }
    provider.resetGame();
    Navigator.pop(context);
    _resultDialogShown = false;
  }

  // ADD: Function to show game time in the dialog
  void _showResultDialogWithTime(GameProvider provider) {
    final int duration;
    if (_gameStartTime != null) {
      final gameEndTime = DateTime.now();
      duration = gameEndTime.difference(_gameStartTime!).inSeconds;
    } else {
      duration = 0;
    }

    final int moves;
    if (provider.moveCount != null) {
      moves = provider.moveCount!;
    } else {
      moves = _moveCount;
    }

    _resultDialogShown = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Column(
          children: [
            Icon(
              provider.winner == null ? Icons.handshake : Icons.emoji_events,
              size: 50,
              color: provider.winner == null
                  ? Colors.grey
                  : provider.winner == 'X'
                  ? Colors.blue
                  : Colors.red,
            ),
            const SizedBox(height: 10),
            Text(
              provider.winner == null
                  ? 'It\'s a Tie!'
                  : '${provider.winnerName} Wins! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: provider.winner == null
                    ? Colors.grey
                    : provider.winner == 'X'
                    ? Colors.blue
                    : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.winner == null
                  ? 'The match ended in a tie.'
                  : 'Congratulations to ${provider.winnerName} for winning the game!',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // ADD: Show game time and moves
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(Icons.timer, color: Colors.deepPurple.shade600),
                      const SizedBox(height: 4),
                      Text(
                        '$duration sec',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Text('Time', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.touch_app, color: Colors.blue.shade600),
                      const SizedBox(height: 4),
                      Text(
                        '$moves',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Text('Moves', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Restart Button
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _handleRestartGame(provider);
            },
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Restart'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
            ),
          ),

          // Switch Players Button
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _handleSwitchPlayers(provider);
            },
            icon: const Icon(Icons.swap_horiz, size: 20),
            label: const Text('Switch Players'),
            style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
          ),

          // Home Button
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _handleGoHome(context, provider);
            },
            icon: const Icon(Icons.home, size: 20),
            label: const Text('Home'),
            style: TextButton.styleFrom(foregroundColor: Colors.green.shade700),
          ),
        ],
      ),
    );
  }

  // UPDATE: Track moves when a move is made
  void _onCellTapped(int row, int col, GameProvider provider) {
    if (!provider.gameOver) {
      // Increment move count before making move
      setState(() {
        _moveCount++;
      });

      provider.makeMove(row, col);

      if (provider.gameOver) {
        _saveGameToFirebase(context, provider);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Start timer when screen loads
    _startGameTimer();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<GameProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth < screenHeight
        ? screenWidth * 0.85
        : screenHeight * 0.6;

    // Show result dialog once when game ends
    if (_provider.gameOver && !_resultDialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultDialogWithTime(_provider);
      });
    }

    // Calculate elapsed time for display
    final String elapsedTime;
    if (_gameStartTime != null) {
      final currentDuration = DateTime.now().difference(_gameStartTime!);
      final seconds = currentDuration.inSeconds;
      elapsedTime = seconds < 60
          ? '$seconds sec'
          : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    } else {
      elapsedTime = '0 sec';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Board'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Top Status Row - ADDED TIME AND MOVES DISPLAY
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _provider.gameOver
                                ? (_provider.winner == null
                                      ? 'Game Tied!'
                                      : '${_provider.winnerName} Wins!')
                                : '${_provider.currentPlayerName}\'s Turn',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _provider.gameOver
                                  ? (_provider.winner == null
                                        ? Colors.grey
                                        : Colors.deepPurple)
                                  : Colors.blue,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_provider.playerX} (X)  vs  ${_provider.playerO} (O)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // ADD: Game time and moves display
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer,
                              size: 14,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              elapsedTime,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.touch_app, size: 14, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              '$_moveCount moves',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Game Board
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.deepPurple, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          int row = index ~/ 3;
                          int col = index % 3;
                          return GestureDetector(
                            onTap: () =>
                                _onCellTapped(row, col, _provider), // UPDATED
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Center(
                                child: Text(
                                  _provider.board[row][col] ?? '',
                                  style: TextStyle(
                                    fontSize: boardSize * 0.12,
                                    fontWeight: FontWeight.bold,
                                    color: _provider.board[row][col] == 'X'
                                        ? Colors.blue
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Buttons Section
              Column(
                children: [
                  // Switch Players Button
                  if (_provider.gameOver)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleSwitchPlayers(_provider),
                          icon: const Icon(Icons.swap_horiz, size: 20),
                          label: const Text('Switch Players & Restart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Restart and Home Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleRestartGame(_provider),
                            icon: const Icon(Icons.refresh, size: 20),
                            label: const Text('Restart'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleGoHome(context, _provider),
                            icon: const Icon(Icons.home, size: 20),
                            label: const Text('Home'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ADD: Missing switch players function
  void _handleSwitchPlayers(GameProvider provider) {
    provider.switchPlayers();
    _resultDialogShown = false;
    // Also reset timer for new game
    _startGameTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Players switched! X is now O and O is now X'),
        backgroundColor: Colors.deepPurple,
        duration: Duration(seconds: 1),
      ),
    );
  }
}
