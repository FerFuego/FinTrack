import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../shared/models/group_model.dart';

final groupRepositoryProvider = Provider<GroupRepository>(
  (ref) => GroupRepository(ref.watch(dioClientProvider)),
);

// Provider: list of groups
final groupsProvider = FutureProvider.autoDispose<List<GroupModel>>((ref) async {
  return ref.watch(groupRepositoryProvider).listGroups();
});

// Provider: single group detail
final groupDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, groupId) async {
  return ref.watch(groupRepositoryProvider).getGroupDetail(groupId);
});

class GroupRepository {
  final DioClient _client;
  GroupRepository(this._client);

  Future<List<GroupModel>> listGroups() async {
    final response = await _client.get(ApiEndpoints.groups);
    final list = response.data as List<dynamic>;
    return list.map((j) => GroupModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<GroupModel> createGroup({
    required String name,
    String? description,
    String emoji = '💰',
    String color = '#6C63FF',
  }) async {
    final response = await _client.post(ApiEndpoints.groups, data: {
      'name': name,
      'description': description,
      'emoji': emoji,
      'color': color,
    });
    return GroupModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getGroupDetail(int groupId) async {
    final response = await _client.get(ApiEndpoints.group(groupId));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getGroupSummary(int groupId, {String? currency}) async {
    final response = await _client.get(
      ApiEndpoints.groupSummary(groupId),
      params: currency != null ? {'currency': currency} : null,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createInvitation(int groupId, {String? email}) async {
    final response = await _client.post(
      ApiEndpoints.groupInvite(groupId),
      data: email != null ? {'email': email} : {},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<GroupModel> joinByCode(String code) async {
    final response = await _client.post(ApiEndpoints.joinGroup, data: {'code': code});
    return GroupModel.fromJson(response.data['group'] as Map<String, dynamic>);
  }

  Future<void> leaveGroup(int groupId) async {
    await _client.delete(ApiEndpoints.groupLeave(groupId));
  }

  Future<void> removeMember(int groupId, int userId) async {
    await _client.delete(ApiEndpoints.groupMember(groupId, userId));
  }

  Future<void> deleteGroup(int groupId) async {
    await _client.delete(ApiEndpoints.group(groupId));
  }
}
