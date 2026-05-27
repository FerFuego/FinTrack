import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../shared/models/transaction_model.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(dioClientProvider)),
);

// Provider: paginated transactions for a group
final transactionsProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, ({int groupId, int page, String? type, String? currency, String? search})>(
  (ref, args) async {
    return ref.watch(transactionRepositoryProvider).listTransactions(
      groupId: args.groupId,
      page: args.page,
      type: args.type,
      currency: args.currency,
      search: args.search,
    );
  },
);

// Provider: group summary
final groupSummaryProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, groupId) async {
  final response = await ref.watch(transactionRepositoryProvider).getSummary(groupId);
  return response;
});

class TransactionRepository {
  final DioClient _client;
  TransactionRepository(this._client);

  Future<Map<String, dynamic>> listTransactions({
    required int groupId,
    int page = 1,
    String? type,
    String? currency,
    String? userId,
    String? dateFrom,
    String? dateTo,
    String? search,
    int perPage = 20,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (type != null) 'type': type,
      if (currency != null) 'currency': currency,
      if (userId != null) 'user_id': userId,
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final response = await _client.get(ApiEndpoints.transactions(groupId), params: params);
    return response.data as Map<String, dynamic>;
  }

  Future<TransactionModel> createTransaction({
    required int groupId,
    required double amount,
    required String currency,
    required String description,
    required String type,
    required String date,
    String? category,
    String? notes,
  }) async {
    final response = await _client.post(
      ApiEndpoints.transactions(groupId),
      data: {
        'amount': amount,
        'currency': currency,
        'description': description,
        'type': type,
        'date': date,
        if (category != null) 'category': category,
        if (notes != null) 'notes': notes,
      },
    );
    return TransactionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTransaction(int groupId, int transactionId) async {
    await _client.delete(ApiEndpoints.transaction(groupId, transactionId));
  }

  Future<Map<String, dynamic>> getSummary(int groupId) async {
    final response = await _client.get(ApiEndpoints.groupSummary(groupId));
    return response.data as Map<String, dynamic>;
  }
}
