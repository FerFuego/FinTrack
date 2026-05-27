import 'user_model.dart';

class GroupModel {
  final int id;
  final String name;
  final String? description;
  final String emoji;
  final String color;
  final int ownerId;
  final UserModel? owner;
  final List<UserModel> members;
  final int? transactionsCount;
  final String? inviteCode;
  final String? createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    this.description,
    required this.emoji,
    required this.color,
    required this.ownerId,
    this.owner,
    this.members = const [],
    this.transactionsCount,
    this.inviteCode,
    this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        emoji: json['emoji'] as String? ?? '💰',
        color: json['color'] as String? ?? '#6C63FF',
        ownerId: json['owner_id'] as int,
        owner: json['owner'] != null
            ? UserModel.fromJson(json['owner'] as Map<String, dynamic>)
            : null,
        members: (json['members'] as List<dynamic>?)
                ?.map((m) => UserModel.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [],
        transactionsCount: json['transactions_count'] as int?,
        inviteCode: json['invite_code'] as String?,
        createdAt: json['created_at'] as String?,
      );
}
