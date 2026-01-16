import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../../domain/groups/entities/group.dart';
import '../../../domain/groups/entities/group_invitation.dart';
import '../../../domain/groups/entities/group_member.dart';
import '../../../domain/groups/entities/group_quiz.dart';
import '../../../domain/groups/entities/leaderboard_entry.dart';
import '../../../domain/groups/repositories/group_repository.dart';
import '../../core/backend_config.dart';
import '../dtos/group_dto.dart';
import '../dtos/group_invitation_dto.dart';
import '../dtos/group_member_dto.dart';
import '../dtos/group_quiz_dto.dart';
import '../dtos/leaderboard_entry_dto.dart';

/// HTTP implementation of GroupRepository.
class HttpGroupRepository implements GroupRepository {
  final http.Client client;

  HttpGroupRepository({required this.client});

  Uri _resolve(String path) => Uri.parse('${BackendSettings.baseUrl}/$path');

  Map<String, String> _headers(String accessToken) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  void _log(String message) {
    developer.log(message, name: 'HttpGroupRepository');
    // ignore: avoid_print
    print('[HttpGroupRepository] $message');
  }

  @override
  Future<List<Group>> getGroups({required String accessToken}) async {
    final uri = _resolve('groups');
    _log('GET $uri');
    final response = await client.get(uri, headers: _headers(accessToken));
    _log('Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((json) => GroupDto.fromJson(json).toDomain())
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Not authenticated');
    } else {
      throw Exception('Failed to fetch groups: ${response.statusCode}');
    }
  }

  @override
  Future<Group> createGroup({
    required String name,
    required String accessToken,
  }) async {
    final uri = _resolve('groups');
    final body = jsonEncode({'name': name});
    _log('POST $uri');
    _log('Request body: $body');
    _log('Headers: ${_headers(accessToken)}');

    final response = await client.post(
      uri,
      headers: _headers(accessToken),
      body: body,
    );

    _log('Response: ${response.statusCode}');
    _log('Response body: ${response.body}');

    if (response.statusCode == 201) {
      return GroupDto.fromJson(jsonDecode(response.body)).toDomain();
    } else if (response.statusCode == 400) {
      throw Exception('Missing required fields. Response: ${response.body}');
    } else if (response.statusCode == 401) {
      throw Exception('Not authenticated');
    } else {
      throw Exception(
        'Failed to create group: ${response.statusCode} - ${response.body}',
      );
    }
  }

  @override
  Future<Group> updateGroup({
    required String groupId,
    String? name,
    String? description,
    required String accessToken,
  }) async {
    final uri = _resolve('groups/$groupId');
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;

    final response = await client.patch(
      uri,
      headers: _headers(accessToken),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return GroupDto.fromJson(jsonDecode(response.body)).toDomain();
    } else if (response.statusCode == 403) {
      throw Exception('Not authorized: Only admin can update group');
    } else if (response.statusCode == 404) {
      throw Exception('Group not found');
    } else {
      throw Exception('Failed to update group: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteGroup({
    required String groupId,
    required String accessToken,
  }) async {
    final uri = _resolve('groups/$groupId');
    final response = await client.delete(uri, headers: _headers(accessToken));

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 403) {
      throw Exception('Not authorized: Only admin can delete group');
    } else if (response.statusCode == 404) {
      throw Exception('Group not found');
    } else {
      throw Exception('Failed to delete group: ${response.statusCode}');
    }
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String memberId,
    required String accessToken,
  }) async {
    final uri = _resolve('groups/$groupId/members/$memberId');
    final response = await client.delete(uri, headers: _headers(accessToken));

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Not authenticated');
    } else if (response.statusCode == 403) {
      throw Exception('Not authorized');
    } else if (response.statusCode == 404) {
      throw Exception('Member or group not found');
    } else {
      throw Exception('Failed to remove member: ${response.statusCode}');
    }
  }

  @override
  Future<void> transferAdmin({
    required String groupId,
    required String newAdminId,
    required String accessToken,
  }) async {
    final uri = _resolve('groups/$groupId/transfer-admin');
    final response = await client.patch(
      uri,
      headers: _headers(accessToken),
      body: jsonEncode({'newAdminId': newAdminId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else if (response.statusCode == 400) {
      throw Exception('New admin is not a member of the group');
    } else if (response.statusCode == 403) {
      throw Exception('Not authorized: Only admin can transfer rights');
    } else {
      throw Exception('Failed to transfer admin: ${response.statusCode}');
    }
  }

  @override
  Future<GroupInvitation> createInvitation({
    required String groupId,
    String expiresIn = '7d',
    required String accessToken,
  }) async {
    final uri = _resolve('groups/$groupId/invitations');
    final response = await client.post(
      uri,
      headers: _headers(accessToken),
      body: jsonEncode({'expiresIn': expiresIn}),
    );

    if (response.statusCode == 201) {
      return GroupInvitationDto.fromJson(jsonDecode(response.body)).toDomain();
    } else if (response.statusCode == 401) {
      throw Exception('Not authenticated');
    } else if (response.statusCode == 403) {
      throw Exception('Not authorized: Only admin can create invitations');
    } else {
      throw Exception('Failed to create invitation: ${response.statusCode}');
    }
  }

  @override
  Future<Group> joinGroup({
    required String invitationToken,
    required String accessToken,
  }) async {
    final uri = _resolve('groups/join');
    _log('POST $uri');
    _log('Request body: ${jsonEncode({'invitationToken': invitationToken})}');

    final response = await client.post(
      uri,
      headers: _headers(accessToken),
      body: jsonEncode({'invitationToken': invitationToken}),
    );

    _log('Response: ${response.statusCode}');
    _log('Response body: ${response.body}');

    // API returns 200 with list of groups or 201 with join info
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);

      // If it's a list, take the first group
      if (decoded is List && decoded.isNotEmpty) {
        return GroupDto.fromJson(
          decoded.first as Map<String, dynamic>,
        ).toDomain();
      }

      // If it's a single object with groupId (legacy format)
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('groupId')) {
          return Group(
            id: decoded['groupId'] as String? ?? '',
            name: decoded['groupName'] as String? ?? 'Group',
            role: GroupRoleExtension.fromString(
              decoded['role'] as String? ?? 'member',
            ),
            memberCount: 0,
            createdAt: decoded['joinedAt'] != null
                ? DateTime.parse(decoded['joinedAt'] as String)
                : DateTime.now(),
          );
        }
        // It's a group object directly
        return GroupDto.fromJson(decoded).toDomain();
      }

      throw Exception('Unexpected response format');
    } else if (response.statusCode == 400) {
      throw Exception('Invalid or expired invitation token');
    } else {
      throw Exception(
        'Failed to join group: ${response.statusCode} - ${response.body}',
      );
    }
  }

  @override
  Future<void> assignQuiz({
    required String groupId,
    required String quizId,
    required DateTime availableFrom,
    required DateTime availableUntil,
    required String accessToken,
  }) async {
    final uri = _resolve('groups/$groupId/quizzes');
    final response = await client.post(
      uri,
      headers: _headers(accessToken),
      body: jsonEncode({
        'quizId': quizId,
        'availableFrom': availableFrom.toIso8601String(),
        'availableUntil': availableUntil.toIso8601String(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else if (response.statusCode == 400) {
      throw Exception('Invalid dates');
    } else if (response.statusCode == 403) {
      throw Exception('Not authorized to assign quiz');
    } else if (response.statusCode == 404) {
      throw Exception('Quiz not found');
    } else {
      throw Exception('Failed to assign quiz: ${response.statusCode}');
    }
  }

  @override
  Future<List<GroupQuiz>> getGroupQuizzes({
    required String groupId,
    required String accessToken,
  }) async {
    final uri = _resolve('groups/$groupId/quizzes');
    final response = await client.get(uri, headers: _headers(accessToken));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? json;
      return data
          .map((item) => GroupQuizDto.fromJson(item).toDomain())
          .toList();
    } else {
      throw Exception('Failed to fetch group quizzes: ${response.statusCode}');
    }
  }

  @override
  Future<List<LeaderboardEntry>> getGroupLeaderboard({
    required String groupId,
    required String accessToken,
  }) async {
    final uri = _resolve('groups/$groupId/leaderboard');
    final response = await client.get(uri, headers: _headers(accessToken));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .asMap()
          .entries
          .map(
            (entry) =>
                LeaderboardEntryDto.fromJson(entry.value, entry.key).toDomain(),
          )
          .toList();
    } else if (response.statusCode == 403) {
      throw Exception('Not a member of this group');
    } else if (response.statusCode == 404) {
      throw Exception('Group not found');
    } else {
      throw Exception('Failed to fetch leaderboard: ${response.statusCode}');
    }
  }

  @override
  Future<List<LeaderboardEntry>> getQuizLeaderboard({
    required String groupId,
    required String quizId,
    required String accessToken,
  }) async {
    final uri = _resolve('groups/$groupId/quizzes/$quizId/leaderboard');
    final response = await client.get(uri, headers: _headers(accessToken));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> topPlayers = json['topPlayers'] ?? json;
      return topPlayers
          .asMap()
          .entries
          .map(
            (entry) =>
                LeaderboardEntryDto.fromJson(entry.value, entry.key).toDomain(),
          )
          .toList();
    } else if (response.statusCode == 404) {
      throw Exception('Group or quiz not found');
    } else {
      throw Exception(
        'Failed to fetch quiz leaderboard: ${response.statusCode}',
      );
    }
  }

  @override
  Future<List<GroupMember>> getGroupMembers({
    required String groupId,
    required String accessToken,
  }) async {
    final uri = _resolve('groups/$groupId/members');
    _log('GET $uri');
    final response = await client.get(uri, headers: _headers(accessToken));
    _log('Response: ${response.statusCode}');
    _log('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      // Fetch user profile for each member to get their name
      final members = <GroupMember>[];
      for (final memberJson in jsonList) {
        final userId = memberJson['userId'] as String;
        final role = memberJson['role'] as String? ?? 'MEMBER';

        // Fetch user profile
        String name = 'User';
        String? avatarUrl;
        try {
          final profileUri = _resolve('user/profile/id/$userId');
          _log('GET $profileUri');
          final profileResponse = await client.get(
            profileUri,
            headers: _headers(accessToken),
          );
          _log('Profile Response: ${profileResponse.statusCode}');

          if (profileResponse.statusCode == 200) {
            final profileData = jsonDecode(profileResponse.body);
            final user = profileData['user'] as Map<String, dynamic>?;
            if (user != null) {
              // Try to get name from userProfileDetails first, then fallback to username/email
              final profileDetails =
                  user['userProfileDetails'] as Map<String, dynamic>?;
              name =
                  profileDetails?['name'] as String? ??
                  user['username'] as String? ??
                  user['email'] as String? ??
                  'User';
              avatarUrl = profileDetails?['avatarAssetUrl'] as String?;
            }
          }
        } catch (e) {
          _log('Error fetching profile for $userId: $e');
        }

        members.add(
          GroupMember(
            id: userId,
            name: name,
            role: GroupRoleExtension.fromString(role),
            avatarUrl: avatarUrl,
          ),
        );
      }

      return members;
    } else if (response.statusCode == 403) {
      throw Exception('Not a member of this group');
    } else if (response.statusCode == 404) {
      throw Exception('Group not found');
    } else {
      throw Exception('Failed to fetch members: ${response.statusCode}');
    }
  }
}
