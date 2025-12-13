import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String id;
  final String player1;
  final String player2;
  final String? winner; // null for tie
  final List<List<String?>> board;
  final DateTime date;
  final String startingPlayer;

  MatchModel({
    required this.id,
    required this.player1,
    required this.player2,
    required this.winner,
    required this.board,
    required this.date,
    required this.startingPlayer,
  });

  Map<String, dynamic> toMap() {
    return {
      'player1': player1,
      'player2': player2,
      'winner': winner,
      'board': board.map((row) => row.map((cell) => cell).toList()).toList(),
      'date': Timestamp.fromDate(date),
      'startingPlayer': startingPlayer,
    };
  }

  static MatchModel fromMap(String id, Map<String, dynamic> map) {
    // Parse board safely
    List<List<String?>> parsedBoard = [
      [null, null, null],
      [null, null, null],
      [null, null, null],
    ];

    final rawBoard = map['board'];
    if (rawBoard is List) {
      try {
        parsedBoard = rawBoard.map<List<String?>>((row) {
          if (row is List) {
            return row.map<String?>((cell) => cell?.toString()).toList();
          }
          return <String?>[null, null, null];
        }).toList();
        if (parsedBoard.length != 3) {
          parsedBoard = [
            [null, null, null],
            [null, null, null],
            [null, null, null],
          ];
        }
      } catch (_) {
        // fallback to default empty board
      }
    }

    DateTime parsedDate = DateTime.now();
    final rawDate = map['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? parsedDate;
    }

    return MatchModel(
      id: id,
      player1: (map['player1'] ?? '').toString(),
      player2: (map['player2'] ?? '').toString(),
      winner: map['winner']?.toString(),
      board: parsedBoard,
      date: parsedDate,
      startingPlayer: (map['startingPlayer'] ?? '').toString(),
    );
  }

  factory MatchModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MatchModel.fromMap(doc.id, data);
  }
}

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.tryParse(map['lastLoginAt'].toString())
          : null,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
