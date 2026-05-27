import 'package:flutter/foundation.dart' show kIsWeb;

class ApiEndpoints {
  // Selects the correct host depending on the platform:
  // - Web (Chrome) and macOS desktop → localhost
  // - Android emulator               → 10.0.2.2  (maps to host machine)
  // - Physical device                → change to your machine's LAN IP
  static String get _host {
    if (kIsWeb) return 'http://127.0.0.1:8001';
    // Android emulator: return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8001'; // macOS desktop / iOS simulator
  }

  static String get baseUrl => '$_host/api';


  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/user';

  // Groups
  static const String groups = '/groups';
  static String group(int id) => '/groups/$id';
  static String groupSummary(int id) => '/groups/$id/summary';
  static String groupInvite(int id) => '/groups/$id/invite';
  static String groupLeave(int id) => '/groups/$id/leave';
  static String groupMember(int groupId, int userId) => '/groups/$groupId/members/$userId';
  static const String joinGroup = '/groups/join';

  // Transactions
  static String transactions(int groupId) => '/groups/$groupId/transactions';
  static String transaction(int groupId, int txId) => '/groups/$groupId/transactions/$txId';
}
