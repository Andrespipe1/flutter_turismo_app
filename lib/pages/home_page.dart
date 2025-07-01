import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import 'post_detail_page.dart';
import 'create_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userRole;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _getRole();
  }

  Future<void> _getRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final data = await Supabase.instance.client.from('roles').select().eq('user_id', user.id).maybeSingle();
      setState(() {
        userRole = data != null ? data['role'] : null;
        loading = false;
      });
    } else {
      setState(() { loading = false; });
    }
  }

  void _logout() async {
    await AuthService().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        title: const Text("Sitios turísticos", style: TextStyle(color: Color(0xFF6D5BFF), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF6D5BFF)),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: userRole == 'publicador'
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreatePostPage()),
                );
                if (result == true) setState(() {}); // Refresca la lista
              },
              icon: const Icon(Icons.add_location_alt, color: Colors.white),
              label: const Text('Nuevo sitio', style: TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFF6D5BFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB9AFFF), Color(0xFFF8F3F8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<List<Map<String, dynamic>>>(
                future: SupabaseService().getPosts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final posts = snapshot.data!;
                  if (posts.isEmpty) return const Center(child: Text("No hay publicaciones aún", style: TextStyle(color: Color(0xFF6D5BFF), fontSize: 18)));
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 100, bottom: 24),
                    itemCount: posts.length,
                    itemBuilder: (context, i) {
                      final post = posts[i];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          elevation: 8,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          child: ListTile(
                            leading: const Icon(Icons.place, color: Color(0xFF6D5BFF), size: 36),
                            title: Text(post['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            subtitle: Text(post['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF6D5BFF)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetailPage(post: post),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
} 