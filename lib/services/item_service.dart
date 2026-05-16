import 'package:my_app/models/item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemService {
  ItemService(this._client);

  final SupabaseClient _client;

  static const _table = 'items';

  Future<List<Item>> fetchAll() async {
    final data = await _client
        .from(_table)
        .select()
        .order('created_at', ascending: false);

    return (data as List)
        .map((row) => Item.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<Item> create({
    required String itemCode,
    required String name,
    required int quantity,
    required double price,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final data = await _client
        .from(_table)
        .insert({
          'user_id': userId,
          'item_code': itemCode,
          'name': name,
          'quantity': quantity,
          'price': price,
        })
        .select()
        .single();

    return Item.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Item> update({
    required String id,
    required String itemCode,
    required String name,
    required int quantity,
    required double price,
  }) async {
    final data = await _client
        .from(_table)
        .update({
          'item_code': itemCode,
          'name': name,
          'quantity': quantity,
          'price': price,
        })
        .eq('id', id)
        .select()
        .single();

    return Item.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
