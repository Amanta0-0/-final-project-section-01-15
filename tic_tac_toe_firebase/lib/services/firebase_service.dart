import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save a match to Firestore
  Future<void> saveMatch({
    required String playerX,
    required String playerO,
    required String? winner,
    required List<List<String?>> board,
  }) async {
    try {
      await _firestore.collection('matches').add({
        'playerX': playerX,
        'playerO': playerO,
        'winner': winner,
        'board': _convertBoardToList(board),
        'timestamp': FieldValue.serverTimestamp(),
        'date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get all matches from Firestore
  Stream<List<Map<String, dynamic>>> getMatches() {
    return _firestore
        .collection('matches')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'playerX': data['playerX'] ?? '',
              'playerO': data['playerO'] ?? '',
              'winner': data['winner'],
              'board': data['board'],
              'date': data['date'] ?? '',
            };
          }).toList();
        });
  }

  // Delete a match
  Future<void> deleteMatch(String matchId) async {
    try {
      await _firestore.collection('matches').doc(matchId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Clear all matches
  Future<void> clearAllMatches() async {
    try {
      final snapshot = await _firestore.collection('matches').get();
      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // Helper: Convert 2D board to simple list for Firebase
  List<String?> _convertBoardToList(List<List<String?>> board) {
    return board.expand((row) => row).toList();
  }
}
