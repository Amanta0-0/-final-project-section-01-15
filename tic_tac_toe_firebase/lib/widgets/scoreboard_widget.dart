import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe_firebase/providers/game_provider.dart';

class ScoreboardWidget extends StatelessWidget {
  const ScoreboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'SCOREBOARD',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreColumn(
                  label: provider.playerX,
                  symbol: 'X',
                  wins: provider.xWins,
                  color: Colors.blue,
                ),
                _buildScoreColumn(
                  label: 'TIES',
                  symbol: '',
                  wins: provider.ties,
                  color: Colors.grey,
                ),
                _buildScoreColumn(
                  label: provider.playerO,
                  symbol: 'O',
                  wins: provider.oWins,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Total Matches: ${provider.xWins + provider.oWins + provider.ties}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreColumn({
    required String label,
    required String symbol,
    required int wins,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          symbol,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withAlpha((0.1 * 255).round()),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              wins.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
