import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/photo_gallery.dart';
import '../widgets/review_tile.dart';
import '../services/supabase_service.dart';

class PostDetailPage extends StatefulWidget {
  final Map post;
  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  List<String> photoUrls = [];
  List<Map<String, dynamic>> reviews = [];
  String? userRole;
  bool loading = true;
  final reviewController = TextEditingController();
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { loading = true; error = null; });
    try {
      final photos = await SupabaseService().getPhotos(widget.post['id']);
      final revs = await SupabaseService().getReviews(widget.post['id']);
      final user = Supabase.instance.client.auth.currentUser;
      String? role;
      if (user != null) {
        final data = await Supabase.instance.client.from('roles').select().eq('user_id', user.id).maybeSingle();
        role = data != null ? data['role'] : null;
      }
      setState(() {
        photoUrls = photos.map<String>((p) => p['url'] as String).toList();
        reviews = revs;
        userRole = role;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error al cargar datos: $e';
        loading = false;
      });
    }
  }

  Future<void> _addReview() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || reviewController.text.trim().isEmpty) return;
    await Supabase.instance.client.from('reviews').insert({
      'post_id': widget.post['id'],
      'user_id': user.id,
      'content': reviewController.text.trim(),
    });
    reviewController.clear();
    _loadData();
  }

  Future<void> _addReply(String reviewId, String replyText) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || replyText.trim().isEmpty) return;
    await Supabase.instance.client.from('replies').insert({
      'review_id': reviewId,
      'user_id': user.id,
      'content': replyText.trim(),
    });
    _loadData();
  }

  Future<void> _deleteReview(String reviewId) async {
    await SupabaseService().deleteReview(reviewId);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        title: Text(widget.post['title'], style: const TextStyle(color: Color(0xFF6D5BFF), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF6D5BFF)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB9AFFF), Color(0xFFF8F3F8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 100,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.post['description'] ?? '', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Text('Ubicación: ${widget.post['location'] ?? ''}', style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: PhotoGallery(photoUrls: photoUrls),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('Reseñas', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Color(0xFF6D5BFF), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...reviews.map((review) => Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    ReviewTile(
                                      review: review,
                                      isPublisher: userRole == 'publicador',
                                      onDelete: userRole == 'publicador'
                                          ? () => _deleteReview(review['id'])
                                          : null,
                                    ),
                                    if (userRole == 'publicador')
                                      _ReplyInput(
                                        onSend: (replyText) => _addReply(review['id'], replyText),
                                      ),
                                  ],
                                ),
                              ),
                            )),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: reviewController,
                                    decoration: const InputDecoration(hintText: 'Escribe tu reseña...'),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send, color: Color(0xFF6D5BFF)),
                                  onPressed: _addReview,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (error != null) Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(error!, style: const TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}

class _ReplyInput extends StatefulWidget {
  final Function(String) onSend;
  const _ReplyInput({required this.onSend});

  @override
  State<_ReplyInput> createState() => _ReplyInputState();
}

class _ReplyInputState extends State<_ReplyInput> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Responder...'),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.reply, color: Color(0xFF6D5BFF)),
          onPressed: () {
            widget.onSend(controller.text);
            controller.clear();
          },
        ),
      ],
    );
  }
} 