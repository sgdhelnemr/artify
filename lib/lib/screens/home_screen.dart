import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/painting.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/painting_provider.dart';
import '../providers/theme_provider.dart';
import '../routes.dart';
import '../widgets/error_view.dart';
import '../widgets/painting_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final paintings = context.read<PaintingProvider>();
    final cart = context.read<CartProvider>();
    final messenger = ScaffoldMessenger.of(context);

    await paintings.loadPaintings();
    if (!mounted) return;

    if (paintings.error == null) {
      cart.prune(paintings.paintings.map((p) => p.id).toSet());
    } else if (paintings.paintings.isNotEmpty) {
      // Refresh failed but we still have data on screen.
      messenger.showSnackBar(SnackBar(content: Text(paintings.error!)));
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  Future<bool> _confirmDelete(String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete painting?'),
        content: Text('"$title" will be removed permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _delete(Painting p) async {
    final error = await context.read<PaintingProvider>().deletePainting(p);
    if (!mounted) return;
    if (error == null) {
      context.read<CartProvider>().remove(p.id);
      _snack('"${p.title}" deleted');
    } else {
      _snack(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaintingProvider>();
    final cart = context.watch<CartProvider>();
    final theme = context.watch<ThemeProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artify 🎨', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Discover',
            icon: const Icon(Icons.travel_explore),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.discover),
          ),
          Badge(
            isLabelVisible: cart.count > 0,
            label: Text('${cart.count}'),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'theme') theme.toggle();
              if (v == 'logout') auth.signOut();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'theme',
                child: Text(theme.isDark ? 'Light mode' : 'Dark mode'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('Log out (${auth.email ?? ''})'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.form),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(PaintingProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && provider.paintings.isEmpty) {
      return ErrorView(message: provider.error!, onRetry: _load);
    }

    final list = provider.visible;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: provider.setQuery,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search title or artist',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Favorites'),
                avatar: const Icon(Icons.favorite, size: 16),
                selected: provider.favoritesOnly,
                onSelected: provider.setFavoritesOnly,
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: list.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 160),
                      Center(child: Text('No paintings found 🖼️', style: TextStyle(fontSize: 18))),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final p = list[index];
                      return Dismissible(
                        key: ValueKey(p.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) => _confirmDelete(p.title),
                        onDismissed: (_) => _delete(p),
                        child: PaintingCard(
                          painting: p,
                          isLiked: provider.isLiked(p.id),
                          onTap: () => Navigator.pushNamed(context, AppRoutes.details, arguments: p.id),
                          onLike: () => provider.toggleLike(p.id),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
