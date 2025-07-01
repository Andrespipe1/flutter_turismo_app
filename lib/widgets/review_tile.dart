import 'package:flutter/material.dart';

class ReviewTile extends StatelessWidget {
  final Map<String, dynamic> review;
  final bool isPublisher;
  final VoidCallback? onDelete;
  const ReviewTile({super.key, required this.review, this.isPublisher = false, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final replies = review['replies'] as List<dynamic>? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.reviews),
          title: Text(review['content'] ?? ''),
          subtitle: const Text('Por: Anónimo'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (review['rating'] != null) Text('⭐ ${review['rating']}'),
              if (isPublisher && onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Eliminar reseña',
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
        ...replies.map((reply) => Padding(
              padding: const EdgeInsets.only(left: 32, bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 16, color: Colors.deepPurple),
                  const SizedBox(width: 4),
                  Expanded(child: Text(reply['content'] ?? '', style: const TextStyle(color: Colors.deepPurple))),
                ],
              ),
            )),
      ],
    );
  }
} 