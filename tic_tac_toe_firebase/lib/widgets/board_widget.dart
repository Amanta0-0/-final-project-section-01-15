import 'package:flutter/material.dart';

class BoardWidget extends StatelessWidget {
  final List<List<String?>> board;
  final Function(int, int) onCellTap;

  const BoardWidget({super.key, required this.board, required this.onCellTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final row = index ~/ 3;
          final col = index % 3;
          final cell = board[row][col];

          return GestureDetector(
            onTap: () => onCellTap(row, col),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Center(
                child: Text(
                  cell ?? '',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: cell == 'X' ? Colors.blue : Colors.red,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
