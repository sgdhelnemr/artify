import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/painting.dart';
import '../providers/painting_provider.dart';
import '../services/art_api_service.dart';
import '../utils/error_helper.dart';
import '../widgets/error_view.dart';
import '../widgets/painting_image.dart';

/// Searches the public Art Institute of Chicago API and lets the user
/// import artworks into the gallery (saved to Supabase).
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _api = ArtApiService();
  final _searchCtrl = TextEditingController(text: 'monet');
  late Future<List<Painting>> _future;
  final Set<String> _added = {};

  @override
  void initState() {
    super.initState();
    _future = _api.search(_searchCtrl.text.trim());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search() {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _future = _api.search(q));
  }

  Future<void> _add(Painting p) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<PaintingProvider>().addPainting(p);
    if (!mounted) return;
    if (error == null) {
      setState(() => _added.add(p.image));
      messenger.showSnackBar(SnackBar(content: Text('"${p.title}" added to your gallery ✅')));
    } else {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover artworks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search artists or artworks (e.g. monet)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Painting>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return ErrorView(
                    message: friendlyError(snap.error!),
                    onRetry: _search,
                  );
                }
                final results = snap.data ?? [];
                if (results.isEmpty) {
                  return const Center(child: Text('No results. Try another search.'));
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, i) {
                    final p = results[i];
                    final added = _added.contains(p.image);
                    return ListTile(
                      leading: SizedBox(
                        width: 56,
                        height: 56,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: PaintingImage(path: p.image, height: 56),
                        ),
                      ),
                      title: Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${p.artist} • ${p.year}'),
                      trailing: added
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : FilledButton.tonal(
                              onPressed: () => _add(p),
                              child: const Text('Add'),
                            ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
