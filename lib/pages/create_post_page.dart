import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';
import '../services/supabase_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final locationController = TextEditingController();
  List<XFile> images = [];
  bool loading = false;
  String? error;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked != null && picked.length <= 5) {
      setState(() { images = picked; });
    } else if (picked.length > 5) {
      setState(() { error = 'Solo puedes seleccionar hasta 5 fotos.'; });
    }
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { loading = true; error = null; });
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() { error = 'Usuario no autenticado.'; loading = false; });
      return;
    }
    try {
      final insertRes = await Supabase.instance.client
          .from('posts')
          .insert({
            'user_id': user.id,
            'title': titleController.text,
            'description': descController.text,
            'location': locationController.text,
          })
          .select();
      if (insertRes == null || insertRes.isEmpty) {
        setState(() { error = 'No se pudo crear el post.'; loading = false; });
        return;
      }
      final postId = insertRes.first['id'];
      final uuid = Uuid();
      for (int i = 0; i < images.length; i++) {
        final img = images[i];
        final bytes = await img.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${i}_${uuid.v4()}_${img.name}';
        await Supabase.instance.client.storage.from('photos').uploadBinary(fileName, bytes);
        final publicUrl = Supabase.instance.client.storage.from('photos').getPublicUrl(fileName);
        await Supabase.instance.client.from('photos').insert({
          'post_id': postId,
          'url': publicUrl,
        });
      }
      Navigator.pop(context, true);
    } catch (e) {
      setState(() { error = 'Error al crear el post: $e'; });
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        title: const Text('Nuevo sitio turístico', style: TextStyle(color: Color(0xFF6D5BFF), fontWeight: FontWeight.bold)),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 100,
              ),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: 'Título', prefixIcon: Icon(Icons.title)),
                          validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descController,
                          decoration: const InputDecoration(labelText: 'Descripción', prefixIcon: Icon(Icons.description)),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: locationController,
                          decoration: const InputDecoration(labelText: 'Ubicación', prefixIcon: Icon(Icons.location_on)),
                        ),
                        const SizedBox(height: 16),
                        Text('Fotos (máx. 5):', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            ...images.map((img) => ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: kIsWeb
                                      ? Image.network(img.path, width: 80, height: 80, fit: BoxFit.cover)
                                      : Image.file(File(img.path), width: 80, height: 80, fit: BoxFit.cover),
                                )),
                            if (images.length < 5)
                              GestureDetector(
                                onTap: _pickImages,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.deepPurple),
                                  ),
                                  child: const Icon(Icons.add_a_photo, color: Colors.deepPurple),
                                ),
                              ),
                          ],
                        ),
                        if (error != null) Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(error!, style: const TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: loading ? const CircularProgressIndicator() : const Icon(Icons.save),
                            label: const Text('Guardar'),
                            onPressed: loading ? null : _savePost,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6D5BFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
} 