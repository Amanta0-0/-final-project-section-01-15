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

  void _saveGameToFirebase(BuildContext context, GameProvider provider) async {
    try {
      await _firebaseService.saveMatch(
        playerX: provider.playerX,
        playerO: provider.playerO,
        winner: provider.winner,
        board: provider.board,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Game saved!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
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

  void _handleRestartGame(GameProvider provider) {
    provider.resetGame();
    _resultDialogShown = false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Game restarted!'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleGoHome(BuildContext context, GameProvider provider) {
    if (provider.gameOver) {
      _saveGameToFirebase(context, provider);
    }
    provider.resetGame();
    Navigator.pop(context);
    _resultDialogShown = false;
  }

  void _handleSwitchPlayers(GameProvider provider) {
    provider.switchPlayers();
    _resultDialogShown = false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Players switched! X is now O and O is now X'),
        backgroundColor: Colors.deepPurple,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth < screenHeight
        ? screenWidth * 0.85
        : screenHeight * 0.6;

    // Show result dialog once when game ends
    if (provider.gameOver && !_resultDialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resultDialogShown = true;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Column(
              children: [
                Icon(
                  provider.winner == null
                      ? Icons.handshake
                      : Icons.emoji_events,
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
            content: Text(
              provider.winner == null
                  ? 'The match ended in a tie.'
                  : 'Congratulations to ${provider.winnerName} for winning the game!',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
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
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                ),
              ),
            ],
          ),
        );
      });
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
              // Top Status Row
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
                            provider.gameOver
                                ? (provider.winner == null
                                      ? 'Game Tied!'
                                      : '${provider.winnerName} Wins!')
                                : '${provider.currentPlayerName}\'s Turn',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: provider.gameOver
                                  ? (provider.winner == null
                                        ? Colors.grey
                                        : Colors.deepPurple)
                                  : Colors.blue,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.playerX} (X)  vs  ${provider.playerO} (O)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Game Status Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: provider.gameOver
                            ? (provider.winner == null
                                  ? Colors.grey.shade200
                                  : provider.winner == 'X'
                                  ? Colors.blue.shade50
                                  : Colors.red.shade50)
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: provider.gameOver
                              ? (provider.winner == null
                                    ? Colors.grey
                                    : provider.winner == 'X'
                                    ? Colors.blue
                                    : Colors.red)
                              : Colors.blue,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        provider.gameOver ? 'Game Over' : 'Playing',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: provider.gameOver
                              ? (provider.winner == null
                                    ? Colors.grey
                                    : provider.winner == 'X'
                                    ? Colors.blue
                                    : Colors.red)
                              : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Game Board (responsive) inside Expanded
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
                            onTap: () {
                              if (!provider.gameOver) {
                                provider.makeMove(row, col);
                                if (provider.gameOver) {
                                  _saveGameToFirebase(context, provider);
                                }
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Center(
                                child: Text(
                                  provider.board[row][col] ?? '',
                                  style: TextStyle(
                                    fontSize: boardSize * 0.12,
                                    fontWeight: FontWeight.bold,
                                    color: provider.board[row][col] == 'X'
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

              // Buttons Section - Two Rows for better organization
              Column(
                children: [
                  // First Row: Switch Players Button (only when game is over)
                  if (provider.gameOver)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleSwitchPlayers(provider),
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

                  // Second Row: Restart and Home Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleRestartGame(provider),
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
                            onPressed: () => _handleGoHome(context, provider),
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
}
