import 'package:flutter/material.dart';
import 'package:tic_tac_toe_firebase/services/firebase_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isDeletingAll = false;
  late Future<List<Map<String, dynamic>>> _initialMatchesFuture;

  @override
  void initState() {
    super.initState();
    // Load initial data once
    _initialMatchesFuture = _firebaseService.getMatches().first;
  }

  // Function to handle Clear All action - IMMEDIATE
  void _handleClearAll() async {
    final matches = await _initialMatchesFuture;

    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No game history to clear'),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
          'Are you sure you want to delete ALL game history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE ALL'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _isDeletingAll = true;
      });

      try {
        // IMMEDIATE CLEAR - Show success first, then process
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clearing all history...'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );

        // Fire and forget - don't wait for completion
        _firebaseService.clearAllMatches();

        // Show immediate success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All history cleared successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Reset loading state after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isDeletingAll = false;
            });
          }
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            _isDeletingAll = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  // Helper function to format duration
  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    }

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (remainingSeconds == 0) {
      return '$minutes min';
    }

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        actions: [
          // Clear All button in AppBar for quick access
          IconButton(
            onPressed: _handleClearAll,
            icon: _isDeletingAll
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.delete_forever),
            tooltip: 'Clear All History',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.blue.shade50,
              Colors.green.shade50,
            ],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _initialMatchesFuture,
          builder: (context, initialSnapshot) {
            // Initial loading (only once)
            if (initialSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Loading history...',
                      style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                    ),
                  ],
                ),
              );
            }

            // Now use StreamBuilder for real-time updates
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firebaseService.getMatches(),
              initialData: initialSnapshot.data, // Use cached data
              builder: (context, streamSnapshot) {
                // If stream hasn't started yet, use initial data
                final matches =
                    streamSnapshot.data ?? initialSnapshot.data ?? [];

                // Error state
                if (streamSnapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 60),
                        const SizedBox(height: 20),
                        const Text(
                          'Error loading history',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            streamSnapshot.error.toString(),
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Refresh initial data
                            setState(() {
                              _initialMatchesFuture = _firebaseService
                                  .getMatches()
                                  .first;
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Empty state
                if (matches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off,
                          color: Colors.deepPurple.shade300,
                          size: 80,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No games played yet',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Play a game to see history here!',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                          child: const Text('Go Play Now'),
                        ),
                      ],
                    ),
                  );
                }

                // Calculate total statistics
                int totalGames = matches.length;
                int xWins = matches.where((m) => m['winner'] == 'X').length;
                int oWins = matches.where((m) => m['winner'] == 'O').length;
                int ties = matches
                    .where((m) => m['winner'] == null || m['winner'] == 'Tie')
                    .length;

                // Calculate average duration
                int totalDuration = 0;
                int validDurationGames = 0;
                for (var match in matches) {
                  if (match['duration'] != null && match['duration'] is int) {
                    totalDuration += match['duration'] as int;
                    validDurationGames++;
                  }
                }
                int averageDuration = validDurationGames > 0
                    ? totalDuration ~/ validDurationGames
                    : 0;

                // List of matches
                return Column(
                  children: [
                    // Statistics Card
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              const Text(
                                '📊 Game Statistics',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    'Total Games',
                                    totalGames.toString(),
                                    Icons.games,
                                  ),
                                  _buildStatItem(
                                    'X Wins',
                                    xWins.toString(),
                                    Icons.circle,
                                    color: Colors.blue,
                                  ),
                                  _buildStatItem(
                                    'O Wins',
                                    oWins.toString(),
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  _buildStatItem(
                                    'Ties',
                                    ties.toString(),
                                    Icons.handshake,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (averageDuration > 0)
                                Text(
                                  'Average Game Time: ${_formatDuration(averageDuration)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Matches List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: matches.length,
                        itemBuilder: (context, index) {
                          final match = matches[index];
                          final boardList = match['board'] as List<dynamic>;
                          final flatBoard = boardList.cast<String?>();
                          final duration = match['duration'] as int?;

                          // Get moves count (optional)
                          final moves = match['moves'] as int?;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Game number and date
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple.shade50,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          'Game ${index + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatDate(match['date']),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // Game duration and moves
                                  if (duration != null || moves != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          if (duration != null)
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.timer,
                                                  size: 16,
                                                  color: Colors
                                                      .deepPurple
                                                      .shade600,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDuration(duration),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors
                                                        .deepPurple
                                                        .shade700,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                              ],
                                            ),
                                          if (moves != null)
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.touch_app,
                                                  size: 16,
                                                  color: Colors.blue.shade600,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '$moves moves',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),

                                  // Players
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text(
                                                match['playerX'],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              const Text(
                                                'Player X',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple.shade100,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Text(
                                            'VS',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text(
                                                match['playerO'],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              const Text(
                                                'Player O',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Result
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          match['winner'] == null ||
                                              match['winner'] == 'Tie'
                                          ? Colors.grey.withOpacity(0.2)
                                          : match['winner'] == 'X'
                                          ? Colors.blue.withOpacity(0.2)
                                          : Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            match['winner'] == null ||
                                                match['winner'] == 'Tie'
                                            ? Colors.grey
                                            : match['winner'] == 'X'
                                            ? Colors.blue
                                            : Colors.red,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          match['winner'] == null ||
                                                  match['winner'] == 'Tie'
                                              ? Icons.handshake
                                              : Icons.emoji_events,
                                          size: 18,
                                          color:
                                              match['winner'] == null ||
                                                  match['winner'] == 'Tie'
                                              ? Colors.grey
                                              : match['winner'] == 'X'
                                              ? Colors.blue
                                              : Colors.red,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          match['winner'] == null ||
                                                  match['winner'] == 'Tie'
                                              ? 'RESULT: TIE'
                                              : 'WINNER: ${match['winner'] == 'X' ? match['playerX'] : match['playerO']} (${match['winner']})',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color:
                                                match['winner'] == null ||
                                                    match['winner'] == 'Tie'
                                                ? Colors.grey
                                                : match['winner'] == 'X'
                                                ? Colors.blue
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  // Board preview
                                  const Text(
                                    'Final Board:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: GridView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                          ),
                                      itemCount: 9,
                                      itemBuilder: (context, gridIndex) {
                                        int listIndex = gridIndex;
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              flatBoard[listIndex] ?? '',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    flatBoard[listIndex] == 'X'
                                                    ? Colors.blue
                                                    : Colors.red,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  // Delete button
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        // Show confirmation dialog
                                        bool? confirm = await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Game'),
                                            content: const Text(
                                              'Are you sure you want to delete this game?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('DELETE'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          // Show immediate feedback
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('Deleting game...'),
                                              backgroundColor: Colors.orange,
                                              duration: Duration(seconds: 1),
                                            ),
                                          );

                                          // Fire and forget
                                          _firebaseService.deleteMatch(
                                            match['id'],
                                          );

                                          // Show immediate success
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text('Game deleted'),
                                                backgroundColor: Colors.green,
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 16,
                                      ),
                                      label: const Text('Delete'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Helper to format date
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  // Helper widget for statistics
  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? Colors.deepPurple).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color ?? Colors.deepPurple),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.deepPurple,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
