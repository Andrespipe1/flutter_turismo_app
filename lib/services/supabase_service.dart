import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getPosts() async {
    final data = await _client.from('posts').select().order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getPhotos(String postId) async {
    final data = await _client.from('photos').select().eq('post_id', postId);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getReviews(String postId) async {
    final data = await _client.from('reviews')
      .select()
      .eq('post_id', postId)
      .order('created_at', ascending: false);

    // Trae todas las replies de este post
    final allReplies = await _client.from('replies').select().order('created_at', ascending: true);

    // Agrupa replies por review_id
    for (final review in data) {
      review['replies'] = allReplies.where((r) => r['review_id'] == review['id']).toList();
    }
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getReplies(String reviewId) async {
    final data = await _client.from('replies').select().eq('review_id', reviewId).order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> deleteReview(String reviewId) async {
    await _client.from('reviews').delete().eq('id', reviewId);
  }
} 